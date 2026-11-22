import SwiftUI

struct StoryIslandView: View {
    @Environment(AppStore.self) private var store
    @Environment(SpeechService.self) private var speech
    @Environment(SoundEffectService.self) private var sound

    let onBack: () -> Void

    @State private var modeId: String = "books"
    @State private var activeBook: StoryBook?
    @State private var showAICreator: Bool = false

    // 100k Whys state
    @State private var selectedWhyCategory: WhyCategory = .sky
    @State private var selectedQA: WhyQAItem?
    @State private var questionInput: String = ""
    @State private var isAskingWhy: Bool = false
    @State private var whyStatusNote: String?

    private let aiService = AIService()
    private let modes = [
        ModeTabOption(id: "books", title: "互动绘本馆", emoji: "📚"),
        ModeTabOption(id: "why", title: "十万个为什么", emoji: "❓"),
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "F3ECFF"), IslandTheme.creamCanvas],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 12) {
                IslandHeaderBar(
                    destination: .stories,
                    starCount: store.state.totalStars,
                    onBack: onBack,
                    onSpeakTip: {
                        speech.speak(
                            modeId == "books"
                                ? "选一本喜欢的绘本点开听故事，或者用魔法绘本机创作新故事吧！"
                                : "有什么好奇的为什么？点一点气泡，或者问小芽宝吧！",
                            language: .chinese
                        )
                    }
                )

                ModePillBar(options: modes, selectedId: $modeId, accentColor: IslandTheme.lavender) {
                    sound.play(.tap)
                }

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        if modeId == "books" {
                            bookShelfView
                        } else {
                            hundredThousandWhysView
                        }
                        Spacer(minLength: 28)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 4)
                }
            }
        }
        .fullScreenCover(item: $activeBook) { book in
            StoryReaderView(book: book) {
                activeBook = nil
            }
        }
        .sheet(isPresented: $showAICreator) {
            AIStoryCreatorSheet { newBook in
                store.addCustomStory(newBook)
                showAICreator = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    activeBook = newBook
                }
            }
        }
    }

    // MARK: - Picture Book Shelf

    private var bookShelfView: some View {
        VStack(spacing: 16) {
            // AI Magic Story Creator Banner
            Button {
                sound.play(.star)
                showAICreator = true
            } label: {
                HStack(spacing: 14) {
                    Text("🪄")
                        .font(.system(size: 46))
                        .frame(width: 68, height: 68)
                        .background(Circle().fill(Color.white.opacity(0.24)))

                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text("魔法绘本机")
                                .font(.kidTitle(22))
                                .foregroundStyle(.white)
                            Text(store.state.aiSettings.isEnabled ? "AI 已开启" : "离线可用")
                                .font(.kidCaption(12))
                                .foregroundStyle(IslandTheme.lavenderDark)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Capsule().fill(Color.white.opacity(0.92)))
                        }
                        Text("挑一个主角和场景，立刻变出专属互动绘本！")
                            .font(.kidCaption(14))
                            .foregroundStyle(.white.opacity(0.92))
                    }

                    Spacer()
                    Image(systemName: "sparkles")
                        .font(.system(size: 24))
                        .foregroundStyle(.white)
                }
                .padding(18)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "9B72CF"), Color(hex: "6C4AB6")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                )
            }
            .buttonStyle(ToyButtonStyle(fill: Color.clear, shadow: IslandTheme.lavenderDark, cornerRadius: 26))

            // Book Grid
            let cols = [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]
            LazyVGrid(columns: cols, spacing: 14) {
                ForEach(store.allStories) { book in
                    let isRead = store.state.readStoryIds.contains(book.id)
                    Button {
                        sound.play(.tap)
                        activeBook = book
                    } label: {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text(book.coverEmoji)
                                    .font(.system(size: 46))
                                Spacer()
                                if isRead {
                                    Text("已读 ⭐")
                                        .font(.kidCaption(11))
                                        .foregroundStyle(IslandTheme.mintDark)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Capsule().fill(Color(hex: "E6F8EE")))
                                } else if book.isAIGenerated {
                                    Text("AI 创作")
                                        .font(.kidCaption(11))
                                        .foregroundStyle(IslandTheme.lavenderDark)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Capsule().fill(Color(hex: "F3E8FF")))
                                }
                            }

                            Text(book.title)
                                .font(.kidHeadline(18))
                                .foregroundStyle(IslandTheme.inkDark)
                                .lineLimit(2)

                            Text(book.subtitle)
                                .font(.kidCaption(12))
                                .foregroundStyle(IslandTheme.inkSoft)
                                .lineLimit(2)

                            HStack {
                                Text(book.themeTag)
                                    .font(.kidCaption(11))
                                    .foregroundStyle(Color(hex: book.accentHex))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Capsule().fill(Color(hex: book.accentHex).opacity(0.14)))
                                Spacer()
                                Text("\(book.pages.count) 页")
                                    .font(.kidCaption(12))
                                    .foregroundStyle(IslandTheme.inkSoft)
                            }
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, minHeight: 196, alignment: .topLeading)
                        .background(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                                        .strokeBorder(Color(hex: book.accentHex).opacity(0.35), lineWidth: 2)
                                )
                                .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - 100,000 Whys

    private var hundredThousandWhysView: some View {
        VStack(spacing: 16) {
            // Ask Box
            ToyCard(cornerRadius: 26, padding: 16) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("🔎 问问小芽宝「为什么」")
                            .font(.kidHeadline(18))
                            .foregroundStyle(IslandTheme.inkDark)
                        Spacer()
                        Text(store.state.aiSettings.isEnabled ? "✨ AI 模式" : "📖 离线百科")
                            .font(.kidCaption(12))
                            .foregroundStyle(IslandTheme.lavenderDark)
                            .padding(.horizontal, 9)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(Color(hex: "F3E8FF")))
                    }

                    HStack(spacing: 10) {
                        TextField("例如：为什么云朵不会掉下来？", text: $questionInput)
                            .font(.kidBody(16))
                            .padding(12)
                            .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color(hex: "F8FAFC")))
                            .submitLabel(.search)
                            .onSubmit { submitWhyQuestion() }

                        Button {
                            submitWhyQuestion()
                        } label: {
                            if isAskingWhy {
                                ProgressView()
                                    .tint(.white)
                                    .frame(width: 52, height: 46)
                            } else {
                                Text("问一问")
                                    .font(.kidCaption(15))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 14)
                                    .frame(height: 46)
                            }
                        }
                        .buttonStyle(ToyButtonStyle(fill: IslandTheme.lavender, shadow: IslandTheme.lavenderDark, cornerRadius: 16))
                        .disabled(isAskingWhy)
                    }
                }
            }

            // Active Answer Spotlight
            if let qa = selectedQA {
                ToyCard(background: Color(hex: "FBF7FF"), border: IslandTheme.lavender.opacity(0.5), cornerRadius: 28, padding: 18) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(alignment: .top) {
                            Text(qa.emoji)
                                .font(.system(size: 46))
                            VStack(alignment: .leading, spacing: 4) {
                                Text(qa.question)
                                    .font(.kidHeadline(20))
                                    .foregroundStyle(IslandTheme.inkDark)
                                Text(qa.shortAnswer)
                                    .font(.kidCaption(15))
                                    .foregroundStyle(IslandTheme.lavenderDark)
                            }
                            Spacer()
                            Button {
                                speech.speak("\(qa.question)。\(qa.shortAnswer)。\(qa.kidExplanation)", language: .chinese)
                            } label: {
                                Image(systemName: "speaker.wave.2.fill")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(.white)
                                    .frame(width: 42, height: 42)
                                    .background(Circle().fill(IslandTheme.lavender))
                            }
                            .buttonStyle(.plain)
                        }

                        Text(qa.kidExplanation)
                            .font(.kidBody(16))
                            .foregroundStyle(IslandTheme.inkDark)
                            .lineSpacing(5)

                        HStack(alignment: .top, spacing: 8) {
                            Text("🧪")
                            Text("亲子小互动：\(qa.funActivity)")
                                .font(.kidCaption(14))
                                .foregroundStyle(IslandTheme.mintDark)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color(hex: "E9FBF2")))

                        if let note = whyStatusNote {
                            Text(note)
                                .font(.kidCaption(12))
                                .foregroundStyle(IslandTheme.inkSoft)
                        }
                    }
                }
            }

            // Category Pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(WhyCategory.allCases) { cat in
                        let active = cat == selectedWhyCategory
                        Button {
                            sound.play(.tap)
                            selectedWhyCategory = cat
                        } label: {
                            HStack(spacing: 5) {
                                Text(cat.emoji)
                                Text(cat.rawValue)
                                    .font(.kidCaption(14))
                            }
                            .foregroundStyle(active ? .white : IslandTheme.inkDark)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 9)
                            .background(Capsule().fill(active ? IslandTheme.lavender : Color.white))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            // Curated Questions List
            VStack(spacing: 10) {
                ForEach(StoryCatalog.qas(for: selectedWhyCategory)) { item in
                    Button {
                        sound.play(.tap)
                        selectedQA = item
                        whyStatusNote = "来自小芽岛精选十万个为什么"
                        if store.state.profile.autoSpeak {
                            speech.speak("\(item.question)。\(item.shortAnswer)。\(item.kidExplanation)", language: .chinese)
                        }
                        store.awardStars(1, category: .story, toast: "好奇宝宝爱提问！+1⭐")
                    } label: {
                        HStack(spacing: 12) {
                            Text(item.emoji)
                                .font(.system(size: 32))
                                .frame(width: 50, height: 50)
                                .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color(hex: "F4EEFF")))
                            VStack(alignment: .leading, spacing: 3) {
                                Text(item.question)
                                    .font(.kidHeadline(16))
                                    .foregroundStyle(IslandTheme.inkDark)
                                Text(item.shortAnswer)
                                    .font(.kidCaption(13))
                                    .foregroundStyle(IslandTheme.inkSoft)
                                    .lineLimit(1)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(IslandTheme.lavender)
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(Color.white)
                                .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).strokeBorder(IslandTheme.borderSoft, lineWidth: 1.5))
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func submitWhyQuestion() {
        let q = questionInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return }
        sound.play(.tap)
        isAskingWhy = true
        let settings = store.state.aiSettings
        let age = store.state.profile.age
        let apiKey = KeychainHelper.loadAPIKey()

        Task {
            let outcome = await aiService.askWhy(question: q, childAge: age, settings: settings, apiKey: apiKey)
            await MainActor.run {
                isAskingWhy = false
                selectedQA = outcome.value
                whyStatusNote = outcome.statusNote
                store.awardStars(1, category: .story, toast: "好奇小探索 +1⭐")
                if store.state.profile.autoSpeak {
                    speech.speak("\(outcome.value.shortAnswer)。\(outcome.value.kidExplanation)", language: .chinese)
                }
            }
        }
    }
}

