import Foundation

enum IslandDestination: String, CaseIterable, Identifiable, Hashable, Sendable {
    case literacy
    case math
    case english
    case stories
    case habits

    var id: String { rawValue }

    var title: String {
        switch self {
        case .literacy: return "汉字谷"
        case .math: return "数字屋"
        case .english: return "英语湾"
        case .stories: return "故事树"
        case .habits: return "星星塔"
        }
    }

    var subtitle: String {
        switch self {
        case .literacy: return "趣味识字与拼音"
        case .math: return "数数、口算与图形"
        case .english: return "字母、单词与跟读"
        case .stories: return "AI 绘本与十万个为什么"
        case .habits: return "好习惯打卡与贴纸墙"
        }
    }

    var emoji: String {
        switch self {
        case .literacy: return "🌱"
        case .math: return "🔢"
        case .english: return "🐳"
        case .stories: return "🌳"
        case .habits: return "⭐"
        }
    }

    var welcomeSpeech: String {
        switch self {
        case .literacy: return "欢迎来到汉字谷！我们来认识汉字和拼音吧！"
        case .math: return "欢迎来到数字屋！一起数一数，算一算！"
        case .english: return "Welcome to English Cove! 一起来玩趣味英语吧！"
        case .stories: return "欢迎来到故事树！想听绘本故事，还是问十万个为什么呢？"
        case .habits: return "欢迎来到星星塔！看看今天的好习惯和漂亮的贴纸墙吧！"
        }
    }
}

struct ChildProfile: Codable, Equatable, Sendable {
    var name: String = "小芽宝"
    var avatarEmoji: String = "🐣"
    var age: Int = 4
    var autoSpeak: Bool = true
    var soundEffectsEnabled: Bool = true
    var eyeCareMinutes: Int = 15

    static let avatarChoices = ["🐣", "🐰", "🐻", "🦊", "🐼", "🦁", "🐱", "🐶", "🦄", "🦖"]
}

enum AIProviderPreset: String, CaseIterable, Identifiable, Sendable {
    case llmLab = "本机 llm-lab"
    case ollama = "本机 Ollama"
    case deepseek = "DeepSeek"
    case openai = "OpenAI"
    case custom = "自定义兼容接口"

    var id: String { rawValue }

    var defaultBaseURL: String {
        switch self {
        case .llmLab: return "http://127.0.0.1:8000/v1"
        case .ollama: return "http://127.0.0.1:11434/v1"
        case .deepseek: return "https://api.deepseek.com/v1"
        case .openai: return "https://api.openai.com/v1"
        case .custom: return "https://api.openai.com/v1"
        }
    }

    var defaultModel: String {
        switch self {
        case .llmLab: return "llm-lab"
        case .ollama: return "qwen2.5:7b"
        case .deepseek: return "deepseek-chat"
        case .openai: return "gpt-4o-mini"
        case .custom: return "gpt-4o-mini"
        }
    }
}

struct AISettings: Codable, Equatable, Sendable {
    var isEnabled: Bool = false
    var baseURL: String = AIProviderPreset.llmLab.defaultBaseURL
    var modelName: String = AIProviderPreset.llmLab.defaultModel
    var presetName: String = AIProviderPreset.llmLab.rawValue
}

enum TTSProviderPreset: String, CaseIterable, Identifiable, Sendable {
    case openai = "OpenAI TTS"
    case siliconFlow = "硅基流动 CosyVoice"
    case localProxy = "本机 TTS 代理 (Kokoro/Edge)"
    case custom = "自定义 OpenAI 兼容 TTS"

    var id: String { rawValue }

    var defaultBaseURL: String {
        switch self {
        case .openai: return "https://api.openai.com/v1"
        case .siliconFlow: return "https://api.siliconflow.cn/v1"
        case .localProxy: return "http://127.0.0.1:8880/v1"
        case .custom: return "https://api.openai.com/v1"
        }
    }

    var defaultModel: String {
        switch self {
        case .openai: return "gpt-4o-mini-tts"
        case .siliconFlow: return "FunAudioLLM/CosyVoice2-0.5B"
        case .localProxy: return "kokoro"
        case .custom: return "tts-1"
        }
    }

    var defaultVoice: String {
        switch self {
        case .openai: return "nova"
        case .siliconFlow: return "FunAudioLLM/CosyVoice2-0.5B:anna"
        case .localProxy: return "zf_xiaoyi"
        case .custom: return "nova"
        }
    }
}

