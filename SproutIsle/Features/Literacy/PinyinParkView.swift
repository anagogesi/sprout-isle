import SwiftUI

struct PinyinParkView: View {
    @Environment(AppStore.self) private var store
    @Environment(SpeechService.self) private var speech
    @Environment(SoundEffectService.self) private var sound

    @State private var selectedVowel: PinyinItem = LiteracyCatalog.vowels[0]
    @State private var selectedToneIndex: Int = 0
    @State private var blendIndex: Int = 0
    @State private var isCoupled: Bool = false

    private let toneDescriptions = [
        ("一声平", "高高平平像滑道"),
        ("二声扬", "坐上小车往上爬"),
        ("三声拐弯", "先下小坡再上坡"),
        ("四声降", "咻——开心滑下来"),
    ]

    private var currentBlend: PinyinBlend {
        LiteracyCatalog.blendingPairs[blendIndex % LiteracyCatalog.blendingPairs.count]
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                // 1. Tone Rollercoaster
                ToyCard(cornerRadius: 28, padding: 18) {
                    VStack(spacing: 14) {
                        HStack {
                            Text("🎢 韵母四声调滑梯")
                                .font(.kidHeadline(20))
                                .foregroundStyle(IslandTheme.inkDark)
                            Spacer()
                            Text(selectedVowel.emoji + " " + selectedVowel.sampleWord)
                                .font(.kidCaption(14))
                                .foregroundStyle(IslandTheme.mintDark)
                        }

                        // Vowel chips
                        HStack(spacing: 8) {
                            ForEach(LiteracyCatalog.vowels) { vowel in
                                let active = vowel.id == selectedVowel.id
                                Button {
                                    sound.play(.tap)
                                    selectedVowel = vowel
                                    speech.speak(vowel.sampleChar, language: .chinese)
                                } label: {
                                    Text(vowel.symbol)
                                        .font(.kidHeadline(20))
                                        .foregroundStyle(active ? .white : IslandTheme.inkDark)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(
                                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                                .fill(active ? IslandTheme.mint : Color(hex: "F1F5F9"))
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        // Tone Curve Visual
                        ToneCurveView(toneIndex: selectedToneIndex)
                            .frame(height: 82)

                        Text("\(toneDescriptions[selectedToneIndex].0) · \(toneDescriptions[selectedToneIndex].1)")
                            .font(.kidCaption(15))
                            .foregroundStyle(IslandTheme.mintDark)

                        // 4 Tones buttons
                        HStack(spacing: 10) {
                            ForEach(0..<4, id: \.self) { idx in
                                let active = idx == selectedToneIndex
                                Button {
                                    sound.play(.tap)
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedToneIndex = idx
                                    }
                                    speech.speak("\(toneDescriptions[idx].0)，\(selectedVowel.sampleChar)", language: .chinese)
                                } label: {
                                    VStack(spacing: 2) {
                                        Text(selectedVowel.tones[idx])
                                            .font(.kidTitle(26))
                                        Text("\(idx + 1)声")
                                            .font(.kidCaption(12))
                                    }
                                    .foregroundStyle(active ? .white : IslandTheme.inkDark)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .fill(active ? IslandTheme.amber : Color(hex: "FFF9E6"))
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }

                // 2. Blending Train
                ToyCard(cornerRadius: 28, padding: 18) {
                    VStack(spacing: 14) {
                        HStack {
                            Text("🚂 拼读小火车")
                                .font(.kidHeadline(20))
                                .foregroundStyle(IslandTheme.inkDark)
                            Spacer()
                            Button("换一列 ↻") {
                                sound.play(.tap)
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    isCoupled = false
                                    blendIndex = (blendIndex + 1) % LiteracyCatalog.blendingPairs.count
                                }
                            }
                            .font(.kidCaption(14))
                            .foregroundStyle(IslandTheme.lagoonDark)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(Color(hex: "E6F4FC")))
                        }

                        HStack(spacing: isCoupled ? 4 : 24) {
                            trainCar(text: currentBlend.initial, label: "声母", color: IslandTheme.lagoon)
                            if !isCoupled {
                                Text("+")
                                    .font(.kidTitle(26))
                                    .foregroundStyle(IslandTheme.inkSoft)
                            }
                            trainCar(text: currentBlend.finalPart, label: "韵母", color: IslandTheme.amber)
                        }
                        .animation(.spring(response: 0.4, dampingFraction: 0.65), value: isCoupled)

                        if isCoupled {
                            HStack(spacing: 12) {
                                Text(currentBlend.emoji)
                                    .font(.system(size: 42))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("\(currentBlend.combined) → \(currentBlend.character)")
                                        .font(.kidTitle(26))
                                        .foregroundStyle(IslandTheme.mintDark)
                                    Text("组成词语：\(currentBlend.word)")
                                        .font(.kidCaption(15))
                                        .foregroundStyle(IslandTheme.inkSoft)
                                }
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(Color(hex: "E9FBF2"))
                            )
                            .transition(.scale.combined(with: .opacity))
                        }

                        Button {
                            if isCoupled {
                                sound.play(.tap)
                                speech.speak("\(currentBlend.character)，\(currentBlend.word)", language: .chinese)
                            } else {
                                sound.play(.correct)
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.65)) {
                                    isCoupled = true
                                }
                                speech.speak("\(currentBlend.character)，\(currentBlend.word)！拼读成功！", language: .chinese)
                                store.awardStars(1, category: .literacy, toast: "拼出「\(currentBlend.character)」！+1⭐")
                            }
                        } label: {
                            Text(isCoupled ? "🔊 再读一遍「\(currentBlend.word)」" : "🚂 呜呜！拼在一起读一读")
                                .font(.kidHeadline(17))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                        }
                        .buttonStyle(ToyButtonStyle(fill: IslandTheme.mint, shadow: IslandTheme.mintDark))
                    }
                }

                // 3. Initials board
                ToyCard(cornerRadius: 28, padding: 18) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("🎵 常用声母点读墙")
                            .font(.kidHeadline(19))
                            .foregroundStyle(IslandTheme.inkDark)

                        let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 4)
                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(LiteracyCatalog.initials) { item in
                                Button {
                                    sound.play(.tap)
                                    speech.speak("\(item.sampleWord)的\(item.sampleChar)", language: .chinese)
                                } label: {
                                    VStack(spacing: 3) {
                                        Text(item.symbol)
                                            .font(.kidTitle(24))
                                            .foregroundStyle(IslandTheme.lagoonDark)
                                        Text("\(item.emoji) \(item.sampleChar)")
                                            .font(.kidCaption(12))
                                            .foregroundStyle(IslandTheme.inkSoft)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .fill(Color(hex: "F0F9FF"))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                    .strokeBorder(IslandTheme.lagoon.opacity(0.3), lineWidth: 1.5)
                                            )
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }

                Spacer(minLength: 24)
            }
            .padding(.horizontal, 16)
            .padding(.top, 4)
        }
    }

