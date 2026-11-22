import Charts
import SwiftUI

struct ParentCornerView: View {
    @Environment(AppStore.self) private var store
    @Environment(ParentVoiceStore.self) private var parentVoices
    @Environment(SpeechService.self) private var speech
    @Environment(EyeCareTimerService.self) private var eyeCare
    @Environment(\.dismiss) private var dismiss

    @State private var childName: String = ""
    @State private var avatarEmoji: String = "🐣"
    @State private var age: Int = 4
    @State private var autoSpeak: Bool = true
    @State private var soundEnabled: Bool = true
    @State private var eyeCareMinutes: Int = 15

    // Voice & TTS Settings
    @State private var preferParentRecordings: Bool = true
    @State private var useBundledNeuralVoices: Bool = true
    @State private var onlineTTSEnabled: Bool = false
    @State private var ttsBaseURL: String = ""
    @State private var ttsModelName: String = ""
    @State private var ttsVoiceName: String = ""
    @State private var ttsAPIKey: String = ""
    @State private var ttsSpeed: Double = 0.95
    @State private var preferredAppleZhVoiceId: String = ""
    @State private var preferredAppleEnVoiceId: String = ""
    @State private var testingTTS: Bool = false
    @State private var ttsStatusMessage: String?
    @State private var ttsSucceeded: Bool?

    // AI Settings
    @State private var aiEnabled: Bool = false
    @State private var baseURL: String = ""
    @State private var modelName: String = ""
    @State private var apiKey: String = ""
    @State private var testingConnection: Bool = false
    @State private var testStatusMessage: String?
    @State private var testSucceeded: Bool?
    @State private var showResetConfirm: Bool = false

    private let aiService = AIService()

    var body: some View {
        NavigationStack {
            Form {
                reportSection
                voiceAndTTSSection
                profileSection
                eyeCareSection
                aiConfigurationSection
                maintenanceSection
            }
            .navigationTitle("家长小屋")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存并关闭") {
                        saveAllSettings()
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
            .onAppear(perform: loadFromStore)
            .alert("确认重置学习进度？", isPresented: $showResetConfirm) {
                Button("取消", role: .cancel) {}
                Button("确认重置", role: .destructive) {
                    store.resetProgress()
                }
            } message: {
                Text("将清空星星数、识字记录、打卡与自定义贴纸布局，但保留宝贝档案和 AI 设置。")
            }
        }
    }

    // MARK: - 1. Learning Report

    private var reportSection: some View {
        Section("学习成长报告") {
            let metrics: [(title: String, value: String, emoji: String)] = [
                ("累计星星", "\(store.state.totalStars) ⭐", "🌟"),
                ("已学汉字", "\(store.state.masteredHanziIds.count)/\(LiteracyCatalog.hanziCards.count)", "🌱"),
                ("数学正确率", "\(store.mathAccuracyPercent)%", "🔢"),
                ("英语词汇", "\(store.state.masteredEnglishIds.count) 词", "🐳"),
                ("已读绘本", "\(store.state.readStoryIds.count) 本", "📚"),
                ("连续打卡", "\(store.currentStreakDays) 天", "🔥"),
            ]

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(metrics, id: \.title) { item in
                    VStack(spacing: 4) {
                        Text(item.emoji)
                            .font(.system(size: 22))
                        Text(item.value)
                            .font(.kidHeadline(16))
                            .foregroundStyle(IslandTheme.inkDark)
                        Text(item.title)
                            .font(.kidCaption(11))
                            .foregroundStyle(IslandTheme.inkSoft)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(RoundedRectangle(cornerRadius: 14).fill(Color(hex: "F8FAFC")))
                }
            }
            .padding(.vertical, 6)

            // 7-day stars chart
            let recent = store.recent7DayRecords()
            VStack(alignment: .leading, spacing: 8) {
                Text("近 7 天获得星星趋势")
                    .font(.kidCaption(14))
                    .foregroundStyle(IslandTheme.inkSoft)

                Chart(recent, id: \.label) { entry in
                    BarMark(
                        x: .value("日期", entry.label),
                        y: .value("星星", entry.record.starsEarned)
                    )
                    .foregroundStyle(IslandTheme.mint.gradient)
                    .cornerRadius(6)
                }
                .frame(height: 130)
            }
            .padding(.vertical, 4)
        }
    }

