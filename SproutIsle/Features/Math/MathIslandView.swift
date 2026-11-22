import SwiftUI

struct MathIslandView: View {
    @Environment(AppStore.self) private var store
    @Environment(SpeechService.self) private var speech
    @Environment(SoundEffectService.self) private var sound

    let onBack: () -> Void

    @State private var modeId: String = "counting"
    @State private var difficulty: MathDifficulty = .sprout
    @State private var confettiTrigger: Int = 0

    // Counting state
    @State private var countingQ: CountingQuestion = MathProblemGenerator.makeCountingQuestion(difficulty: .sprout)
    @State private var tappedIndices: [Int] = []
    @State private var countingSolved: Bool = false
    @State private var countingWrongNumber: Int?

    // Arithmetic state
    @State private var arithmeticQ: ArithmeticQuestion = MathProblemGenerator.makeArithmeticQuestion(difficulty: .sprout)
    @State private var arithmeticSolved: Bool = false
    @State private var arithmeticWrongNumber: Int?
    @State private var mathCombo: Int = 0

    // Pattern state
    @State private var patternQ: PatternQuestion = MathProblemGenerator.makePatternQuestion(difficulty: .sprout)
    @State private var patternSolved: Bool = false
    @State private var patternWrongId: String?

    private let modes = [
        ModeTabOption(id: "counting", title: "数数野餐", emoji: "🍎"),
        ModeTabOption(id: "arithmetic", title: "趣味口算", emoji: "➕"),
        ModeTabOption(id: "patterns", title: "图形规律", emoji: "🔷"),
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "FFF7DB"), IslandTheme.creamCanvas],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 12) {
                IslandHeaderBar(
                    destination: .math,
                    starCount: store.state.totalStars,
                    onBack: onBack,
                    onSpeakTip: { speakCurrentPrompt() }
                )

                ModePillBar(options: modes, selectedId: $modeId, accentColor: IslandTheme.amber) {
                    sound.play(.tap)
                }

                // Difficulty selector
                HStack(spacing: 8) {
                    ForEach(MathDifficulty.allCases) { level in
                        let active = level == difficulty
                        Button {
                            sound.play(.tap)
                            difficulty = level
                            regenerateAllForDifficulty()
                        } label: {
                            Text(level.title)
                                .font(.kidCaption(14))
                                .foregroundStyle(active ? .white : IslandTheme.inkDark)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 7)
                                .background(
                                    Capsule()
                                        .fill(active ? IslandTheme.amberDark : Color.white)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                    Spacer()
                    if mathCombo > 1 {
                        Text("🔥 连对 \(mathCombo)")
                            .font(.kidCaption(14))
                            .foregroundStyle(IslandTheme.coralDark)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(Color(hex: "FFE8E8")))
                    }
                }
                .padding(.horizontal, 16)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        switch modeId {
                        case "counting":
                            countingSection
                        case "arithmetic":
                            arithmeticSection
                        default:
                            patternSection
                        }
                        Spacer(minLength: 28)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 4)
                }
            }

            ConfettiBurstView(trigger: confettiTrigger)
        }
    }

    // MARK: - Mode 1: Counting Picnic

    private var countingSection: some View {
        VStack(spacing: 16) {
            ToyCard(cornerRadius: 28, padding: 20) {
                VStack(spacing: 14) {
                    HStack {
                        Text("点一点\(countingQ.theme.name)一起数一数！")
                            .font(.kidHeadline(19))
                            .foregroundStyle(IslandTheme.inkDark)
                        Spacer()
                        Text("已数 \(tappedIndices.count)")
                            .font(.kidCaption(15))
                            .foregroundStyle(IslandTheme.amberDark)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 5)
                            .background(Capsule().fill(Color(hex: "FFF3CD")))
                    }

                    // Interactive meadow
                    let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: min(5, max(3, countingQ.count)))
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(0..<countingQ.count, id: \.self) { index in
                            let order = tappedIndices.firstIndex(of: index).map { $0 + 1 }
                            Button {
                                if order == nil {
                                    sound.play(.tap)
                                    tappedIndices.append(index)
                                    speech.speak("\(tappedIndices.count)", language: .chinese)
                                }
                            } label: {
                                ZStack(alignment: .topTrailing) {
                                    Text(countingQ.theme.emoji)
                                        .font(.system(size: 44))
                                        .scaleEffect(order != nil ? 1.15 : 1.0)
                                        .animation(.spring(response: 0.25, dampingFraction: 0.55), value: order)

                                    if let num = order {
                                        Text("\(num)")
                                            .font(.kidCaption(13))
                                            .foregroundStyle(.white)
                                            .frame(width: 24, height: 24)
                                            .background(Circle().fill(IslandTheme.mint))
                                            .offset(x: 6, y: -6)
                                    }
                                }
                                .frame(width: 60, height: 60)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, minHeight: 165)
                    .background(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(Color(hex: "EEFBF0"))
                    )
                }
            }

            numberOptionGrid(
                options: countingQ.options,
                correct: countingQ.count,
                solved: countingSolved,
                wrongNumber: countingWrongNumber
            ) { picked in
                if picked == countingQ.count {
                    sound.play(.celebration)
                    countingSolved = true
                    mathCombo += 1
                    confettiTrigger += 1
                    store.recordMathResult(isCorrect: true)
                    speech.speakSequence(
                        ["数得真准！一共有", "\(picked)\(countingQ.theme.measureWord)\(countingQ.theme.name)"],
                        language: .chinese
                    )
                } else {
                    sound.play(.tryAgain)
                    mathCombo = 0
                    countingWrongNumber = picked
                    store.recordMathResult(isCorrect: false)
                    speech.speak("再点一点\(countingQ.theme.name)慢慢数哦！", language: .chinese)
                }
            }

            if countingSolved {
                nextRoundButton {
                    countingQ = MathProblemGenerator.makeCountingQuestion(difficulty: difficulty)
                    tappedIndices = []
                    countingSolved = false
                    countingWrongNumber = nil
                    if store.state.profile.autoSpeak {
                        speech.speak(countingQ.spokenPrompt, language: .chinese)
                    }
                }
            }
        }
    }

    // MARK: - Mode 2: Visual Arithmetic

    private var arithmeticSection: some View {
        VStack(spacing: 16) {
            ToyCard(cornerRadius: 28, padding: 20) {
                VStack(spacing: 16) {
                    Text(arithmeticQ.spokenPrompt)
                        .font(.kidBody(16))
                        .foregroundStyle(IslandTheme.inkSoft)
                        .multilineTextAlignment(.center)

                    // Big equation pill
                    HStack(spacing: 12) {
                        equationBadge("\(arithmeticQ.lhs)", color: IslandTheme.lagoon)
                        Text(arithmeticQ.operatorSymbol)
                            .font(.kidTitle(34))
                            .foregroundStyle(IslandTheme.amberDark)
                        equationBadge("\(arithmeticQ.rhs)", color: IslandTheme.coral)
                        Text("=")
                            .font(.kidTitle(34))
                            .foregroundStyle(IslandTheme.inkSoft)
                        equationBadge(arithmeticSolved ? "\(arithmeticQ.answer)" : "?", color: arithmeticSolved ? IslandTheme.mint : IslandTheme.amber)
                    }

                    // Concrete Visual Representation
                    if arithmeticQ.isAddition {
                        HStack(spacing: 12) {
                            visualGroupBox(count: arithmeticQ.lhs, emoji: arithmeticQ.theme.emoji, tint: Color(hex: "E8F6FF"))
                            Text("+")
                                .font(.kidTitle(24))
                                .foregroundStyle(IslandTheme.amberDark)
                            visualGroupBox(count: arithmeticQ.rhs, emoji: arithmeticQ.theme.emoji, tint: Color(hex: "FFF0F0"))
                        }
                    } else {
                        VStack(spacing: 8) {
                            Text("虚线里的表示拿走啦")
                                .font(.kidCaption(13))
                                .foregroundStyle(IslandTheme.inkSoft)
                            let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: min(5, arithmeticQ.lhs))
                            LazyVGrid(columns: columns, spacing: 8) {
                                ForEach(0..<arithmeticQ.lhs, id: \.self) { idx in
                                    let removed = idx >= arithmeticQ.answer
                                    Text(arithmeticQ.theme.emoji)
                                        .font(.system(size: 32))
                                        .opacity(removed ? 0.25 : 1.0)
                                        .overlay {
                                            if removed {
                                                Image(systemName: "xmark")
                                                    .font(.system(size: 20, weight: .bold))
                                                    .foregroundStyle(IslandTheme.coral)
                                            }
                                        }
                                }
                            }
                            .padding(14)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(Color(hex: "FFF8EB"))
                            )
                        }
                    }
                }
            }

            numberOptionGrid(
                options: arithmeticQ.options,
                correct: arithmeticQ.answer,
                solved: arithmeticSolved,
                wrongNumber: arithmeticWrongNumber
            ) { picked in
                if picked == arithmeticQ.answer {
                    sound.play(.celebration)
                    arithmeticSolved = true
                    mathCombo += 1
                    confettiTrigger += 1
                    store.recordMathResult(isCorrect: true)
                    speech.speak("算对啦！答案就是\(picked)！", language: .chinese)
                } else {
                    sound.play(.tryAgain)
                    mathCombo = 0
                    arithmeticWrongNumber = picked
                    store.recordMathResult(isCorrect: false)
                    speech.speak("数一数小图案，再试一次吧！", language: .chinese)
                }
            }

            if arithmeticSolved {
                nextRoundButton {
                    arithmeticQ = MathProblemGenerator.makeArithmeticQuestion(difficulty: difficulty)
                    arithmeticSolved = false
                    arithmeticWrongNumber = nil
                    if store.state.profile.autoSpeak {
                        speech.speakSequence(arithmeticQ.spokenSegments, language: .chinese)
                    }
                }
            }
        }
    }

    // MARK: - Mode 3: Shapes & Pattern Train

    private var patternSection: some View {
        VStack(spacing: 16) {
            ToyCard(cornerRadius: 28, padding: 20) {
                VStack(spacing: 14) {
                    Text("🚂 下一个该排谁呢？")
                        .font(.kidHeadline(20))
                        .foregroundStyle(IslandTheme.inkDark)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(Array(patternQ.sequence.enumerated()), id: \.offset) { _, token in
                                KidShapeBadge(token: token, size: 54)
                            }
                            ZStack {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(patternSolved ? Color(hex: "E9FBF2") : Color(hex: "FFF3CD"))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .strokeBorder(IslandTheme.amber, style: StrokeStyle(lineWidth: 2.5, dash: [6, 4]))
                                    )
                                if patternSolved {
                                    KidShapeView(shape: patternQ.answer.shape, color: Color(hex: patternQ.answer.colorHex))
                                        .frame(width: 34, height: 34)
                                } else {
                                    Text("?")
                                        .font(.kidTitle(28))
                                        .foregroundStyle(IslandTheme.amberDark)
                                }
                            }
                            .frame(width: 56, height: 56)
                        }
                        .padding(.vertical, 4)
                    }

                    if patternSolved {
                        Text("规律：\(patternQ.ruleDescription)")
                            .font(.kidCaption(15))
                            .foregroundStyle(IslandTheme.mintDark)
                    }

                    HStack(spacing: 12) {
                        ForEach(patternQ.options) { option in
                            let isCorrect = option == patternQ.answer
                            let isWrong = patternWrongId == option.id
                            Button {
                                if isCorrect {
                                    sound.play(.celebration)
                                    patternSolved = true
                                    mathCombo += 1
                                    confettiTrigger += 1
                                    store.recordMathResult(isCorrect: true)
                                    speech.speak("找到规律啦！下一个是\(option.colorName)\(option.shape.chineseName)！", language: .chinese)
                                } else {
                                    sound.play(.tryAgain)
                                    mathCombo = 0
                                    patternWrongId = option.id
                                    store.recordMathResult(isCorrect: false)
                                    speech.speak("再仔细看看前面的排队顺序哦！", language: .chinese)
                                }
                            } label: {
                                VStack(spacing: 6) {
                                    KidShapeView(shape: option.shape, color: Color(hex: option.colorHex))
                                        .frame(width: 44, height: 44)
                                    Text(option.shape.chineseName)
                                        .font(.kidCaption(13))
                                        .foregroundStyle(IslandTheme.inkDark)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                                        .fill(isWrong ? Color(hex: "FFE5E5") : (patternSolved && isCorrect ? Color(hex: "E6F8EE") : Color.white))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                                .strokeBorder(patternSolved && isCorrect ? IslandTheme.mint : IslandTheme.borderSoft, lineWidth: 2)
                                        )
                                )
                            }
                            .buttonStyle(.plain)
                            .disabled(patternSolved)
                        }
                    }

                    if patternSolved {
                        nextRoundButton {
                            patternQ = MathProblemGenerator.makePatternQuestion(difficulty: difficulty)
                            patternSolved = false
                            patternWrongId = nil
                        }
                    }
                }
            }

            // Shape Explorer
            ToyCard(cornerRadius: 28, padding: 18) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("✨ 形状好朋友认一认")
                        .font(.kidHeadline(19))
                        .foregroundStyle(IslandTheme.inkDark)

                    let cols = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
                    let colors = ["FF6B6B", "4EA8DE", "FFB703", "34B37E", "FF758F", "9B72CF"]
                    LazyVGrid(columns: cols, spacing: 12) {
                        ForEach(Array(KidShape.allCases.enumerated()), id: \.element.id) { idx, shape in
                            Button {
                                sound.play(.tap)
                                speech.speak("\(shape.chineseName)，\(shape.everydayExample)", language: .chinese)
                            } label: {
                                HStack(spacing: 10) {
                                    KidShapeView(shape: shape, color: Color(hex: colors[idx % colors.count]))
                                        .frame(width: 36, height: 36)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("\(shape.chineseName) \(shape.exampleEmoji)")
                                            .font(.kidHeadline(15))
                                            .foregroundStyle(IslandTheme.inkDark)
                                        Text(shape.everydayExample)
                                            .font(.kidCaption(11))
                                            .foregroundStyle(IslandTheme.inkSoft)
                                            .lineLimit(2)
                                    }
                                    Spacer(minLength: 0)
                                }
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .fill(Color(hex: "FFFDF7"))
                                        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).strokeBorder(IslandTheme.borderSoft, lineWidth: 1.5))
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private func equationBadge(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.kidTitle(28))
            .foregroundStyle(.white)
            .frame(width: 54, height: 54)
            .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(color))
    }

    private func visualGroupBox(count: Int, emoji: String, tint: Color) -> some View {
        let cols = Array(repeating: GridItem(.flexible(), spacing: 4), count: min(4, max(2, count)))
        return LazyVGrid(columns: cols, spacing: 4) {
            ForEach(0..<count, id: \.self) { _ in
                Text(emoji)
                    .font(.system(size: count > 8 ? 20 : 26))
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, minHeight: 88)
        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(tint))
    }

    private func numberOptionGrid(
        options: [Int],
        correct: Int,
        solved: Bool,
        wrongNumber: Int?,
        onSelect: @escaping (Int) -> Void
    ) -> some View {
        let cols = [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]
        return LazyVGrid(columns: cols, spacing: 14) {
            ForEach(options, id: \.self) { num in
                let isCorrectChoice = solved && num == correct
                let isWrongChoice = wrongNumber == num
                let fill: Color = isCorrectChoice ? IslandTheme.mint : (isWrongChoice ? IslandTheme.coral : Color.white)
                let shadow: Color = isCorrectChoice ? IslandTheme.mintDark : (isWrongChoice ? IslandTheme.coralDark : IslandTheme.borderSoft)
                let fg: Color = (isCorrectChoice || isWrongChoice) ? .white : IslandTheme.inkDark

                Button {
                    onSelect(num)
                } label: {
                    Text("\(num)")
                        .font(.kidGiant(38))
                        .foregroundStyle(fg)
                        .frame(maxWidth: .infinity)
                        .frame(height: 82)
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .strokeBorder((isCorrectChoice || isWrongChoice) ? Color.clear : IslandTheme.borderSoft, lineWidth: 2)
                        )
                }
                .buttonStyle(ToyButtonStyle(fill: fill, shadow: shadow, cornerRadius: 22))
                .disabled(solved)
            }
        }
    }

    private func nextRoundButton(action: @escaping () -> Void) -> some View {
        Button {
            sound.play(.tap)
            action()
        } label: {
            Text("下一题 →")
                .font(.kidHeadline(20))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
        }
        .buttonStyle(ToyButtonStyle(fill: IslandTheme.amber, shadow: IslandTheme.amberDark))
    }

    private func regenerateAllForDifficulty() {
        countingQ = MathProblemGenerator.makeCountingQuestion(difficulty: difficulty)
        tappedIndices = []
        countingSolved = false
        countingWrongNumber = nil

        arithmeticQ = MathProblemGenerator.makeArithmeticQuestion(difficulty: difficulty)
        arithmeticSolved = false
        arithmeticWrongNumber = nil

        patternQ = MathProblemGenerator.makePatternQuestion(difficulty: difficulty)
        patternSolved = false
        patternWrongId = nil
    }

    private func speakCurrentPrompt() {
        switch modeId {
        case "counting": speech.speak(countingQ.spokenPrompt, language: .chinese)
        case "arithmetic": speech.speakSequence(arithmeticQ.spokenSegments, language: .chinese)
        default: speech.speak("看一看前面的图形是怎么排队的，猜猜问号里应该放哪一个呢？", language: .chinese)
        }
    }
}

struct KidShapeBadge: View {
    let token: PatternToken
    var size: CGFloat = 54

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white)
                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(IslandTheme.borderSoft, lineWidth: 1.5))
            KidShapeView(shape: token.shape, color: Color(hex: token.colorHex))
                .frame(width: size * 0.62, height: size * 0.62)
        }
        .frame(width: size, height: size)
    }
}

struct KidShapeView: View {
    let shape: KidShape
    let color: Color

    var body: some View {
        switch shape {
        case .circle:
            Circle().fill(color)
        case .square:
            RoundedRectangle(cornerRadius: 8, style: .continuous).fill(color)
        case .triangle:
            TriangleShape().fill(color)
        case .star:
            Image(systemName: "star.fill")
                .resizable()
                .scaledToFit()
                .foregroundStyle(color)
        case .heart:
            Image(systemName: "heart.fill")
                .resizable()
                .scaledToFit()
                .foregroundStyle(color)
        case .diamond:
            DiamondShape().fill(color)
        }
    }
}

private struct TriangleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

private struct DiamondShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.closeSubpath()
        return path
    }
}
