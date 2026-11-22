import SwiftUI

@main
struct SproutIsleApp: App {
    @State private var store = AppStore()
    @State private var parentVoices = ParentVoiceStore()
    @State private var speech = SpeechService()
    @State private var sound = SoundEffectService()
    @State private var eyeCare = EyeCareTimerService()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(store)
                .environment(parentVoices)
                .environment(speech)
                .environment(sound)
                .environment(eyeCare)
                .preferredColorScheme(.light)
                .onAppear {
                    speech.configure(parentVoiceStore: parentVoices) {
                        store.state.ttsSettings
                    }
                    sound.isEnabled = store.state.profile.soundEffectsEnabled
                    eyeCare.startMonitoring {
                        store.state.profile.eyeCareMinutes
                    }
                }
                .onChange(of: store.state.profile.soundEffectsEnabled) { _, newValue in
                    sound.isEnabled = newValue
                }
        }
    }
}
