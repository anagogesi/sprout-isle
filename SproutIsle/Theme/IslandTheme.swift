import SwiftUI

extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&int)
        let r, g, b: UInt64
        switch cleaned.count {
        case 6:
            (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (52, 179, 126)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255.0,
            green: Double(g) / 255.0,
            blue: Double(b) / 255.0,
            opacity: 1.0
        )
    }
}

enum IslandTheme {
    static let creamCanvas = Color(hex: "FFFBF2")
    static let warmCard = Color.white
    static let skyTop = Color(hex: "DDF4FF")
    static let skyMid = Color(hex: "F3FBFF")
    static let meadowLight = Color(hex: "E9F9EE")

    static let mint = Color(hex: "34B37E")
    static let mintDark = Color(hex: "238C60")
    static let amber = Color(hex: "FFB703")
    static let amberDark = Color(hex: "D98E00")
    static let lagoon = Color(hex: "4EA8DE")
    static let lagoonDark = Color(hex: "2F7FB5")
    static let lavender = Color(hex: "9B72CF")
    static let lavenderDark = Color(hex: "734BA8")
    static let coral = Color(hex: "FF6B6B")
    static let coralDark = Color(hex: "D94848")

    static let inkDark = Color(hex: "2B3445")
    static let inkSoft = Color(hex: "64748B")
    static let borderSoft = Color(hex: "EAE3D2")
}

extension IslandDestination {
    var primaryColor: Color {
        switch self {
        case .literacy: return IslandTheme.mint
        case .math: return IslandTheme.amber
        case .english: return IslandTheme.lagoon
        case .stories: return IslandTheme.lavender
        case .habits: return IslandTheme.coral
        }
    }

    var darkColor: Color {
        switch self {
        case .literacy: return IslandTheme.mintDark
        case .math: return IslandTheme.amberDark
        case .english: return IslandTheme.lagoonDark
        case .stories: return IslandTheme.lavenderDark
        case .habits: return IslandTheme.coralDark
        }
    }

    var gradientColors: [Color] {
        switch self {
        case .literacy: return [Color(hex: "4AD295"), Color(hex: "24A16D")]
        case .math: return [Color(hex: "FFCA3A"), Color(hex: "F7931E")]
        case .english: return [Color(hex: "56CFE1"), Color(hex: "3A86FF")]
        case .stories: return [Color(hex: "B388EB"), Color(hex: "7B52C7")]
        case .habits: return [Color(hex: "FF8585"), Color(hex: "F25C54")]
        }
    }
}

extension Font {
    static func kidGiant(_ size: CGFloat = 68) -> Font {
        .system(size: size, weight: .heavy, design: .rounded)
    }

    static func kidTitle(_ size: CGFloat = 28) -> Font {
        .system(size: size, weight: .heavy, design: .rounded)
    }

    static func kidHeadline(_ size: CGFloat = 20) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }

    static func kidBody(_ size: CGFloat = 17) -> Font {
        .system(size: size, weight: .medium, design: .rounded)
    }

    static func kidCaption(_ size: CGFloat = 14) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }
}