// MARK: - Interactive Fullscreen Picture Book Reader

struct StoryReaderView: View {
    @Environment(AppStore.self) private var store
    @Environment(SpeechService.self) private var speech
    @Environment(SoundEffectService.self) private var sound

    let book: StoryBook
    let onClose: () -> Void

    @State private var pageIndex: Int = 0
    @State private var pickedChoiceByPage: [String: StoryChoice] = [:]
    @State private var confettiTrigger: Int = 0
    @State private var finishedRewardClaimed: Bool = false

    private var currentPage: StoryPage {
        book.pages[min(pageIndex, max(0, book.pages.count - 1))]
    }

    private var isLastPage: Bool {
        pageIndex >= book.pages.count - 1
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: currentPage.gradientHexes.map { Color(hex: $0) },
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.45), value: pageIndex)

            VStack(spacing: 18) {
                // Reader Top Bar
                HStack {
                    Button {
                        speech.stopSpeaking()
                        onClose()
                    } label: {
                        Label("合上绘本", systemImage: "xmark")
                            .font(.kidCaption(15))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 9)
                            .background(Capsule().fill(Color.black.opacity(0.25)))
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Text("《\(book.title)》 · \(pageIndex + 1)/\(book.pages.count)")
                        .font(.kidCaption(15))
                        .foregroundStyle(.white.opacity(0.95))

                    Spacer()

                    Button {
                        speakCurrentPage()
                    } label: {
                        Image(systemName: speech.isSpeaking ? "speaker.wave.3.fill" : "speaker.wave.2.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 42, height: 42)
                            .background(Circle().fill(Color.black.opacity(0.25)))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 18)
                .padding(.top, 10)

                Spacer(minLength: 4)

                // Storybook Illustration Stage
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.18))
                        .frame(width: 210, height: 210)
                    HStack(spacing: 12) {
                        Text(currentPage.sceneEmoji)
                            .font(.system(size: 98))
                        Text(currentPage.secondaryEmoji)
                            .font(.system(size: 56))
                            .offset(y: -26)
                    }
                }
                .id(currentPage.id)
                .transition(.scale.combined(with: .opacity))

                // Narration Card
                ToyCard(background: Color.white.opacity(0.96), cornerRadius: 30, padding: 22) {
                    VStack(alignment: .leading, spacing: 14) {
                        Text(currentPage.title)
                            .font(.kidTitle(24))
                            .foregroundStyle(IslandTheme.inkDark)

                        Text(currentPage.narration)
                            .font(.kidBody(19))
                            .foregroundStyle(IslandTheme.inkDark)
                            .lineSpacing(6)

                        // Interactive Branching Choices
                        if !currentPage.choices.isEmpty {
                            if let chosen = pickedChoiceByPage[currentPage.id] {
                                HStack(spacing: 10) {
                                    Text(chosen.outcomeEmoji)
                                        .font(.system(size: 36))
                                    Text(chosen.outcomeText)
                                        .font(.kidHeadline(16))
                                        .foregroundStyle(IslandTheme.mintDark)
                                }
                                .padding(14)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Color(hex: "E9FBF2")))
                            } else {
                                VStack(alignment: .leading, spacing: 10) {
                                    if let prompt = currentPage.choicePrompt {
                                        Text("✨ \(prompt)")
                                            .font(.kidCaption(15))
                                            .foregroundStyle(IslandTheme.lavenderDark)
                                    }
                                    ForEach(currentPage.choices) { choice in
                                        Button {
                                            sound.play(.star)
                                            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                                pickedChoiceByPage[currentPage.id] = choice
                                            }
                                            speech.speak(choice.outcomeText, language: .chinese)
                                        } label: {
                                            HStack(spacing: 10) {
                                                Text(choice.emoji)
                                                    .font(.system(size: 24))
                                                Text(choice.label)
                                                    .font(.kidHeadline(16))
                                                    .foregroundStyle(.white)
                                                Spacer()
                                            }
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 12)
                                        }
                                        .buttonStyle(ToyButtonStyle(fill: IslandTheme.lavender, shadow: IslandTheme.lavenderDark, cornerRadius: 18))
                                    }
                                }
                            }
                        }

                        if isLastPage {
                            HStack(spacing: 8) {
                                Text("💛")
                                Text(book.moral)
                                    .font(.kidCaption(15))
                                    .foregroundStyle(IslandTheme.amberDark)
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color(hex: "FFF9E6")))
                        }
                    }
                }
                .padding(.horizontal, 18)

                // Navigation Controls
                HStack(spacing: 14) {
                    if pageIndex > 0 {
                        Button {
                            sound.play(.tap)
                            withAnimation { pageIndex -= 1 }
                            if store.state.profile.autoSpeak { speakCurrentPage() }
                        } label: {
                            Text("← 上一页")
                                .font(.kidHeadline(17))
                                .foregroundStyle(IslandTheme.inkDark)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 14)
                        }
                        .buttonStyle(ToyButtonStyle(fill: .white, shadow: Color.black.opacity(0.2)))
                    }

                    Spacer()

                    Button {
                        if isLastPage {
                            if !finishedRewardClaimed {
                                finishedRewardClaimed = true
                                sound.play(.celebration)
                                confettiTrigger += 1
                                store.markStoryRead(book)
                                speech.speak("故事讲完啦！你真棒！", language: .chinese)
                                Task { @MainActor in
                                    try? await Task.sleep(for: .seconds(1.2))
                                    onClose()
                                }
                            } else {
                                onClose()
                            }
                        } else {
                            sound.play(.tap)
                            withAnimation { pageIndex += 1 }
                            if store.state.profile.autoSpeak { speakCurrentPage() }
                        }
                    } label: {
                        Text(isLastPage ? "读完领星星 ⭐" : "翻下一页 →")
                            .font(.kidHeadline(18))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 26)
                            .padding(.vertical, 14)
                    }
                    .buttonStyle(ToyButtonStyle(fill: isLastPage ? IslandTheme.amber : IslandTheme.mint, shadow: isLastPage ? IslandTheme.amberDark : IslandTheme.mintDark))
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 18)
            }

            ConfettiBurstView(trigger: confettiTrigger)
        }
        .onAppear {
            if store.state.profile.autoSpeak {
                speakCurrentPage()
            }
        }
        .onDisappear {
            speech.stopSpeaking()
        }
    }

    private func speakCurrentPage() {
        speech.speak("\(currentPage.title)。\(currentPage.narration)", language: .chinese, rate: 0.44)
    }
}

