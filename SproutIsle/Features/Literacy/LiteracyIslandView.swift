import SwiftUI

struct LiteracyIslandView: View {
    @Environment(AppStore.self) private var store
    @Environment(SpeechService.self) private var speech
    @Environment(SoundEffectService.self) private var sound

    let onBack: () -> Void

    @State private var modeId: String = "hanzi"
    @State private var selectedCategory: HanziCategory = .nature
    @State private var selectedCardIndex: Int = 0
    @State private var showTracingPad: Bool = false
    @State private var confettiTrigger: Int = 0

    private let modes = [
        ModeTabOption(id: "hanzi", title: "识字卡片", emoji: "📖"),
        ModeTabOption(id: "pinyin", title: "拼音乐园", emoji: "🚂"),
        ModeTabOption(id: "quiz", title: "组词闯关", emoji: "🎯"),
    ]

    private var categoryCards: [HanziCard] {
        LiteracyCatalog.cards(for: selectedCategory)
    }

    private var currentCard: HanziCard {
        categoryCards[min(selectedCardIndex, max(0, categoryCards.count - 1))]
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "E9FBF2"), IslandTheme.creamCanvas],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 12) {
                IslandHeaderBar(
                    destination: .literacy,
                    starCount: store.state.totalStars,
                    onBack: onBack,
                    onSpeakTip: {
                        speech.speak(currentModeTip, language: .chinese)
                    }
                )

                ModePillBar(options: modes, selectedId: $modeId, accentColor: IslandTheme.mint) {
                    sound.play(.tap)
                }

                switch modeId {
                case "hanzi":
                    hanziExplorerView
                case "pinyin":
                    PinyinParkView()
                default:
                    WordQuizView()
                }
            }

            ConfettiBurstView(trigger: confettiTrigger)
        }
    }

    private var currentModeTip: String {
        switch modeId {
        case "hanzi":
            return "点一点汉字卡片听读音，还可以打开描红画板用手指写一写哦！"
        case "pinyin":
            return "点一点声调滑梯，再把声母和韵母小火车拼在一起吧！"
        default:
            return "听声音，找出组成词语的正确汉字！"
        }
    }

    private var hanziExplorerView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                // Category picker
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(HanziCategory.allCases) { category in
                            let isSelected = category == selectedCategory
                            Button {
                                sound.play(.tap)
                                selectedCategory = category
                                selectedCardIndex = 0
                                showTracingPad = false
                            } label: {
                                HStack(spacing: 6) {
                                    Text(category.emoji)
                                    Text(category.rawValue)
                                        .font(.kidCaption(15))
                                }
                                .foregroundStyle(isSelected ? .white : IslandTheme.inkDark)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 9)
                                .background(
                                    Capsule()
                                        .fill(isSelected ? IslandTheme.mint : Color.white)
                                        .overlay(Capsule().strokeBorder(IslandTheme.borderSoft, lineWidth: isSelected ? 0 : 1.5))
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                }

                // Quick character rail
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(Array(categoryCards.enumerated()), id: \.element.id) { idx, card in
                            let isCurrent = idx == selectedCardIndex
                            let isMastered = store.state.masteredHanziIds.contains(card.id)
                            Button {
                                sound.play(.tap)
                                selectedCardIndex = idx
                                if store.state.profile.autoSpeak {
                                    speakCard(card)
                                }
                            } label: {
                                VStack(spacing: 2) {
                                    Text(card.character)
                                        .font(.kidHeadline(22))
                                    Text(isMastered ? "⭐" : card.emoji)
                                        .font(.system(size: 13))
                                }
                                .foregroundStyle(isCurrent ? .white : IslandTheme.inkDark)
                                .frame(width: 56, height: 62)
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(isCurrent ? IslandTheme.mint : Color.white)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                .strokeBorder(isMastered ? IslandTheme.amber : IslandTheme.borderSoft, lineWidth: 2)
                                        )
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                }

                // Main Hanzi Card or Tracing Canvas
                ToyCard(cornerRadius: 30, padding: 20) {
                    VStack(spacing: 16) {
                        HStack {
                            Text(currentCard.pinyin)
                                .font(.kidTitle(28))
                                .foregroundStyle(IslandTheme.mintDark)
                            Spacer()
                            Button {
                                sound.play(.tap)
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                    showTracingPad.toggle()
                                }
                            } label: {
                                Label(showTracingPad ? "看卡片" : "手指描红", systemImage: showTracingPad ? "rectangle.portrait" : "pencil.tip.crop.circle")
                                    .font(.kidCaption(14))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(Capsule().fill(showTracingPad ? IslandTheme.lagoon : IslandTheme.amber))
                            }
                            .buttonStyle(.plain)
                        }

                        if showTracingPad {
                            HanziTracingPad(character: currentCard.character, strokeHint: currentCard.strokeHint) {
                                sound.play(.celebration)
                                confettiTrigger += 1
                                store.awardStars(1, category: .literacy, toast: "写得真棒！「\(currentCard.character)」+1⭐")
                                speech.speak("写得真棒！这就是\(currentCard.character)！", language: .chinese)
                            }
                        } else {
                            HStack(spacing: 20) {
                                MiZiGeBox(character: currentCard.character)
                                    .onTapGesture {
                                        sound.play(.tap)
                                        speakCard(currentCard)
                                    }

                                VStack(alignment: .leading, spacing: 10) {
                                    Text(currentCard.emoji)
                                        .font(.system(size: 56))
                                    Text(currentCard.meaning)
                                        .font(.kidTitle(24))
                                        .foregroundStyle(IslandTheme.inkDark)
                                    Text("笔顺：\(currentCard.strokeHint)")
                                        .font(.kidCaption(13))
                                        .foregroundStyle(IslandTheme.inkSoft)
                                }
                            }

                            Text(currentCard.mnemonic)
                                .font(.kidBody(16))
                                .foregroundStyle(IslandTheme.inkDark)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(Color(hex: "F1FCF6"))
                                )

                            // Example words
                            HStack(spacing: 10) {
                                ForEach(currentCard.words, id: \.self) { word in
                                    Button {
                                        sound.play(.tap)
                                        speech.speak(word, language: .chinese)
                                    } label: {
                                        Text(word)
                                            .font(.kidHeadline(17))
                                            .foregroundStyle(IslandTheme.mintDark)
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 9)
                                            .background(
                                                Capsule()
                                                    .fill(Color(hex: "E3F9EC"))
                                                    .overlay(Capsule().strokeBorder(IslandTheme.mint.opacity(0.4), lineWidth: 1.5))
                                            )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }

                            Text("“\(currentCard.sentence)”")
                                .font(.kidBody(15))
                                .foregroundStyle(IslandTheme.inkSoft)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        // Action Buttons
                        HStack(spacing: 12) {
                            Button {
                                sound.play(.tap)
                                speakCard(currentCard)
                            } label: {
                                Label("听一听", systemImage: "speaker.wave.3.fill")
                                    .font(.kidHeadline(17))
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                            }
                            .buttonStyle(ToyButtonStyle(fill: IslandTheme.lagoon, shadow: IslandTheme.lagoonDark))

                            Button {
                                sound.play(.celebration)
                                confettiTrigger += 1
                                _ = store.markHanziMastered(currentCard)
                                speech.speak("太棒啦！你学会了\(currentCard.character)！", language: .chinese)
                            } label: {
                                let mastered = store.state.masteredHanziIds.contains(currentCard.id)
                                Label(mastered ? "再复习 +⭐" : "我学会啦 ⭐", systemImage: "star.fill")
                                    .font(.kidHeadline(17))
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                            }
                            .buttonStyle(ToyButtonStyle(fill: IslandTheme.mint, shadow: IslandTheme.mintDark))
                        }

                        // Prev / Next navigation
                        HStack {
                            Button {
                                sound.play(.tap)
                                selectedCardIndex = (selectedCardIndex - 1 + categoryCards.count) % categoryCards.count
                                if store.state.profile.autoSpeak { speakCard(currentCard) }
                            } label: {
                                Label("上一个", systemImage: "arrow.left")
                                    .font(.kidCaption(15))
                                    .foregroundStyle(IslandTheme.inkDark)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(Capsule().fill(Color(hex: "F3F4F6")))
                            }
                            .buttonStyle(.plain)

                            Spacer()
                            Text("\(selectedCardIndex + 1) / \(categoryCards.count)")
                                .font(.kidCaption(14))
                                .foregroundStyle(IslandTheme.inkSoft)
                            Spacer()

                            Button {
                                sound.play(.tap)
                                selectedCardIndex = (selectedCardIndex + 1) % categoryCards.count
                                if store.state.profile.autoSpeak { speakCard(currentCard) }
                            } label: {
                                Label("下一个", systemImage: "arrow.right")
                                    .font(.kidCaption(15))
                                    .foregroundStyle(IslandTheme.inkDark)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(Capsule().fill(Color(hex: "F3F4F6")))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, 16)
                Spacer(minLength: 24)
            }
            .padding(.top, 4)
        }
    }

    private func speakCard(_ card: HanziCard) {
        speech.speak("\(card.character)。\(card.words.first ?? card.meaning)。\(card.mnemonic)", language: .chinese)
    }
}