    // MARK: - 2. Voice & Real-Human TTS Settings

    private var voiceAndTTSSection: some View {
        let zhVoices = SpeechService.availableNaturalAppleVoices(for: .chinese)
        let enVoices = SpeechService.availableNaturalAppleVoices(for: .english)

        return Section {
            NavigationLink {
                ParentVoiceStudioView()
            } label: {
                HStack {
                    Label("爸妈亲声录制室", systemImage: "mic.circle.fill")
                        .foregroundStyle(IslandTheme.coralDark)
                    Spacer()
                    Text("已录 \(parentVoices.recordedSlotIds.count) 段")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Toggle("优先播放爸妈亲声录制", isOn: $preferParentRecordings)

            Toggle("使用内置拟真幼师/童声语音包", isOn: $useBundledNeuralVoices)

            HStack {
                Label("离线拟真语音包状态", systemImage: "sparkles")
                    .font(.subheadline)
                Spacer()
                Text(speech.bundledVoiceCount > 0 ? "已内置 \(speech.bundledVoiceCount) 段" : "未打包")
                    .font(.caption)
                    .foregroundStyle(speech.bundledVoiceCount > 0 ? IslandTheme.mintDark : .secondary)
            }

            Button("🔊 试听内置拟真幼师声音") {
                saveAllSettings()
                speech.speak("你好呀！今天想去哪座小岛探险呢？", language: .chinese)
            }

            Toggle("动态内容启用在线真人 TTS", isOn: $onlineTTSEnabled)

            if onlineTTSEnabled {
                VStack(alignment: .leading, spacing: 8) {
                    Text("在线真人语音预设（OpenAI /audio/speech 兼容）")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(TTSProviderPreset.allCases) { preset in
                                Button(preset.rawValue) {
                                    ttsBaseURL = preset.defaultBaseURL
                                    ttsModelName = preset.defaultModel
                                    ttsVoiceName = preset.defaultVoice
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.small)
                            }
                        }
                    }
                }

                TextField("TTS Base URL", text: $ttsBaseURL)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.URL)

                TextField("TTS 模型（如 gpt-4o-mini-tts）", text: $ttsModelName)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                TextField("音色名（如 nova / shimmer / zf_xiaoyi）", text: $ttsVoiceName)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                SecureField("TTS API Key（留空则复用下方 AI Key）", text: $ttsAPIKey)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                HStack {
                    Text("语速 \(String(format: "%.2fx", ttsSpeed))")
                    Slider(value: $ttsSpeed, in: 0.75...1.15, step: 0.05)
                }

                Button {
                    testOnlineTTS()
                } label: {
                    HStack {
                        if testingTTS {
                            ProgressView()
                        } else {
                            Image(systemName: "waveform.circle.fill")
                        }
                        Text(testingTTS ? "正在合成真人语音..." : "试听在线真人 TTS")
                    }
                }
                .disabled(testingTTS)

                if let ttsStatusMessage {
                    Text(ttsStatusMessage)
                        .font(.footnote)
                        .foregroundStyle(ttsSucceeded == true ? IslandTheme.mintDark : IslandTheme.coralDark)
                }

                Button("清理在线语音本地缓存") {
                    speech.clearOnlineTTSCache()
                    ttsSucceeded = true
                    ttsStatusMessage = "已清理本地在线语音缓存"
                }
                .font(.footnote)
            }

            if !zhVoices.isEmpty {
                Picker("兜底系统中文音色", selection: $preferredAppleZhVoiceId) {
                    Text("自动选择最佳人声").tag("")
                    ForEach(zhVoices) { v in
                        Text("\(v.name)（\(v.qualityLabel)）").tag(v.id)
                    }
                }
            }

            if !enVoices.isEmpty {
                Picker("兜底系统英文音色", selection: $preferredAppleEnVoiceId) {
                    Text("自动选择最佳人声").tag("")
                    ForEach(enVoices) { v in
                        Text("\(v.name)（\(v.qualityLabel)）").tag(v.id)
                    }
                }
            }
        } header: {
            Text("真人声音与语音播报")
        } footer: {
            Text("播放优先级：爸妈原声 > 内置离线拟真语音包 > 在线真人 TTS（自动缓存）> 系统自然人声（已屏蔽机械变声音色）。在 iPhone/iPad 系统「设置 → 辅助功能 → 朗读内容 → 声音」中下载免费「增强版/Siri」语音可让兜底音色也更自然。")
        }
    }

    // MARK: - 3. Child Profile

    private var profileSection: some View {
        Section("宝贝档案与交互") {
            TextField("宝贝昵称", text: $childName)

            Picker("年龄阶段", selection: $age) {
                ForEach(3...6, id: \.self) { years in
                    Text("\(years) 岁").tag(years)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("选择头像")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(ChildProfile.avatarChoices, id: \.self) { emoji in
                            Button {
                                avatarEmoji = emoji
                            } label: {
                                Text(emoji)
                                    .font(.system(size: 28))
                                    .frame(width: 44, height: 44)
                                    .background(
                                        Circle()
                                            .fill(avatarEmoji == emoji ? IslandTheme.mint.opacity(0.25) : Color.clear)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }

            Toggle("自动语音朗读（推荐 3-6 岁开启）", isOn: $autoSpeak)
            Toggle("按键与鼓励音效", isOn: $soundEnabled)
        }
    }

    // MARK: - 3. Eye Care

    private var eyeCareSection: some View {
        Section("护眼防沉迷") {
            Picker("单次连续使用提醒", selection: $eyeCareMinutes) {
                Text("关闭提醒").tag(0)
                Text("10 分钟").tag(10)
                Text("15 分钟（推荐）").tag(15)
                Text("20 分钟").tag(20)
                Text("30 分钟").tag(30)
            }

            Button("立即预览护眼休息界面") {
                saveAllSettings()
                dismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    eyeCare.triggerEyeCareBreak()
                }
            }
        }
    }

    // MARK: - 4. AI Settings

    private var aiConfigurationSection: some View {
        Section {
            Toggle("启用在线 / 本地大模型创作", isOn: $aiEnabled)

            VStack(alignment: .leading, spacing: 8) {
                Text("快捷预设（支持 OpenAI 兼容协议）")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(AIProviderPreset.allCases) { preset in
                            Button(preset.rawValue) {
                                baseURL = preset.defaultBaseURL
                                modelName = preset.defaultModel
                                aiEnabled = true
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                        }
                    }
                }
            }

            TextField("Base URL（如 http://127.0.0.1:8000/v1）", text: $baseURL)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .keyboardType(.URL)

            TextField("模型名称（如 llm-lab / deepseek-chat）", text: $modelName)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

            SecureField("API Key（本地服务可留空，安全存于钥匙串）", text: $apiKey)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

            Button {
                testAIConnection()
            } label: {
                HStack {
                    if testingConnection {
                        ProgressView()
                    } else {
                        Image(systemName: "bolt.horizontal.circle.fill")
                    }
                    Text(testingConnection ? "正在测试连接..." : "测试 AI 连接")
                }
            }
            .disabled(testingConnection)

            if let testStatusMessage {
                Text(testStatusMessage)
                    .font(.footnote)
                    .foregroundStyle(testSucceeded == true ? IslandTheme.mintDark : IslandTheme.coralDark)
            }
        } header: {
            Text("AI 绘本与科普配置")
        } footer: {
            Text("关闭或断网时，小芽岛会自动使用内置的离线互动绘本与十万个为什么百科，小朋友随时都可以开心学习。")
        }
    }

    // MARK: - 5. Maintenance

    private var maintenanceSection: some View {
        Section("数据管理") {
            Button("重置所有学习记录", role: .destructive) {
                showResetConfirm = true
            }
        }
    }

    private func loadFromStore() {
        let p = store.state.profile
        childName = p.name
        avatarEmoji = p.avatarEmoji
        age = p.age
        autoSpeak = p.autoSpeak
        soundEnabled = p.soundEffectsEnabled
        eyeCareMinutes = p.eyeCareMinutes

        let tts = store.state.ttsSettings
        preferParentRecordings = tts.preferParentRecordings
        useBundledNeuralVoices = tts.useBundledNeuralVoices
        onlineTTSEnabled = tts.onlineTTSEnabled
        ttsBaseURL = tts.baseURL
        ttsModelName = tts.modelName
        ttsVoiceName = tts.voiceName
        ttsSpeed = tts.speed
        preferredAppleZhVoiceId = tts.preferredAppleZhVoiceId
        preferredAppleEnVoiceId = tts.preferredAppleEnVoiceId
        ttsAPIKey = KeychainHelper.loadTTSAPIKey()

        let ai = store.state.aiSettings
        aiEnabled = ai.isEnabled
        baseURL = ai.baseURL
        modelName = ai.modelName
        apiKey = KeychainHelper.loadAPIKey()
    }

    private func saveAllSettings() {
        let trimmedName = childName.trimmingCharacters(in: .whitespacesAndNewlines)
        store.updateProfile { profile in
            profile.name = trimmedName.isEmpty ? "小芽宝" : trimmedName
            profile.avatarEmoji = avatarEmoji
            profile.age = age
            profile.autoSpeak = autoSpeak
            profile.soundEffectsEnabled = soundEnabled
            profile.eyeCareMinutes = eyeCareMinutes
        }
        store.updateTTSSettings { tts in
            tts.preferParentRecordings = preferParentRecordings
            tts.useBundledNeuralVoices = useBundledNeuralVoices
            tts.onlineTTSEnabled = onlineTTSEnabled
            tts.baseURL = ttsBaseURL.trimmingCharacters(in: .whitespacesAndNewlines)
            tts.modelName = ttsModelName.trimmingCharacters(in: .whitespacesAndNewlines)
            tts.voiceName = ttsVoiceName.trimmingCharacters(in: .whitespacesAndNewlines)
            tts.speed = ttsSpeed
            tts.preferredAppleZhVoiceId = preferredAppleZhVoiceId
            tts.preferredAppleEnVoiceId = preferredAppleEnVoiceId
        }
        KeychainHelper.saveTTSAPIKey(ttsAPIKey)

        store.updateAISettings { ai in
            ai.isEnabled = aiEnabled
            ai.baseURL = baseURL.trimmingCharacters(in: .whitespacesAndNewlines)
            ai.modelName = modelName.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        KeychainHelper.saveAPIKey(apiKey)
    }

    private func testOnlineTTS() {
        saveAllSettings()
        testingTTS = true
        ttsStatusMessage = nil
        let settings = store.state.ttsSettings
        let key = ttsAPIKey.isEmpty ? apiKey : ttsAPIKey

        Task {
            let result = await speech.previewOnlineTTS(
                text: "你好呀，\(store.state.profile.name)！欢迎来到小芽岛一起快乐学习！",
                settings: settings,
                apiKey: key
            )
            await MainActor.run {
                testingTTS = false
                switch result {
                case .success:
                    ttsSucceeded = true
                    ttsStatusMessage = "合成并试听成功！"
                case let .failure(error):
                    ttsSucceeded = false
                    ttsStatusMessage = error.localizedDescription
                }
            }
        }
    }

    private func testAIConnection() {
        saveAllSettings()
        testingConnection = true
        testStatusMessage = nil
        let settings = store.state.aiSettings
        let key = apiKey

        Task {
            let result = await aiService.testConnection(settings: settings, apiKey: key)
            await MainActor.run {
                testingConnection = false
                switch result {
                case let .success(reply):
                    testSucceeded = true
                    testStatusMessage = "连接成功：\(reply)"
                case let .failure(error):
                    testSucceeded = false
                    testStatusMessage = error.localizedDescription
                }
            }
        }
    }
}