// MARK: - AI / Offline Story Creator Sheet

struct AIStoryCreatorSheet: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @Environment(SoundEffectService.self) private var sound

    let onCreated: (StoryBook) -> Void

    @State private var heroIndex: Int = 0
    @State private var settingIndex: Int = 0
    @State private var lessonIndex: Int = 0
    @State private var isGenerating: Bool = false
    @State private var statusMessage: String?

    private let aiService = AIService()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("选一选故事主角、地方和魔法主题，立刻为「\(store.state.profile.name)」变出一本新绘本！")
                        .font(.kidBody(16))
                        .foregroundStyle(IslandTheme.inkSoft)

                    sectionTitle("1. 故事主角是谁？")
                    chipGrid(items: StoryCatalog.heroOptions.map { "\($0.emoji) \($0.name)" }, selectedIndex: $heroIndex, color: IslandTheme.lavender)

                    sectionTitle("2. 故事发生在哪里？")
                    chipGrid(items: StoryCatalog.settingOptions.map { "\($0.emoji) \($0.name)" }, selectedIndex: $settingIndex, color: IslandTheme.lagoon)

                    sectionTitle("3. 想学什么小本领？")
                    chipGrid(items: StoryCatalog.lessonOptions, selectedIndex: $lessonIndex, color: IslandTheme.mint)

                    if let statusMessage {
                        Text(statusMessage)
                            .font(.kidCaption(14))
                            .foregroundStyle(IslandTheme.lavenderDark)
                    }

                    Button {
                        generateStory()
                    } label: {
                        HStack(spacing: 8) {
                            if isGenerating {
                                ProgressView().tint(.white)
                                Text("正在施展童话魔法...")
                            } else {
                                Text("🪄 开始变出专属绘本！")
                            }
                        }
                        .font(.kidHeadline(19))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                    }
                    .buttonStyle(ToyButtonStyle(fill: IslandTheme.lavender, shadow: IslandTheme.lavenderDark))
                    .disabled(isGenerating)
                }
                .padding(20)
            }
            .background(IslandTheme.creamCanvas.ignoresSafeArea())
            .navigationTitle("魔法绘本机")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") { dismiss() }
                }
            }
        }
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.kidHeadline(18))
            .foregroundStyle(IslandTheme.inkDark)
    }

    private func chipGrid(items: [String], selectedIndex: Binding<Int>, color: Color) -> some View {
        let cols = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]
        return LazyVGrid(columns: cols, spacing: 10) {
            ForEach(Array(items.enumerated()), id: \.offset) { idx, label in
                let active = selectedIndex.wrappedValue == idx
                Button {
                    sound.play(.tap)
                    selectedIndex.wrappedValue = idx
                } label: {
                    Text(label)
                        .font(.kidHeadline(15))
                        .foregroundStyle(active ? .white : IslandTheme.inkDark)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .padding(.horizontal, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(active ? color : Color.white)
                                .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).strokeBorder(active ? color : IslandTheme.borderSoft, lineWidth: 1.5))
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func generateStory() {
        sound.play(.star)
        isGenerating = true
        statusMessage = store.state.aiSettings.isEnabled ? "正在请 AI 童话作家创作绘本..." : "正在拼装专属互动绘本..."
        let hero = StoryCatalog.heroOptions[heroIndex]
        let setting = StoryCatalog.settingOptions[settingIndex]
        let request = StoryCreationRequest(
            hero: hero.name,
            heroEmoji: hero.emoji,
            setting: setting.name,
            settingEmoji: setting.emoji,
            lesson: StoryCatalog.lessonOptions[lessonIndex],
            childName: store.state.profile.name
        )
        let settings = store.state.aiSettings
        let apiKey = KeychainHelper.loadAPIKey()

        Task {
            let outcome = await aiService.generatePictureBook(request: request, settings: settings, apiKey: apiKey)
            await MainActor.run {
                isGenerating = false
                statusMessage = outcome.statusNote
                onCreated(outcome.value)
            }
        }
    }
}