struct MiZiGeBox: View {
    let character: String
    var size: CGFloat = 148

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(hex: "FFFDF7"))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .strokeBorder(IslandTheme.coral.opacity(0.55), lineWidth: 3)
                )

            // Dashed cross & diagonals
            Path { path in
                path.move(to: CGPoint(x: size / 2, y: 8))
                path.addLine(to: CGPoint(x: size / 2, y: size - 8))
                path.move(to: CGPoint(x: 8, y: size / 2))
                path.addLine(to: CGPoint(x: size - 8, y: size / 2))
                path.move(to: CGPoint(x: 12, y: 12))
                path.addLine(to: CGPoint(x: size - 12, y: size - 12))
                path.move(to: CGPoint(x: size - 12, y: 12))
                path.addLine(to: CGPoint(x: 12, y: size - 12))
            }
            .stroke(IslandTheme.coral.opacity(0.25), style: StrokeStyle(lineWidth: 1.5, dash: [5, 5]))

            Text(character)
                .font(.system(size: size * 0.64, weight: .bold, design: .rounded))
                .foregroundStyle(IslandTheme.inkDark)
        }
        .frame(width: size, height: size)
    }
}

struct HanziTracingPad: View {
    let character: String
    let strokeHint: String
    let onCelebrate: () -> Void

