import SwiftUI

struct RootView: View {
    @Environment(AppStore.self) private var store
    @Environment(SpeechService.self) private var speech
    @Environment(EyeCareTimerService.self) private var eyeCare
    @Environment(SoundEffectService.self) private var sound

    @State private var navigationPath: [IslandDestination] = []
    @State private var showParentGate = false
    @State private var showParentCorner = false

    var body: some View {
        ZStack(alignment: .top) {
            NavigationStack(path: $navigationPath) {
                IslandHomeView(
                    onSelectIsland: { destination in
                        sound.play(.tap)
                        navigationPath.append(destination)
                        if store.state.profile.autoSpeak {
                            speech.speak(destination.welcomeSpeech, language: .chinese)
                        }
                    },
                    onOpenParentGate: {
                        sound.play(.tap)
                        showParentGate = true
                    }
                )
                .navigationDestination(for: IslandDestination.self) { destination in
                    islandView(for: destination)
                        .navigationBarBackButtonHidden(true)
                        .toolbar(.hidden, for: .navigationBar)
                }
            }

            if let toast = store.starToastMessage {
                StarToastBanner(message: toast)
                    .padding(.top, 10)
                    .zIndex(50)
            }

            if eyeCare.showBreakOverlay {
                EyeCareOverlayView(countdown: eyeCare.restCountdownSeconds) {
                    sound.play(.star)
                    eyeCare.finishBreak()
                }
                .transition(.opacity)
                .zIndex(100)
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.78), value: store.starToastMessage)
        .animation(.easeInOut(duration: 0.3), value: eyeCare.showBreakOverlay)
        .sheet(isPresented: $showParentGate) {
            ParentGateView {
                showParentGate = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    showParentCorner = true
                }
            }
        }
        .sheet(isPresented: $showParentCorner) {
            ParentCornerView()
        }
    }

    @ViewBuilder
    private func islandView(for destination: IslandDestination) -> some View {
        let goBack: () -> Void = {
            speech.stopSpeaking()
            speech.stopListening()
            sound.play(.tap)
            if !navigationPath.isEmpty {
                navigationPath.removeLast()
            }
        }
        switch destination {
        case .literacy:
            LiteracyIslandView(onBack: goBack)
        case .math:
            MathIslandView(onBack: goBack)
        case .english:
            EnglishIslandView(onBack: goBack)
        case .stories:
            StoryIslandView(onBack: goBack)
        case .habits:
            HabitsAndStickersView(onBack: goBack)
        }
    }
}
