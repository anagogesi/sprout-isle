import SwiftUI

struct WordQuizView: View {
    @Environment(AppStore.self) private var store
    @Environment(SpeechService.self) private var speech
    @Environment(SoundEffectService.self) private var sound

    @State private var question: WordQuizQuestion = LiteracyCatalog.makeQuizQuestion()
    @State private var selectedId: String?
    @State private var isAnsweredCorrectly: Bool = false
    @State private var wrongShakeId: String?
    @State private var streak: Int = 0
    @State private var confettiTrigger: Int = 0

    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    ToyCard(cornerRadius: 28, padding: 20) {
                        VStack(spacing: 14) {
                            HStack {
                                Label("连对 \(streak) 题", systemImage: "flame.fill")
                                    .font(.kidCaption(14))
                                    .foregroundStyle(IslandTheme.coralDark)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Capsule().fill(Color(hex: "FFE8E8")))
                                Spacer()
                                Button {
                                    speech.speak(question.spokenPrompt, language: .chinese)
                                } label: {
                                    Label("再听题目", systemImage: "speaker.wave.2.fill")
                                        .font(.kidCaption(14))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 7)
                                        .background(Capsule().fill(IslandTheme.lagoon))
                                }
                                .buttonStyle(.plain)
                            }

                            Text(question.targetHanzi.emoji)
                                .font(.system(size: 64))

                            Text(question.prompt)
                                .font(.kidHeadline(22))
                                .foregroundStyle(IslandTheme.inkDark)

                            Text(isAnsweredCorrectly ? (question.targetHanzi.words.first ?? question.targetHanzi.character) : question.wordHint)
                                .font(.kidTitle(32))
                                .foregroundStyle(isAnsweredCorrectly ? IslandTheme.mintDark : IslandTheme.amberDark)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .fill(Color(hex: "FFF9E6"))
                                )
                        }
                    }

                    let columns = [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(question.options) { option in
                            optionButton(option)
                        }
                    }

                    if isAnsweredCorrectly {
                        Button {
                            nextQuestion()
                        } label: {
                            Text("太棒啦！下一题 →")
                                .font(.kidHeadline(20))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                        }
                        .buttonStyle(ToyButtonStyle(fill: IslandTheme.mint, shadow: IslandTheme.mintDark))
                        .transition(.scale.combined(with: .opacity))
                    }

                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 16)
                .padding(.top, 4)
            }

            ConfettiBurstView(trigger: confettiTrigger)
        }
        .onAppear {
            if store.state.profile.autoSpeak {
                speech.speak(question.spokenPrompt, language: .chinese)
            }
        }
    }

    private func optionButton(_ option: HanziCard) -> some View {
        let isCorrect = option.id == question.targetHanzi.id
        let isPicked = selectedId == option.id
        let fill: Color = {
            if isAnsweredCorrectly && isCorrect { return IslandTheme.mint }
            if wrongShakeId == option.id { return IslandTheme.coral }
            return Color.white
        }()
        let shadow: Color = {
            if isAnsweredCorrectly && isCorrect { return IslandTheme.mintDark }
            if wrongShakeId == option.id { return IslandTheme.coralDark }
            return IslandTheme.borderSoft
        }()
        let textColor: Color = (isAnsweredCorrectly && isCorrect) || wrongShakeId == option.id ? .white : IslandTheme.inkDark

        return Button {
            handleSelection(option)
        } label: {
            VStack(spacing: 4) {
                Text(option.character)
                    .font(.kidGiant(50))
                Text(option.pinyin)
                    .font(.kidCaption(16))
                    .opacity(0.85)
            }
            .foregroundStyle(textColor)
            .frame(maxWidth: .infinity)
            .frame(height: 118)
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(isPicked ? Color.clear : IslandTheme.borderSoft, lineWidth: 2)
            )
        }
        .buttonStyle(ToyButtonStyle(fill: fill, shadow: shadow, cornerRadius: 22))
        .disabled(isAnsweredCorrectly)
    }

    private func handleSelection(_ option: HanziCard) {
        selectedId = option.id
        if option.id == question.targetHanzi.id {
            sound.play(.celebration)
            withAnimation(.spring(response: 0.32, dampingFraction: 0.7)) {
                isAnsweredCorrectly = true
                streak += 1
                confettiTrigger += 1
            }
            _ = store.markHanziMastered(option)
            speech.speak("答对啦！这是\(option.character)！", language: .chinese)
        } else {
            sound.play(.tryAgain)
            streak = 0
            wrongShakeId = option.id
            speech.speak("那是\(option.character)，再找一找哦！", language: .chinese)
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(0.8))
                if wrongShakeId == option.id {
                    wrongShakeId = nil
                }
            }
        }
    }

    private func nextQuestion() {
        sound.play(.tap)
        let lastId = question.targetHanzi.id
        question = LiteracyCatalog.makeQuizQuestion(excluding: lastId)
        selectedId = nil
        wrongShakeId = nil
        isAnsweredCorrectly = false
        if store.state.profile.autoSpeak {
            speech.speak(question.spokenPrompt, language: .chinese)
        }
    }
}