    @State private var strokes: [(points: [CGPoint], color: Color)] = []
    @State private var currentPoints: [CGPoint] = []
    @State private var selectedColor: Color = IslandTheme.mint

    private let crayonColors: [Color] = [
        IslandTheme.mint,
        IslandTheme.coral,
        IslandTheme.lagoon,
        IslandTheme.amber,
        IslandTheme.lavender,
    ]

    var body: some View {
        VStack(spacing: 12) {
            Text("跟着虚线用手指描一描 · \(strokeHint)")
                .font(.kidCaption(14))
                .foregroundStyle(IslandTheme.inkSoft)

            ZStack {
                MiZiGeBox(character: character, size: 220)
                    .opacity(0.32)

                Canvas { context, _ in
                    for stroke in strokes {
                        drawPath(points: stroke.points, color: stroke.color, in: &context)
                    }
                    drawPath(points: currentPoints, color: selectedColor, in: &context)
                }
                .frame(width: 220, height: 220)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let clamped = CGPoint(
                                x: min(215, max(5, value.location.x)),
                                y: min(215, max(5, value.location.y))
                            )
                            currentPoints.append(clamped)
                        }
                        .onEnded { _ in
                            if !currentPoints.isEmpty {
                                strokes.append((points: currentPoints, color: selectedColor))
                                currentPoints = []
                            }
                        }
                )
            }
            .frame(width: 220, height: 220)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(IslandTheme.mint.opacity(0.6), lineWidth: 2.5)
            )

            HStack(spacing: 12) {
                ForEach(Array(crayonColors.enumerated()), id: \.offset) { _, color in
                    Circle()
                        .fill(color)
                        .frame(width: 30, height: 30)
                        .overlay(
                            Circle()
                                .strokeBorder(Color.white, lineWidth: selectedColor == color ? 3 : 0)
                        )
                        .scaleEffect(selectedColor == color ? 1.18 : 1.0)
                        .onTapGesture {
                            selectedColor = color
                        }
                }

                Spacer()

                Button("重写") {
                    strokes.removeAll()
                    currentPoints.removeAll()
                }
                .font(.kidCaption(14))
                .foregroundStyle(IslandTheme.inkSoft)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(Capsule().fill(Color(hex: "F3F4F6")))

                Button("写好啦!") {
                    guard !strokes.isEmpty else { return }
                    onCelebrate()
                }
                .font(.kidCaption(14))
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(Capsule().fill(strokes.isEmpty ? Color.gray.opacity(0.4) : IslandTheme.amber))
                .disabled(strokes.isEmpty)
            }
        }
        .onChange(of: character) { _, _ in
            strokes.removeAll()
            currentPoints.removeAll()
        }
    }

    private func drawPath(points: [CGPoint], color: Color, in context: inout GraphicsContext) {
        guard points.count > 1 else { return }
        var path = Path()
        path.move(to: points[0])
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        context.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: 12, lineCap: .round, lineJoin: .round))
    }
}
