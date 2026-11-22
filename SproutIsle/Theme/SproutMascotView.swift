import SwiftUI

enum SproutMood {
    case happy
    case cheering
    case thinking
    case sleepy
}

struct SproutMascotView: View {
    var mood: SproutMood = .happy
    var stage: SproutGrowthStage = .sprout
    var size: CGFloat = 110

    @State private var sway = false
    @State private var floatUp = false

    var body: some View {
        ZStack {
            // Soft sunlit aura
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "FFF3B0").opacity(0.75), Color.clear],
                        center: .center,
                        startRadius: size * 0.1,
                        endRadius: size * 0.56
                    )
                )
                .frame(width: size * 1.15, height: size * 1.15)

            VStack(spacing: -size * 0.1) {
                // Twin Sprouting Leaves + Growth Accessory
                ZStack {
                    // Left leaf
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "74E39A"), Color(hex: "34B37E")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: size * 0.24, height: size * 0.14)
                        .rotationEffect(.degrees(sway ? -34 : -22))
                        .offset(x: -size * 0.12, y: size * 0.02)

                    // Right leaf
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "8CF0AE"), Color(hex: "2DA16E")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: size * 0.26, height: size * 0.15)
                        .rotationEffect(.degrees(sway ? 24 : 36))
                        .offset(x: size * 0.13, y: 0)

                    // Stem
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(hex: "238C60"))
                        .frame(width: size * 0.06, height: size * 0.16)
                        .offset(y: size * 0.08)

                    if stage.rawValue >= SproutGrowthStage.bud.rawValue {
                        Text(stage == .magicTree ? "👑" : "🌼")
                            .font(.system(size: size * 0.22))
                            .offset(y: -size * 0.14)
                    }
                }
                .frame(height: size * 0.28)
                .zIndex(2)

                // Plump round sprout body
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "79E69F"), Color(hex: "34B37E")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: size * 0.72, height: size * 0.68)
                        .overlay(
                            Circle()
                                .strokeBorder(Color.white.opacity(0.6), lineWidth: 3)
                        )
                        .shadow(color: Color(hex: "238C60").opacity(0.28), radius: 8, y: 6)

                    // Cute highlight
                    Ellipse()
                        .fill(Color.white.opacity(0.35))
                        .frame(width: size * 0.2, height: size * 0.1)
                        .rotationEffect(.degrees(-25))
                        .offset(x: -size * 0.16, y: -size * 0.17)

                    // Face
                    VStack(spacing: size * 0.05) {
                        HStack(spacing: size * 0.18) {
                            eyeView
                            eyeView
                        }

                        // Cheeks + Mouth
                        HStack(spacing: size * 0.08) {
                            Circle()
                                .fill(Color(hex: "FF8FAB").opacity(0.7))
                                .frame(width: size * 0.11, height: size * 0.08)

                            mouthView

                            Circle()
                                .fill(Color(hex: "FF8FAB").opacity(0.7))
                                .frame(width: size * 0.11, height: size * 0.08)
                        }
                    }
                    .offset(y: size * 0.03)
                }
            }
            .offset(y: floatUp ? -4 : 4)
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.9).repeatForever(autoreverses: true)) {
                sway = true
            }
            withAnimation(.easeInOut(duration: 2.3).repeatForever(autoreverses: true)) {
                floatUp = true
            }
        }
    }

    @ViewBuilder
    private var eyeView: some View {
        switch mood {
        case .sleepy:
            Capsule()
                .fill(IslandTheme.inkDark)
                .frame(width: size * 0.12, height: size * 0.03)
        case .cheering:
            Image(systemName: "chevron.up")
                .font(.system(size: size * 0.12, weight: .black))
                .foregroundStyle(IslandTheme.inkDark)
        case .happy, .thinking:
            ZStack {
                Circle()
                    .fill(IslandTheme.inkDark)
                    .frame(width: size * 0.11, height: size * 0.11)
                Circle()
                    .fill(Color.white)
                    .frame(width: size * 0.04, height: size * 0.04)
                    .offset(x: -size * 0.02, y: -size * 0.025)
            }
        }
    }

    @ViewBuilder
    private var mouthView: some View {
        switch mood {
        case .cheering:
            Circle()
                .trim(from: 0, to: 0.5)
                .fill(Color(hex: "FF6B6B"))
                .frame(width: size * 0.16, height: size * 0.14)
        case .thinking:
            Circle()
                .strokeBorder(IslandTheme.inkDark, lineWidth: 2.5)
                .frame(width: size * 0.08, height: size * 0.08)
        case .sleepy:
            Capsule()
                .fill(IslandTheme.inkDark)
                .frame(width: size * 0.08, height: size * 0.03)
        case .happy:
            Circle()
                .trim(from: 0.08, to: 0.42)
                .stroke(IslandTheme.inkDark, style: StrokeStyle(lineWidth: max(2.2, size * 0.032), lineCap: .round))
                .frame(width: size * 0.18, height: size * 0.14)
                .offset(y: -size * 0.04)
        }
    }
}
