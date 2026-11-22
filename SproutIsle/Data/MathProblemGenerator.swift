import Foundation

enum MathProblemGenerator {
    static let themes: [MathObjectTheme] = [
        MathObjectTheme(emoji: "🍎", measureWord: "个", name: "苹果"),
        MathObjectTheme(emoji: "🦆", measureWord: "只", name: "小鸭"),
        MathObjectTheme(emoji: "⭐", measureWord: "颗", name: "星星"),
        MathObjectTheme(emoji: "🌸", measureWord: "朵", name: "小花"),
        MathObjectTheme(emoji: "🦋", measureWord: "只", name: "蝴蝶"),
        MathObjectTheme(emoji: "🎈", measureWord: "个", name: "气球"),
        MathObjectTheme(emoji: "🍓", measureWord: "颗", name: "草莓"),
        MathObjectTheme(emoji: "🧁", measureWord: "个", name: "蛋糕"),
    ]

    static let patternPalette: [(hex: String, name: String)] = [
        ("FF6B6B", "红色"),
        ("4EA8DE", "蓝色"),
        ("FFB703", "黄色"),
        ("34B37E", "绿色"),
        ("9B72CF", "紫色"),
    ]

    static func makeCountingQuestion(difficulty: MathDifficulty) -> CountingQuestion {
        let maxVisual = min(difficulty.maxNumber, 15)
        let count = Int.random(in: 1...maxVisual)
        let theme = themes.randomElement() ?? themes[0]
        let options = makeNumberOptions(correct: count, minValue: 1, maxValue: max(maxVisual, count + 2))
        return CountingQuestion(id: UUID(), count: count, theme: theme, options: options)
    }

    static func makeArithmeticQuestion(difficulty: MathDifficulty) -> ArithmeticQuestion {
        let theme = themes.randomElement() ?? themes[0]
        let isAddition = Bool.random()
        let maxTotal = difficulty.maxNumber

        let lhs: Int
        let rhs: Int
        let answer: Int

        if isAddition {
            let cap = max(2, maxTotal)
            answer = Int.random(in: 2...cap)
            lhs = Int.random(in: 1...(answer - 1))
            rhs = answer - lhs
        } else {
            let cap = max(2, maxTotal)
            lhs = Int.random(in: 2...cap)
            rhs = Int.random(in: 1...(lhs - 1))
            answer = lhs - rhs
        }

        let options = makeNumberOptions(correct: answer, minValue: 1, maxValue: max(maxTotal, answer + 2))
        return ArithmeticQuestion(
            id: UUID(),
            lhs: lhs,
            rhs: rhs,
            isAddition: isAddition,
            answer: answer,
            theme: theme,
            options: options
        )
    }

    static func makePatternQuestion(difficulty: MathDifficulty) -> PatternQuestion {
        let shapes = KidShape.allCases.shuffled()
        let colors = patternPalette.shuffled()

        let tokenA = PatternToken(shape: shapes[0], colorHex: colors[0].hex, colorName: colors[0].name)
        let tokenB = PatternToken(shape: shapes[1], colorHex: colors[1].hex, colorName: colors[1].name)
        let tokenC = PatternToken(shape: shapes[2], colorHex: colors[2].hex, colorName: colors[2].name)
        let tokenD = PatternToken(shape: shapes[3], colorHex: colors[3].hex, colorName: colors[3].name)

        let sequence: [PatternToken]
        let answer: PatternToken
        let ruleDescription: String

        switch difficulty {
        case .sprout:
            // ABAB -> ? (A)
            sequence = [tokenA, tokenB, tokenA, tokenB]
            answer = tokenA
            ruleDescription = "\(tokenA.colorName)\(tokenA.shape.chineseName) 和 \(tokenB.colorName)\(tokenB.shape.chineseName) 轮流排队！"
        case .bud:
            if Bool.random() {
                // AABBA -> ? (B)
                sequence = [tokenA, tokenA, tokenB, tokenB, tokenA]
                answer = tokenA
                ruleDescription = "两个一样的排一起，再换下一个！"
            } else {
                // ABABA -> ? (B)
                sequence = [tokenA, tokenB, tokenA, tokenB, tokenA]
                answer = tokenB
                ruleDescription = "一个接一个轮流出现！"
            }
        case .bloom:
            // ABCAB -> ? (C)
            sequence = [tokenA, tokenB, tokenC, tokenA, tokenB]
            answer = tokenC
            ruleDescription = "三个好朋友按顺序排成一队！"
        }

        var optionSet: [PatternToken] = [answer]
        for candidate in [tokenA, tokenB, tokenC, tokenD] where !optionSet.contains(candidate) {
            optionSet.append(candidate)
            if optionSet.count == 3 { break }
        }

        return PatternQuestion(
            id: UUID(),
            sequence: sequence,
            answer: answer,
            options: optionSet.shuffled(),
            ruleDescription: ruleDescription
        )
    }

    static func makeNumberOptions(correct: Int, minValue: Int, maxValue: Int, count: Int = 4) -> [Int] {
        var values: Set<Int> = [correct]
        let offsets = [-3, -2, -1, 1, 2, 3, 4].shuffled()
        for offset in offsets where values.count < count {
            let candidate = correct + offset
            if candidate >= minValue && candidate <= maxValue + 3 {
                values.insert(candidate)
            }
        }
        var fallback = minValue
        while values.count < count {
            values.insert(fallback)
            fallback += 1
        }
        return Array(values).sorted()
    }
}
