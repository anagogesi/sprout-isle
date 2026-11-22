import Foundation

struct HabitItem: Identifiable, Hashable, Codable, Sendable {
    let id: String
    let title: String
    let emoji: String
    let encourageText: String
    let starReward: Int
    let isCustom: Bool
}

enum StickerCategory: String, CaseIterable, Identifiable, Codable, Sendable {
    case forest = "森林伙伴"
    case sweets = "美味点心"
    case space = "梦幻星空"
    case vehicles = "酷炫交通"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .forest: return "🦊"
        case .sweets: return "🧁"
        case .space: return "🪐"
        case .vehicles: return "🚂"
        }
    }
}

struct StickerItem: Identifiable, Hashable, Codable, Sendable {
    let id: String
    let name: String
    let emoji: String
    let category: StickerCategory
    let starCost: Int
    let tintHex: String
}

enum SproutGrowthStage: Int, CaseIterable, Sendable {
    case seed = 0
    case sprout = 1
    case bud = 2
    case sunflower = 3
    case magicTree = 4

    static func stage(for totalStars: Int) -> SproutGrowthStage {
        switch totalStars {
        case ..<15: return .seed
        case 15..<35: return .sprout
        case 35..<70: return .bud
        case 70..<120: return .sunflower
        default: return .magicTree
        }
    }

    var title: String {
        switch self {
        case .seed: return "小种子宝宝"
        case .sprout: return "嫩绿小芽芽"
        case .bud: return "害羞小花苞"
        case .sunflower: return "阳光向日葵"
        case .magicTree: return "魔法智慧树"
        }
    }

    var emoji: String {
        switch self {
        case .seed: return "🌰"
        case .sprout: return "🌱"
        case .bud: return "🌷"
        case .sunflower: return "🌻"
        case .magicTree: return "🌳"
        }
    }

    var nextMilestone: Int? {
        switch self {
        case .seed: return 15
        case .sprout: return 35
        case .bud: return 70
        case .sunflower: return 120
        case .magicTree: return nil
        }
    }

    var previousMilestone: Int {
        switch self {
        case .seed: return 0
        case .sprout: return 15
        case .bud: return 35
        case .sunflower: return 70
        case .magicTree: return 120
        }
    }
}
