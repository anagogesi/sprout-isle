import AVFoundation
import CryptoKit
import Foundation
import Observation
import Speech

enum SpeechLanguage: String, Sendable {
    case chinese = "zh-CN"
    case english = "en-US"
}

enum VoiceSourceKind: Equatable, Sendable {
    case parentRecording
    case bundledNeural
    case onlineNeuralTTS
    case appleSystem

    var badgeLabel: String {
        switch self {
        case .parentRecording: return "💛 爸妈原声"
        case .bundledNeural: return "✨ 拟真幼师声"
        case .onlineNeuralTTS: return "☁️ AI 真人声"
        case .appleSystem: return "🗣️ 系统语音"
        }
    }
}

struct AppleVoiceOption: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let language: String
    let qualityLabel: String
}

@MainActor
@Observable
final class SpeechService: NSObject {
    private let synthesizer = AVSpeechSynthesizer()
    private var audioPlayer: AVAudioPlayer?
    private var onlineFetchTask: Task<Void, Never>?

    private var voiceManifest: [String: String] = [:]
    private weak var parentVoiceStore: ParentVoiceStore?
    private var ttsSettingsProvider: (@MainActor () -> TTSSettings)?
    private let ttsCacheDir: URL

    var isSpeaking: Bool = false
    var activeVoiceSource: VoiceSourceKind?

    // Speech recognition state for English Speak-Along
    var isListening: Bool = false
    var recognizedTranscript: String = ""
    var recognitionNotice: String?

    private var audioEngine: AVAudioEngine?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    var bundledVoiceCount: Int {
        voiceManifest.count
    }

    override init() {
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        self.ttsCacheDir = caches.appendingPathComponent("SproutIsleTTS", isDirectory: true)
        super.init()
        synthesizer.delegate = self
        try? FileManager.default.createDirectory(at: ttsCacheDir, withIntermediateDirectories: true)
        loadBundledManifest()
    }

    func configure(
        parentVoiceStore: ParentVoiceStore,
        ttsSettingsProvider: @escaping @MainActor () -> TTSSettings
    ) {
        self.parentVoiceStore = parentVoiceStore
        self.ttsSettingsProvider = ttsSettingsProvider
    }

    private func loadBundledManifest() {
        let url = Bundle.main.url(forResource: "VoiceManifest", withExtension: "json", subdirectory: "Voices")
            ?? Bundle.main.url(forResource: "VoiceManifest", withExtension: "json")
        guard let url,
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([String: String].self, from: data) else {
            return
        }
        voiceManifest = decoded
    }

    func speak(
        _ text: String,
        language: SpeechLanguage = .chinese,
        rate: Float = 0.48,
        pitch: Float = 1.0,
        interrupt: Bool = true,
        voiceSlotKey: String? = nil
    ) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        if interrupt {
            stopSpeaking()
        }

        let settings = ttsSettingsProvider?() ?? TTSSettings()

        // 1. Parent's own real voice recording (highest warmth!)
        if settings.preferParentRecordings,
           let parentURL = parentVoiceStore?.recordedURL(for: voiceSlotKey, matchingText: trimmed) {
            if playAudioFile(at: parentURL, source: .parentRecording) {
                return
            }
        }

        // 2. Bundled offline studio-quality neural voice pack
        if settings.useBundledNeuralVoices,
           let bundledURL = bundledVoiceURL(for: trimmed) {
            if playAudioFile(at: bundledURL, source: .bundledNeural) {
                return
            }
        }

        // 3. Online Neural TTS API (OpenAI-compatible /audio/speech with disk cache)
        if settings.onlineTTSEnabled {
            let cacheURL = onlineCacheURL(for: trimmed, settings: settings)
            if FileManager.default.fileExists(atPath: cacheURL.path),
               playAudioFile(at: cacheURL, source: .onlineNeuralTTS) {
                return
            }
            fetchAndPlayOnlineTTS(text: trimmed, language: language, settings: settings, cacheURL: cacheURL)
            return
        }

