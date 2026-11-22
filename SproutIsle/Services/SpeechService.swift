import AVFoundation
import Foundation
import Observation
import Speech

enum SpeechLanguage: String, Sendable {
    case chinese = "zh-CN"
    case english = "en-US"
}

@MainActor
@Observable
final class SpeechService: NSObject {
    private let synthesizer = AVSpeechSynthesizer()
    var isSpeaking: Bool = false

    // Speech recognition state for English Speak-Along
    var isListening: Bool = false
    var recognizedTranscript: String = ""
    var recognitionNotice: String?

    private var audioEngine: AVAudioEngine?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    func speak(_ text: String, language: SpeechLanguage = .chinese, rate: Float = 0.45, pitch: Float = 1.12, interrupt: Bool = true) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        if interrupt && synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        configurePlaybackSession()

        let utterance = AVSpeechUtterance(string: trimmed)
        utterance.voice = preferredVoice(for: language)
        utterance.rate = rate
        utterance.pitchMultiplier = pitch
        utterance.postUtteranceDelay = 0.08
        isSpeaking = true
        synthesizer.speak(utterance)
    }

    func stopSpeaking() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        isSpeaking = false
    }

    private func preferredVoice(for language: SpeechLanguage) -> AVSpeechSynthesisVoice? {
        let voices = AVSpeechSynthesisVoice.speechVoices().filter {
            $0.language.lowercased().hasPrefix(language.rawValue.prefix(2).lowercased())
        }
        if let exact = voices.first(where: { $0.language == language.rawValue && $0.quality == .enhanced }) {
            return exact
        }
        if let exactDefault = AVSpeechSynthesisVoice(language: language.rawValue) {
            return exactDefault
        }
        return voices.first
    }

    private func configurePlaybackSession() {
        #if os(iOS)
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
        try? session.setActive(true, options: [])
        #endif
    }

    // MARK: - English Speak-Along (graceful fallback on Simulator / denied permissions)

    func startEnglishListening(expectedWord: String, onMatch: @escaping @MainActor () -> Void) {
        stopSpeaking()
        stopListening()
        recognitionNotice = nil
        recognizedTranscript = ""

        #if targetEnvironment(simulator)
        recognitionNotice = "模拟器暂不支持实时麦克风识别，跟着大声读出来再点「我读好啦」领星星吧！"
        return
        #else
        SFSpeechRecognizer.requestAuthorization { [weak self] authStatus in
            Task { @MainActor in
                guard let self else { return }
                guard authStatus == .authorized else {
                    self.recognitionNotice = "未开启语音识别权限，可以直接大声跟读再点「我读好啦」哦！"
                    return
                }
                let granted = await AVAudioApplication.requestRecordPermission()
                guard granted else {
                    self.recognitionNotice = "未开启麦克风权限，可以直接大声跟读再点「我读好啦」哦！"
                    return
                }
                self.beginLiveRecognition(expectedWord: expectedWord, onMatch: onMatch)
            }
        }
        #endif
    }

    func stopListening() {
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
        audioEngine = nil
        isListening = false
    }

    private func beginLiveRecognition(expectedWord: String, onMatch: @escaping @MainActor () -> Void) {
        guard let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US")), recognizer.isAvailable else {
            recognitionNotice = "语音识别当前不可用，可以直接大声跟读再点「我读好啦」！"
            return
        }

        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .measurement, options: [.duckOthers, .defaultToSpeaker])
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            recognitionNotice = "麦克风准备中遇到小问题，直接点「我读好啦」领取鼓励吧！"
            return
        }

        let engine = AVAudioEngine()
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        self.audioEngine = engine
        self.recognitionRequest = request

        let inputNode = engine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            request.append(buffer)
        }

        engine.prepare()
        do {
            try engine.start()
            isListening = true
        } catch {
            stopListening()
            recognitionNotice = "无法启动麦克风，可以直接跟读再点「我读好啦」！"
            return
        }

        let targetLower = expectedWord.lowercased()
        recognitionTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
            Task { @MainActor in
                guard let self else { return }
                if let result {
                    let transcript = result.bestTranscription.formattedString
                    self.recognizedTranscript = transcript
                    if transcript.lowercased().contains(targetLower) {
                        self.stopListening()
                        onMatch()
                    }
                }
                if error != nil {
                    self.stopListening()
                }
            }
        }

        Task { @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(5))
            if self?.isListening == true {
                self?.stopListening()
            }
        }
    }
}

extension SpeechService: AVSpeechSynthesizerDelegate {
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isSpeaking = false
        }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isSpeaking = false
        }
    }
}
