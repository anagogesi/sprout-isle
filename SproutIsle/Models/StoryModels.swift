import Foundation

struct StoryChoice: Identifiable, Hashable, Codable, Sendable {
    let id: String
    let label: String
    let emoji: String
    let outcomeText: String
    let outcomeEmoji: String
}

struct StoryPage: Identifiable, Hashable, Codable, Sendable {
    let id: String
    let title: String
    let narration: String
    let sceneEmoji: String
    let secondaryEmoji: String
    let gradientHexes: [String]
    let choicePrompt: String?
    let choices: [StoryChoice]
    var speechSegments: [String]? = nil
}

struct StoryBook: Identifiable, Hashable, Codable, Sendable {
    let id: String
    let title: String
    let subtitle: String
    let coverEmoji: String
    let themeTag: String
    let accentHex: String
    let isAIGenerated: Bool
    let pages: [StoryPage]
    let moral: String
}

enum WhyCategory: String, CaseIterable, Identifiable, Codable, Sendable {
    case sky = "天空与宇宙"
    case animals = "动物世界"
    case body = "奇妙身体"
    case life = "生活小科学"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .sky: return "🌌"
        case .animals: return "🦒"
        case .body: return "🫀"
        case .life: return "🫧"
        }
    }
}

struct WhyQAItem: Identifiable, Hashable, Codable, Sendable {
    let id: String
    let question: String
    let shortAnswer: String
    let kidExplanation: String
    let funActivity: String
    let emoji: String
    let category: WhyCategory
}

struct StoryCreationRequest: Hashable, Sendable {
    var hero: String
    var heroEmoji: String
    var setting: String
    var settingEmoji: String
    var lesson: String
    var childName: String
}