        // 4. Clean Apple system voice fallback (robotic Eloquence voices filtered out)
        speakWithAppleSynthesizer(trimmed, language: language, rate: rate, pitch: pitch, settings: settings)
    }

    func previewAudioFile(at url: URL, source: VoiceSourceKind = .parentRecording) {
        stopSpeaking()
        _ = playAudioFile(at: url, source: source)
    }

    func previewOnlineTTS(text: String, settings: TTSSettings, apiKey: String) async -> Result<Void, Error> {
        do {
            let data = try await requestOnlineTTSAudio(text: text, settings: settings, apiKey: apiKey)
            let tmp = ttsCacheDir.appendingPathComponent("preview_tts.audio")
            try data.write(to: tmp, options: .atomic)
            stopSpeaking()
            _ = playAudioFile(at: tmp, source: .onlineNeuralTTS)
            return .success(())
        } catch {
            return .failure(error)
        }
    }

    func previewAppleVoice(identifier: String, language: SpeechLanguage) {
        stopSpeaking()
        configurePlaybackSession()
        let sample = language == .chinese ? "你好呀小朋友！欢迎来到小芽岛一起学本领！" : "Hello little friend! Welcome to Sprout Isle!"
        let utterance = AVSpeechUtterance(string: sample)
        utterance.voice = AVSpeechSynthesisVoice(identifier: identifier) ?? preferredAppleVoice(for: language, preferredId: "")
        utterance.rate = 0.48
        utterance.pitchMultiplier = 1.0
        activeVoiceSource = .appleSystem
        isSpeaking = true
        synthesizer.speak(utterance)
    }

    func clearOnlineTTSCache() {
        let files = (try? FileManager.default.contentsOfDirectory(at: ttsCacheDir, includingPropertiesForKeys: nil)) ?? []
        for file in files {
            try? FileManager.default.removeItem(at: file)
        }
    }

    func stopSpeaking() {
        onlineFetchTask?.cancel()
        onlineFetchTask = nil
        if let player = audioPlayer, player.isPlaying {
            player.stop()
        }
        audioPlayer = nil
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        isSpeaking = false
        activeVoiceSource = nil
    }

    // MARK: - Bundled Neural Voice Lookup

    func bundledVoiceURL(for text: String) -> URL? {
        let hash = Self.sha256Key(for: text)
        guard let filename = voiceManifest[hash] else { return nil }
        let base = (filename as NSString).deletingPathExtension
        let ext = (filename as NSString).pathExtension
        return Bundle.main.url(forResource: base, withExtension: ext, subdirectory: "Voices")
            ?? Bundle.main.url(forResource: base, withExtension: ext)
    }

    nonisolated static func sha256Key(for text: String) -> String {
        let digest = SHA256.hash(data: Data(text.trimmingCharacters(in: .whitespacesAndNewlines).utf8))
        return digest.map { String(format: "%02x", $0) }.joined().prefix(16).description
    }

    // MARK: - Audio File Playback

    private func playAudioFile(at url: URL, source: VoiceSourceKind) -> Bool {
        configurePlaybackSession()
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.delegate = self
            player.prepareToPlay()
            guard player.play() else { return false }
            audioPlayer = player
            isSpeaking = true
            activeVoiceSource = source
            return true
        } catch {
            return false
        }
    }

    // MARK: - Online Neural TTS (/audio/speech)

    private func onlineCacheURL(for text: String, settings: TTSSettings) -> URL {
        let cacheKey = Self.sha256Key(for: "\(settings.baseURL)|\(settings.modelName)|\(settings.voiceName)|\(settings.speed)|\(text)")
        return ttsCacheDir.appendingPathComponent("tts_\(cacheKey).mp3")
    }

    private func fetchAndPlayOnlineTTS(
        text: String,
        language: SpeechLanguage,
        settings: TTSSettings,
        cacheURL: URL
    ) {
        let apiKey = KeychainHelper.loadTTSAPIKey().isEmpty ? KeychainHelper.loadAPIKey() : KeychainHelper.loadTTSAPIKey()
        onlineFetchTask?.cancel()
        onlineFetchTask = Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                let data = try await self.requestOnlineTTSAudio(text: text, settings: settings, apiKey: apiKey)
                guard !Task.isCancelled else { return }
                try data.write(to: cacheURL, options: .atomic)
                if !self.playAudioFile(at: cacheURL, source: .onlineNeuralTTS) {
                    self.speakWithAppleSynthesizer(text, language: language, rate: 0.48, pitch: 1.0, settings: settings)
                }
            } catch {
                guard !Task.isCancelled else { return }
                self.speakWithAppleSynthesizer(text, language: language, rate: 0.48, pitch: 1.0, settings: settings)
            }
        }
    }

    private func requestOnlineTTSAudio(text: String, settings: TTSSettings, apiKey: String) async throws -> Data {
        let base = settings.baseURL.trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let endpoint = base.hasSuffix("/audio/speech") ? base : "\(base)/audio/speech"
        guard let url = URL(string: endpoint), let scheme = url.scheme, (scheme == "http" || scheme == "https") else {
            throw AIServiceError.invalidURL
        }

        struct TTSPayload: Encodable {
            let model: String
            let input: String
            let voice: String
            let response_format: String
            let speed: Double
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 20
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = try JSONEncoder().encode(
            TTSPayload(
                model: settings.modelName.isEmpty ? "gpt-4o-mini-tts" : settings.modelName,
                input: text,
                voice: settings.voiceName.isEmpty ? "nova" : settings.voiceName,
                response_format: "mp3",
                speed: max(0.7, min(1.3, settings.speed))
            )
        )

        let (data, response) = try await URLSession.shared.data(for: request)
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            let errBody = String(data: data, encoding: .utf8) ?? ""
            throw AIServiceError.httpError(http.statusCode, errBody)
        }
        guard data.count > 256 else {
            throw AIServiceError.emptyResponse
        }
        return data
    }

    // MARK: - Smart Apple System Voice Fallback (Filters Robotic Voices)

    private func speakWithAppleSynthesizer(
        _ text: String,
        language: SpeechLanguage,
        rate: Float,
        pitch: Float,
        settings: TTSSettings
    ) {
        configurePlaybackSession()
        let preferredId = language == .chinese ? settings.preferredAppleZhVoiceId : settings.preferredAppleEnVoiceId
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = preferredAppleVoice(for: language, preferredId: preferredId)
        // Use natural pitch (1.0) so voices never sound squeaky or robotic
        utterance.rate = max(0.42, min(0.52, rate))
        utterance.pitchMultiplier = max(0.95, min(1.03, pitch == 1.12 ? 1.0 : pitch))
        utterance.postUtteranceDelay = 0.06
        activeVoiceSource = .appleSystem
        isSpeaking = true
        synthesizer.speak(utterance)
    }

    static func availableNaturalAppleVoices(for language: SpeechLanguage) -> [AppleVoiceOption] {
        let prefix = language.rawValue.prefix(2).lowercased()
        let voices = AVSpeechSynthesisVoice.speechVoices()
            .filter { voice in
                voice.language.lowercased().hasPrefix(prefix) &&
                !isRoboticVoice(identifier: voice.identifier, name: voice.name)
            }
            .sorted { rank(voice: $0, targetLang: language.rawValue) > rank(voice: $1, targetLang: language.rawValue) }

        return voices.map { voice in
            let q: String
            switch voice.quality {
            case .premium: q = "超清人声"
            case .enhanced: q = "增强人声"
            default: q = voice.identifier.lowercased().contains("siri") ? "Siri 人声" : "标准"
            }
            return AppleVoiceOption(id: voice.identifier, name: voice.name, language: voice.language, qualityLabel: q)
        }
    }

    nonisolated static func isRoboticVoice(identifier: String, name: String) -> Bool {
        let idLower = identifier.lowercased()
        if idLower.contains("eloquence") || idLower.contains("speech.synthesis.voice") {
            return true
        }
        let noveltyNames: Set<String> = [
            "albert", "bad news", "bahh", "bells", "boing", "bubbles", "cellos",
            "eddy", "flo", "fred", "good news", "grandma", "grandpa", "jester",
            "junior", "kathy", "organ", "ralph", "reed", "rocko", "sandy",
            "shelley", "superstar", "trinoids", "whisper", "wobble", "zarvox",
            "deranged", "hysterical",
        ]
        let baseName = name.lowercased().components(separatedBy: " (").first ?? name.lowercased()
        return noveltyNames.contains(baseName)
    }

    private static func rank(voice: AVSpeechSynthesisVoice, targetLang: String) -> Int {
        var score = 0
        if voice.language == targetLang { score += 50 }
        switch voice.quality {
        case .premium: score += 100
        case .enhanced: score += 70
        default: score += 10
        }
        let id = voice.identifier.lowercased()
        let name = voice.name.lowercased()
        if id.contains("siri") { score += 45 }
        if name.contains("tingting") || name.contains("lili") || name.contains("zoe") || name.contains("ava") || name.contains("samantha") {
            score += 20
        }
        return score
    }

    private func preferredAppleVoice(for language: SpeechLanguage, preferredId: String) -> AVSpeechSynthesisVoice? {
        if !preferredId.isEmpty, let chosen = AVSpeechSynthesisVoice(identifier: preferredId) {
            return chosen
        }
        let prefix = language.rawValue.prefix(2).lowercased()
        let natural = AVSpeechSynthesisVoice.speechVoices()
            .filter {
                $0.language.lowercased().hasPrefix(prefix) &&
                !Self.isRoboticVoice(identifier: $0.identifier, name: $0.name)
            }
            .sorted { Self.rank(voice: $0, targetLang: language.rawValue) > Self.rank(voice: $1, targetLang: language.rawValue) }

        return natural.first ?? AVSpeechSynthesisVoice(language: language.rawValue)
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
            self.activeVoiceSource = nil
        }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isSpeaking = false
            self.activeVoiceSource = nil
        }
    }
}

extension SpeechService: AVAudioPlayerDelegate {
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            self.isSpeaking = false
            self.activeVoiceSource = nil
            self.audioPlayer = nil
        }
    }
}
