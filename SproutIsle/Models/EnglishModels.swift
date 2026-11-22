import Foundation

struct PhonicsCard: Identifiable, Hashable, Sendable {
    var id: String { letter }
    let letter: String
    let lowercase: String
    let phonicsCue: String
    let word: String
    let chinese: String
    let emoji: String
    let sentence: String
    let colorHex: String
}

enum EnglishCategory: String, CaseIterable, Identifiable, Sendable {
    case animals = "小动物 Animals"
    case fruits = "水果美食 Fruits"
    case colors = "彩虹颜色 Colors"
    case world = "交通与自然 World"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .animals: return "🐶"
        case .fruits: return "🍓"
        case .colors: return "🌈"
        case .world: return "🚀"
        }
    }
}

struct EnglishWordCard: Identifiable, Hashable, Sendable {
    let id: String
    let word: String
    let phonetic: String
    let chinese: String
    let emoji: String
    let category: EnglishCategory
    let sentence: String
    let sentenceChinese: String
    let accentHex: String
}