    private func trainCar(text: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.kidCaption(12))
                .foregroundStyle(.white.opacity(0.9))
            Text(text)
                .font(.kidTitle(32))
                .foregroundStyle(.white)
        }
        .frame(width: 96, height: 84)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(color)
                .shadow(color: color.opacity(0.35), radius: 6, y: 4)
        )
    }
}

private struct ToneCurveView: View {
    let toneIndex: Int

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(hex: "F4FBF7"))

                Path { path in
                    switch toneIndex {
                    case 0: // Flat high
                        path.move(to: CGPoint(x: w * 0.14, y: h * 0.30))
                        path.addLine(to: CGPoint(x: w * 0.86, y: h * 0.30))
                    case 1: // Rising
                        path.move(to: CGPoint(x: w * 0.14, y: h * 0.72))
                        path.addQuadCurve(to: CGPoint(x: w * 0.86, y: h * 0.24), control: CGPoint(x: w * 0.55, y: h * 0.58))
                    case 2: // Dipping
                        path.move(to: CGPoint(x: w * 0.14, y: h * 0.42))
                        path.addQuadCurve(to: CGPoint(x: w * 0.50, y: h * 0.78), control: CGPoint(x: w * 0.34, y: h * 0.74))
                        path.addQuadCurve(to: CGPoint(x: w * 0.86, y: h * 0.30), control: CGPoint(x: w * 0.70, y: h * 0.72))
                    default: // Falling
                        path.move(to: CGPoint(x: w * 0.14, y: h * 0.22))
                        path.addQuadCurve(to: CGPoint(x: w * 0.86, y: h * 0.76), control: CGPoint(x: w * 0.50, y: h * 0.40))
                    }
                }
                .stroke(
                    LinearGradient(colors: [IslandTheme.mint, IslandTheme.amber], startPoint: .leading, endPoint: .trailing),
                    style: StrokeStyle(lineWidth: 7, lineCap: .round, lineJoin: .round)
                )
            }
        }
    }
}
