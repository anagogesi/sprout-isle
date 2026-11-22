import SwiftUI

struct EnglishIslandView: View {
    @Environment(AppStore.self) private var store
    @Environment(SpeechService.self) private var speech
    @Environment(SoundEffectService.self) private var sound

    let onBack: () -> Void

    @State private var modeId: String = "phonics"
    @State private var selectedPhonicsIndex: Int = 0
    @State private var selectedCategory: EnglishCategory = .animals
    @State private var selectedWordIndex: Int = 0
    @State private var confettiTrigger: Int = 0

    // Listen & Speak quiz state
    @State private var quizOptions: [EnglishWordCard] = []
    @State private var quizTarget: EnglishWordCard = EnglishCatalog.wordCards[0]
    @State private var quizSolved: Bool = false
    @State private var quizWrongId: String?
    @State private var speakAlongWord: EnglishWordCard = EnglishCatalog.wordCards[0]
    @State private var speakAlongSuccess: Bool = false

    private let modes = [
        ModeTabOption(id: "phonics", title: "ABC 字母", emoji: "🔤"),
        ModeTabOption(id: "words", title: "主题单词", emoji: "🐾"),
        ModeTabOption(id: "play", title: "听音跟读", emoji: "🎤"),
    ]

    private var currentPhonics: PhonicsCard {
        EnglishCatalog.phonicsCards[selectedPhonicsIndex]
    }

    private var categoryWords: [EnglishWordCard] {
        EnglishCatalog.words(for: selectedCategory)
    }