struct TTSSettings: Codable, Equatable, Sendable {
    var preferParentRecordings: Bool = true
    var useBundledNeuralVoices: Bool = true
    var onlineTTSEnabled: Bool = false
    var baseURL: String = TTSProviderPreset.openai.defaultBaseURL
    var modelName: String = TTSProviderPreset.openai.defaultModel
    var voiceName: String = TTSProviderPreset.openai.defaultVoice
    var speed: Double = 0.95
    var preferredAppleZhVoiceId: String = ""
    var preferredAppleEnVoiceId: String = ""
}

struct DailyActivityRecord: Codable, Equatable, Sendable {
    var dateKey: String
    var starsEarned: Int = 0
    var literacyCount: Int = 0
    var mathCount: Int = 0
    var englishCount: Int = 0
    var storiesRead: Int = 0
    var completedHabitIds: Set<String> = []

    var totalActivities: Int {
        literacyCount + mathCount + englishCount + storiesRead + completedHabitIds.count
    }
}

struct PlacedSticker: Codable, Identifiable, Equatable, Sendable {
    var id: UUID = UUID()
    var stickerId: String
    var xRatio: Double
    var yRatio: Double
    var scale: Double = 1.0
    var rotationDegrees: Double = 0.0
}

struct PersistedAppState: Codable, Equatable, Sendable {
    var profile: ChildProfile = ChildProfile()
    var aiSettings: AISettings = AISettings()
    var ttsSettings: TTSSettings = TTSSettings()
    var totalStars: Int = 6
    var spentStars: Int = 0
    var masteredHanziIds: Set<String> = []
    var masteredEnglishIds: Set<String> = []
    var readStoryIds: Set<String> = []
    var unlockedStickerIds: Set<String> = ["sticker_sprout", "sticker_sun"]
    var placedStickers: [PlacedSticker] = [
        PlacedSticker(stickerId: "sticker_sprout", xRatio: 0.35, yRatio: 0.62, scale: 1.0, rotationDegrees: -4),
        PlacedSticker(stickerId: "sticker_sun", xRatio: 0.72, yRatio: 0.25, scale: 1.0, rotationDegrees: 6),
    ]
    var customHabits: [HabitItem] = []
    var customStories: [StoryBook] = []
    var mathAttempted: Int = 0
    var mathCorrect: Int = 0
    var dailyLogs: [String: DailyActivityRecord] = [:]

    var availableStars: Int {
        max(0, totalStars - spentStars)
    }

    init() {}

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        profile = try c.decodeIfPresent(ChildProfile.self, forKey: .profile) ?? ChildProfile()
        aiSettings = try c.decodeIfPresent(AISettings.self, forKey: .aiSettings) ?? AISettings()
        ttsSettings = try c.decodeIfPresent(TTSSettings.self, forKey: .ttsSettings) ?? TTSSettings()
        totalStars = try c.decodeIfPresent(Int.self, forKey: .totalStars) ?? 6
        spentStars = try c.decodeIfPresent(Int.self, forKey: .spentStars) ?? 0
        masteredHanziIds = try c.decodeIfPresent(Set<String>.self, forKey: .masteredHanziIds) ?? []
        masteredEnglishIds = try c.decodeIfPresent(Set<String>.self, forKey: .masteredEnglishIds) ?? []
        readStoryIds = try c.decodeIfPresent(Set<String>.self, forKey: .readStoryIds) ?? []
        unlockedStickerIds = try c.decodeIfPresent(Set<String>.self, forKey: .unlockedStickerIds) ?? ["sticker_sprout", "sticker_sun"]
        placedStickers = try c.decodeIfPresent([PlacedSticker].self, forKey: .placedStickers) ?? []
        customHabits = try c.decodeIfPresent([HabitItem].self, forKey: .customHabits) ?? []
        customStories = try c.decodeIfPresent([StoryBook].self, forKey: .customStories) ?? []
        mathAttempted = try c.decodeIfPresent(Int.self, forKey: .mathAttempted) ?? 0
        mathCorrect = try c.decodeIfPresent(Int.self, forKey: .mathCorrect) ?? 0
        dailyLogs = try c.decodeIfPresent([String: DailyActivityRecord].self, forKey: .dailyLogs) ?? [:]
    }
}
