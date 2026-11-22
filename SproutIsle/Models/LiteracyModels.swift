import Foundation

enum HanziCategory: String, CaseIterable, Identifiable, Codable, Sendable {
    case nature = "大自然"
    case animals = "小动物"
    case family = "身体与家人"
    case daily = "生活与水果"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .nature: return "☀️"
        case .animals: return "🐱"
        case .family: return "👨‍👩‍👧"
        case .daily: return "🍎"
        }
    }
}

struct HanziCard: Identifiable, Hashable, Codable, Sendable {
    let id: String
    let character: String
    let pinyin: String
    let meaning: String
    let emoji: String
    let category: HanziCategory
    let mnemonic: String
    let words: [String]
    let sentence: String
    let strokeHint: String
}

struct PinyinItem: Identifiable, Hashable, Sendable {
    let id: String
    let symbol: String
    let tones: [String]
    let sampleChar: String
    let sampleWord: String
    let emoji: String
    let isInitial: Bool
}

struct PinyinBlend: Identifiable, Hashable, Sendable {
    let id: String
    let initial: String
    let finalPart: String
    let combined: String
    let character: String
    let word: String
    let emoji: String
}

struct WordQuizQuestion: Identifiable, Hashable, Sendable {
    let id: UUID
    let prompt: String
    let spokenPrompt: String
    let wordHint: String
    let targetHanzi: HanziCard
    let options: [HanziCard]
}