    private var currentWord: EnglishWordCard {
        categoryWords[min(selectedWordIndex, max(0, categoryWords.count - 1))]
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "E4F4FF"), IslandTheme.creamCanvas],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 12) {
                IslandHeaderBar(
                    destination: .english,
                    starCount: store.state.totalStars,
                    onBack: onBack,
                    onSpeakTip: { speakCurrentTip() }
                )

                ModePillBar(options: modes, selectedId: $modeId, accentColor: IslandTheme.lagoon) {
                    sound.play(.tap)
                    speech.stopListening()
                    if modeId == "play" && quizOptions.isEmpty {
                        loadNextListenQuiz(speakNow: store.state.profile.autoSpeak)
                    }
                }

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        switch modeId {
                        case "phonics":
                            phonicsView
                        case "words":
                            vocabularyView
                        default:
                            listenAndSpeakView
                        }
                        Spacer(minLength: 28)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 4)
                }
            }

            ConfettiBurstView(trigger: confettiTrigger)
        }
        .onAppear {
            if quizOptions.isEmpty {
                loadNextListenQuiz(speakNow: false)
            }
        }
        .onDisappear {
            speech.stopListening()
        }
    }

    // MARK: - Mode 1: ABC Phonics

    private var phonicsView: some View {
        VStack(spacing: 16) {
            // A-Z Horizontal Selector
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(EnglishCatalog.phonicsCards.enumerated()), id: \.element.id) { idx, item in
                        let isSelected = idx == selectedPhonicsIndex
                        Button {
                            sound.play(.tap)
                            selectedPhonicsIndex = idx
                            speech.speak("\(item.letter). \(item.word)!", language: .english, rate: 0.42)
                        } label: {
                            Text(item.letter)
                                .font(.kidHeadline(20))
                                .foregroundStyle(isSelected ? .white : IslandTheme.inkDark)
                                .frame(width: 44, height: 48)
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(isSelected ? Color(hex: item.colorHex) : Color.white)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                                .strokeBorder(IslandTheme.borderSoft, lineWidth: isSelected ? 0 : 1.5)
                                        )
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            // Big Phonics Card
            ToyCard(cornerRadius: 30, padding: 22) {
                VStack(spacing: 16) {
                    HStack {
                        Text(currentPhonics.phonicsCue)
                            .font(.kidHeadline(20))
                            .foregroundStyle(Color(hex: currentPhonics.colorHex))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(Color(hex: currentPhonics.colorHex).opacity(0.15)))
                        Spacer()
                        Text("\(selectedPhonicsIndex + 1) / 26")
                            .font(.kidCaption(14))
                            .foregroundStyle(IslandTheme.inkSoft)
                    }

                    HStack(spacing: 20) {
                        Text("\(currentPhonics.letter)\(currentPhonics.lowercase)")
                            .font(.kidGiant(74))
                            .foregroundStyle(Color(hex: currentPhonics.colorHex))

                        VStack(spacing: 6) {
                            Text(currentPhonics.emoji)
                                .font(.system(size: 72))
                            Text(currentPhonics.word)
                                .font(.kidTitle(26))
                                .foregroundStyle(IslandTheme.inkDark)
                            Text(currentPhonics.chinese)
                                .font(.kidCaption(16))
                                .foregroundStyle(IslandTheme.inkSoft)
                        }
                    }
                    .onTapGesture {
                        sound.play(.tap)
                        speech.speak("\(currentPhonics.letter). \(currentPhonics.word). \(currentPhonics.sentence)", language: .english, rate: 0.42)
                    }

                    Text("“\(currentPhonics.sentence)”")
                        .font(.kidBody(17))
                        .foregroundStyle(IslandTheme.inkDark)
                        .multilineTextAlignment(.center)
                        .padding(12)
                        .frame(maxWidth: .infinity)
                        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color(hex: "F0F9FF")))

                    HStack(spacing: 12) {
                        Button {
                            sound.play(.tap)
                            speech.speak("\(currentPhonics.letter), \(currentPhonics.word)! \(currentPhonics.sentence)", language: .english, rate: 0.42)
                        } label: {
                            Label("听英语发音", systemImage: "speaker.wave.3.fill")
                                .font(.kidHeadline(17))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                        }
                        .buttonStyle(ToyButtonStyle(fill: IslandTheme.lagoon, shadow: IslandTheme.lagoonDark))

                        Button {
                            sound.play(.celebration)
                            confettiTrigger += 1
                            _ = store.markEnglishMastered("abc_\(currentPhonics.letter)", label: currentPhonics.word)
                            speech.speak("Great job! \(currentPhonics.letter) is for \(currentPhonics.word)!", language: .english, rate: 0.44)
                        } label: {
                            Label("学会啦 ⭐", systemImage: "star.fill")
                                .font(.kidHeadline(17))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                        }
                        .buttonStyle(ToyButtonStyle(fill: IslandTheme.mint, shadow: IslandTheme.mintDark))
                    }

                    HStack {
                        Button {
                            sound.play(.tap)
                            selectedPhonicsIndex = (selectedPhonicsIndex - 1 + 26) % 26
                            if store.state.profile.autoSpeak {
                                speech.speak("\(currentPhonics.letter), \(currentPhonics.word)", language: .english, rate: 0.42)
                            }
                        } label: {
                            Label("上一个", systemImage: "arrow.left")
                                .font(.kidCaption(15))
                                .foregroundStyle(IslandTheme.inkDark)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Capsule().fill(Color(hex: "F1F5F9")))
                        }
                        .buttonStyle(.plain)

                        Spacer()

                        Button {
                            sound.play(.tap)
                            selectedPhonicsIndex = (selectedPhonicsIndex + 1) % 26
                            if store.state.profile.autoSpeak {
                                speech.speak("\(currentPhonics.letter), \(currentPhonics.word)", language: .english, rate: 0.42)
                            }
                        } label: {
                            Label("下一个", systemImage: "arrow.right")
                                .font(.kidCaption(15))
                                .foregroundStyle(IslandTheme.inkDark)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Capsule().fill(Color(hex: "F1F5F9")))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: - Mode 2: Theme Vocabulary

    private var vocabularyView: some View {
        VStack(spacing: 16) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(EnglishCategory.allCases) { category in
                        let active = category == selectedCategory
                        Button {
                            sound.play(.tap)
                            selectedCategory = category
                            selectedWordIndex = 0
                        } label: {
                            HStack(spacing: 6) {
                                Text(category.emoji)
                                Text(category.rawValue)
                                    .font(.kidCaption(14))
                            }
                            .foregroundStyle(active ? .white : IslandTheme.inkDark)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 9)
                            .background(Capsule().fill(active ? IslandTheme.lagoon : Color.white))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            // Active Word Spotlight Card
            ToyCard(cornerRadius: 30, padding: 20) {
                VStack(spacing: 14) {
                    Text(currentWord.emoji)
                        .font(.system(size: 84))
                        .onTapGesture {
                            sound.play(.tap)
                            speech.speak(currentWord.word, language: .english, rate: 0.42)
                        }

                    Text(currentWord.word)
                        .font(.kidGiant(40))
                        .foregroundStyle(Color(hex: currentWord.accentHex))

                    HStack(spacing: 10) {
                        Text(currentWord.phonetic)
                            .font(.kidBody(16))
                            .foregroundStyle(IslandTheme.inkSoft)
                        Text("·")
                            .foregroundStyle(IslandTheme.inkSoft)
                        Text(currentWord.chinese)
                            .font(.kidHeadline(20))
                            .foregroundStyle(IslandTheme.inkDark)
                    }

                    VStack(spacing: 4) {
                        Text(currentWord.sentence)
                            .font(.kidHeadline(17))
                            .foregroundStyle(IslandTheme.inkDark)
                            .multilineTextAlignment(.center)
                        Text(currentWord.sentenceChinese)
                            .font(.kidCaption(14))
                            .foregroundStyle(IslandTheme.inkSoft)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color(hex: "F0F9FF")))

                    HStack(spacing: 12) {
                        Button {
                            sound.play(.tap)
                            speech.speak("\(currentWord.word). \(currentWord.sentence)", language: .english, rate: 0.42)
                        } label: {
                            Label("听读音", systemImage: "speaker.wave.3.fill")
                                .font(.kidHeadline(17))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                        }
                        .buttonStyle(ToyButtonStyle(fill: IslandTheme.lagoon, shadow: IslandTheme.lagoonDark))

                        Button {
                            sound.play(.celebration)
                            confettiTrigger += 1
                            _ = store.markEnglishMastered(currentWord.id, label: currentWord.word)
                            speech.speak("Wonderful! \(currentWord.word)!", language: .english, rate: 0.44)
                        } label: {
                            Label("记住啦 ⭐", systemImage: "star.fill")
                                .font(.kidHeadline(17))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                        }
                        .buttonStyle(ToyButtonStyle(fill: IslandTheme.amber, shadow: IslandTheme.amberDark))
                    }
                }
            }

            // Word Grid
            let cols = Array(repeating: GridItem(.flexible(), spacing: 10), count: 4)
            LazyVGrid(columns: cols, spacing: 10) {
                ForEach(Array(categoryWords.enumerated()), id: \.element.id) { idx, item in
                    let isSelected = idx == selectedWordIndex
                    let mastered = store.state.masteredEnglishIds.contains(item.id)
                    Button {
                        sound.play(.tap)
                        selectedWordIndex = idx
                        speech.speak(item.word, language: .english, rate: 0.42)
                    } label: {
                        VStack(spacing: 4) {
                            Text(item.emoji)
                                .font(.system(size: 32))
                            Text(item.word)
                                .font(.kidCaption(12))
                                .foregroundStyle(isSelected ? .white : IslandTheme.inkDark)
                                .lineLimit(1)
                                .minimumScaleFactor(0.75)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(isSelected ? IslandTheme.lagoon : Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .strokeBorder(mastered ? IslandTheme.amber : IslandTheme.borderSoft, lineWidth: 2)
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Mode 3: Listen & Speak-Along

    private var listenAndSpeakView: some View {
        VStack(spacing: 16) {
            // Game A: Listen & Find
            ToyCard(cornerRadius: 28, padding: 18) {
                VStack(spacing: 14) {
                    HStack {
                        Text("🎧 听音寻宝")
                            .font(.kidHeadline(20))
                            .foregroundStyle(IslandTheme.inkDark)
                        Spacer()
                        Button {
                            speech.speak("Where is the \(quizTarget.word)? \(quizTarget.word)!", language: .english, rate: 0.41)
                        } label: {
                            Label("播报单词", systemImage: "speaker.wave.2.fill")
                                .font(.kidCaption(14))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .background(Capsule().fill(IslandTheme.lagoon))
                        }
                        .buttonStyle(.plain)
                    }

                    Text("听一听英语，点出对应的卡片吧！")
                        .font(.kidBody(15))
                        .foregroundStyle(IslandTheme.inkSoft)

                    let cols = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
                    LazyVGrid(columns: cols, spacing: 12) {
                        ForEach(quizOptions) { option in
                            let isCorrect = option.id == quizTarget.id
                            let isWrong = quizWrongId == option.id
                            let bg: Color = (quizSolved && isCorrect) ? Color(hex: "E6F8EE") : (isWrong ? Color(hex: "FFE5E5") : Color(hex: "F8FAFC"))
                            let border: Color = (quizSolved && isCorrect) ? IslandTheme.mint : (isWrong ? IslandTheme.coral : IslandTheme.borderSoft)

                            Button {
                                if isCorrect {
                                    sound.play(.celebration)
                                    quizSolved = true
                                    confettiTrigger += 1
                                    _ = store.markEnglishMastered(option.id, label: option.word)
                                    speech.speak("Yes! \(option.word)! Awesome!", language: .english, rate: 0.45)
                                } else {
                                    sound.play(.tryAgain)
                                    quizWrongId = option.id
                                    speech.speak("That is \(option.word). Try again!", language: .english, rate: 0.44)
                                }
                            } label: {
                                VStack(spacing: 6) {
                                    Text(option.emoji)
                                        .font(.system(size: 46))
                                    Text(option.chinese)
                                        .font(.kidHeadline(16))
                                        .foregroundStyle(IslandTheme.inkDark)
                                    if quizSolved && isCorrect {
                                        Text(option.word)
                                            .font(.kidCaption(14))
                                            .foregroundStyle(IslandTheme.mintDark)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                                        .fill(bg)
                                        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).strokeBorder(border, lineWidth: 2))
                                )
                            }
                            .buttonStyle(.plain)
                            .disabled(quizSolved)
                        }
                    }

                    if quizSolved {
                        Button {
                            sound.play(.tap)
                            loadNextListenQuiz(speakNow: true)
                        } label: {
                            Text("下一组词卡 →")
                                .font(.kidHeadline(18))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                        }
                        .buttonStyle(ToyButtonStyle(fill: IslandTheme.lagoon, shadow: IslandTheme.lagoonDark))
                    }
                }
            }

            // Game B: Speak-Along Studio
            ToyCard(cornerRadius: 28, padding: 18) {
                VStack(spacing: 14) {
                    HStack {
                        Text("🎤 开口跟读秀")
                            .font(.kidHeadline(20))
                            .foregroundStyle(IslandTheme.inkDark)
                        Spacer()
                        Button("换一个词 ↻") {
                            sound.play(.tap)
                            speech.stopListening()
                            speakAlongSuccess = false
                            speakAlongWord = EnglishCatalog.wordCards.randomElement() ?? EnglishCatalog.wordCards[0]
                            speech.speak(speakAlongWord.word, language: .english, rate: 0.40)
                        }
                        .font(.kidCaption(14))
                        .foregroundStyle(IslandTheme.lagoonDark)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(Color(hex: "E6F4FC")))
                    }

                    HStack(spacing: 16) {
                        Text(speakAlongWord.emoji)
                            .font(.system(size: 58))
                        VStack(alignment: .leading, spacing: 4) {
                            Text(speakAlongWord.word)
                                .font(.kidTitle(30))
                                .foregroundStyle(IslandTheme.lagoonDark)
                            Text("\(speakAlongWord.phonetic) · \(speakAlongWord.chinese)")
                                .font(.kidCaption(15))
                                .foregroundStyle(IslandTheme.inkSoft)
                        }
                        Spacer()
                        Button {
                            speech.speak(speakAlongWord.word, language: .english, rate: 0.39)
                        } label: {
                            Image(systemName: "speaker.wave.2.fill")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 46, height: 46)
                                .background(Circle().fill(IslandTheme.lagoon))
                        }
                        .buttonStyle(.plain)
                    }

                    if !speech.recognizedTranscript.isEmpty {
                        Text("小耳朵听到：「\(speech.recognizedTranscript)」")
                            .font(.kidCaption(14))
                            .foregroundStyle(IslandTheme.mintDark)
                    }

                    if let notice = speech.recognitionNotice {
                        Text(notice)
                            .font(.kidCaption(13))
                            .foregroundStyle(IslandTheme.inkSoft)
                            .multilineTextAlignment(.center)
                    }

                    HStack(spacing: 12) {
                        Button {
                            if speech.isListening {
                                speech.stopListening()
                            } else {
                                sound.play(.tap)
                                speech.startEnglishListening(expectedWord: speakAlongWord.word) {
                                    celebrateSpeakAlong()
                                }
                            }
                        } label: {
                            Label(speech.isListening ? "正在认真听..." : "麦克风跟读", systemImage: speech.isListening ? "waveform" : "mic.fill")
                                .font(.kidHeadline(16))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                        }
                        .buttonStyle(ToyButtonStyle(fill: speech.isListening ? IslandTheme.coral : IslandTheme.lavender, shadow: speech.isListening ? IslandTheme.coralDark : IslandTheme.lavenderDark))

                        Button {
                            celebrateSpeakAlong()
                        } label: {
                            Label("我读好啦 ⭐", systemImage: "hand.thumbsup.fill")
                                .font(.kidHeadline(16))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                        }
                        .buttonStyle(ToyButtonStyle(fill: IslandTheme.mint, shadow: IslandTheme.mintDark))
                    }

                    if speakAlongSuccess {
                        Text("🌟 发音超级棒！You did great!")
                            .font(.kidHeadline(16))
                            .foregroundStyle(IslandTheme.mintDark)
                    }
                }
            }
        }
    }

    private func celebrateSpeakAlong() {
        sound.play(.celebration)
        confettiTrigger += 1
        speakAlongSuccess = true
        _ = store.markEnglishMastered(speakAlongWord.id, label: speakAlongWord.word)
        speech.speak("Super! \(speakAlongWord.word)! Good job!", language: .english, rate: 0.45)
    }

    private func loadNextListenQuiz(speakNow: Bool) {
        let picks = Array(EnglishCatalog.wordCards.shuffled().prefix(4))
        quizOptions = picks
        quizTarget = picks.randomElement() ?? EnglishCatalog.wordCards[0]
        quizSolved = false
        quizWrongId = nil
        if speakNow {
            speech.speak("Where is the \(quizTarget.word)? \(quizTarget.word)!", language: .english, rate: 0.41)
        }
    }

    private func speakCurrentTip() {
        switch modeId {
        case "phonics": speech.speak("\(currentPhonics.letter) is for \(currentPhonics.word)!", language: .english, rate: 0.42)
        case "words": speech.speak("\(currentWord.word). \(currentWord.sentence)", language: .english, rate: 0.42)
        default: speech.speak("Where is the \(quizTarget.word)?", language: .english, rate: 0.42)
        }
    }
}
