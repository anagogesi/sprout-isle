import Charts
import SwiftUI

struct ParentCornerView: View {
    @Environment(AppStore.self) private var store
    @Environment(EyeCareTimerService.self) private var eyeCare
    @Environment(\.dismiss) private var dismiss

    @State private var childName: String = ""
    @State private var avatarEmoji: String = "🐣"
    @State private var age: Int = 4
    @State private var autoSpeak: Bool = true
    @State private var soundEnabled: Bool = true
    @State private var eyeCareMinutes: Int = 15

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

    // MARK: - 2. Child Profile

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
        store.updateAISettings { ai in
            ai.isEnabled = aiEnabled
            ai.baseURL = baseURL.trimmingCharacters(in: .whitespacesAndNewlines)
            ai.modelName = modelName.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        KeychainHelper.saveAPIKey(apiKey)
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
