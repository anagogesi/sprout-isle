import Foundation

enum MathDifficulty: Int, CaseIterable, Identifiable, Sendable {
    case sprout = 1
    case bud = 2
    case bloom = 3

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .sprout: return "小芽 1-5"
        case .bud: return "嫩叶 1-10"
        case .bloom: return "花朵 1-20"
        }
    }

    var maxNumber: Int {
        switch self {
        case .sprout: return 5
        case .bud: return 10
        case .bloom: return 20
        }
    }
}

struct MathObjectTheme: Hashable, Sendable {
    let emoji: String
    let measureWord: String
    let name: String
}

struct CountingQuestion: Identifiable, Hashable, Sendable {
    let id: UUID
    let count: Int
    let theme: MathObjectTheme
    let options: [Int]

    var spokenPrompt: String {
        "请数一数，草地上有几\(theme.measureWord)\(theme.name)呢？"
    }
}

struct ArithmeticQuestion: Identifiable, Hashable, Sendable {
    let id: UUID
    let lhs: Int
    let rhs: Int
    let isAddition: Bool
    let answer: Int
    let theme: MathObjectTheme
    let options: [Int]

    var operatorSymbol: String { isAddition ? "+" : "-" }

    var spokenPrompt: String {
        if isAddition {
            return "\(lhs)\(theme.measureWord)\(theme.name)，加上\(rhs)\(theme.measureWord)，一共有几\(theme.measureWord)呢？"
        } else {
            return "\(lhs)\(theme.measureWord)\(theme.name)，拿走\(rhs)\(theme.measureWord)，还剩下几\(theme.measureWord)呢？"
        }
    }

    var spokenSegments: [String] {
        let subject = "\(lhs)\(theme.measureWord)\(theme.name)"
        if isAddition {
            return [subject, "加上\(rhs)\(theme.measureWord)", "一共有几\(theme.measureWord)呢？"]
        } else {
            return [subject, "拿走\(rhs)\(theme.measureWord)", "还剩下几\(theme.measureWord)呢？"]
        }
    }
}

enum KidShape: String, CaseIterable, Identifiable, Hashable, Sendable {
    case circle
    case square
    case triangle
    case star
    case heart
    case diamond

    var id: String { rawValue }

    var chineseName: String {
        switch self {
        case .circle: return "圆形"
        case .square: return "正方形"
        case .triangle: return "三角形"
        case .star: return "五角星"
        case .heart: return "爱心"
        case .diamond: return "菱形"
        }
    }

    var englishName: String {
        switch self {
        case .circle: return "Circle"
        case .square: return "Square"
        case .triangle: return "Triangle"
        case .star: return "Star"
        case .heart: return "Heart"
        case .diamond: return "Diamond"
        }
    }

    var everydayExample: String {
        switch self {
        case .circle: return "像圆圆的太阳和西瓜"
        case .square: return "像方方的小饼干和积木"
        case .triangle: return "像美味的披萨和小山坡"
        case .star: return "像夜空里闪闪的小星星"
        case .heart: return "像爸爸妈妈满满的爱"
        case .diamond: return "像飞在天空里的小风筝"
        }
    }

    var exampleEmoji: String {
        switch self {
        case .circle: return "🍉"
        case .square: return "🧊"
        case .triangle: return "🍕"
        case .star: return "🌟"
        case .heart: return "💝"
        case .diamond: return "🪁"
        }
    }
}

struct PatternToken: Identifiable, Hashable, Sendable {
    var id: String { "\(shape.rawValue)_\(colorHex)" }
    let shape: KidShape
    let colorHex: String
    let colorName: String
}

struct PatternQuestion: Identifiable, Hashable, Sendable {
    let id: UUID
    let sequence: [PatternToken]
    let answer: PatternToken
    let options: [PatternToken]
    let ruleDescription: String
}
