import SwiftUI

struct ToyButtonStyle: ButtonStyle {
    var fill: Color = IslandTheme.mint
    var shadow: Color = IslandTheme.mintDark
    var cornerRadius: CGFloat = 20

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(shadow)
                        .offset(y: configuration.isPressed ? 2 : 6)
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(fill)
                        .offset(y: configuration.isPressed ? 4 : 0)
                }
            )
            .offset(y: configuration.isPressed ? 2 : 0)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.22, dampingFraction: 0.65), value: configuration.isPressed)
    }
}

struct ToyCard<Content: View>: View {
    var background: Color = IslandTheme.warmCard
    var border: Color = IslandTheme.borderSoft
    var cornerRadius: CGFloat = 26
    var padding: CGFloat = 18
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(background)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .strokeBorder(border, lineWidth: 2)
                    )
                    .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 5)
            )
    }
}

struct IslandHeaderBar: View {
    let destination: IslandDestination
    let starCount: Int
    let onBack: () -> Void
    let onSpeakTip: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onBack) {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                    Text("回小岛")
                        .font(.kidCaption(15))
                }
                .foregroundStyle(IslandTheme.inkDark)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
                )
            }
            .buttonStyle(.plain)

            HStack(spacing: 6) {
                Text(destination.emoji)
                    .font(.system(size: 24))
                Text(destination.title)
                    .font(.kidHeadline(22))
                    .foregroundStyle(IslandTheme.inkDark)
            }

            Spacer()

            Button(action: onSpeakTip) {
                Image(systemName: "speaker.wave.2.fill")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(destination.primaryColor))
                    .shadow(color: destination.darkColor.opacity(0.35), radius: 4, y: 3)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("朗读提示")

            HStack(spacing: 5) {
                Text("⭐")
                    .font(.system(size: 16))
                Text("\(starCount)")
                    .font(.kidHeadline(17))
                    .foregroundStyle(IslandTheme.inkDark)
                    .contentTransition(.numericText())
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color(hex: "FFF3CD"))
                    .overlay(Capsule().strokeBorder(IslandTheme.amber, lineWidth: 1.5))
            )
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 6)
    }
}

struct ModeTabOption: Identifiable, Hashable {
    let id: String
    let title: String
    let emoji: String
}

struct ModePillBar: View {
    let options: [ModeTabOption]
    @Binding var selectedId: String
    let accentColor: Color
    let onSelect: (() -> Void)?

    var body: some View {
        HStack(spacing: 8) {
            ForEach(options) { option in
                let isSelected = option.id == selectedId
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.72)) {
                        selectedId = option.id
                    }
                    onSelect?()
                } label: {
                    HStack(spacing: 5) {
                        Text(option.emoji)
                            .font(.system(size: 17))
                        Text(option.title)
                            .font(.kidCaption(15))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .foregroundStyle(isSelected ? .white : IslandTheme.inkDark)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .padding(.horizontal, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(isSelected ? accentColor : Color.white.opacity(0.9))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .strokeBorder(isSelected ? accentColor : IslandTheme.borderSoft, lineWidth: 1.5)
                            )
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
    }
}

struct StarToastBanner: View {
    let message: String

    var body: some View {
        HStack(spacing: 8) {
            Text("🌟")
                .font(.system(size: 20))
            Text(message)
                .font(.kidHeadline(16))
                .foregroundStyle(IslandTheme.inkDark)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(Color(hex: "FFF7D6"))
                .overlay(Capsule().strokeBorder(IslandTheme.amber, lineWidth: 2))
                .shadow(color: IslandTheme.amber.opacity(0.35), radius: 12, y: 6)
        )
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}

struct ConfettiBurstView: View {
    let trigger: Int
    @State private var animate = false

    private let particles: [(emoji: String, x: CGFloat, y: CGFloat, angle: Double)] = [
        ("⭐", -110, -90, -25),
        ("✨", 95, -110, 20),
        ("🎉", -75, -135, -40),
        ("🌸", 120, -65, 35),
        ("💛", -25, -145, 10),
        ("🌈", 45, -130, -15),
        ("🌱", -125, -35, 30),
        ("⭐", 80, -30, -30),
    ]

    var body: some View {
        ZStack {
            ForEach(Array(particles.enumerated()), id: \.offset) { _, p in
                Text(p.emoji)
                    .font(.system(size: 28))
                    .offset(x: animate ? p.x : 0, y: animate ? p.y : 0)
                    .rotationEffect(.degrees(animate ? p.angle : 0))
                    .scaleEffect(animate ? 1.1 : 0.2)
                    .opacity(animate ? 0 : 1)
            }
        }
        .allowsHitTesting(false)
        .onChange(of: trigger) { _, _ in
            animate = false
            withAnimation(.easeOut(duration: 0.95)) {
                animate = true
            }
        }
    }
}

struct EyeCareOverlayView: View {
    let countdown: Int
    let onFinish: () -> Void

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "D8F3DC"), Color(hex: "B7E4C7"), Color(hex: "95D5B2")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                SproutMascotView(mood: .sleepy, stage: .sprout, size: 150)

                Text("小眼睛休息时间到啦 🌿")
                    .font(.kidTitle(30))
                    .foregroundStyle(IslandTheme.inkDark)

                Text("跟着小芽宝一起看看窗外绿色的远方，\n轻轻眨眨眼睛吧！")
                    .font(.kidBody(19))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(IslandTheme.inkDark.opacity(0.85))
                    .padding(.horizontal, 24)

                if countdown > 0 {
                    Text("\(countdown) 秒后继续玩")
                        .font(.kidTitle(26))
                        .foregroundStyle(IslandTheme.mintDark)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 14)
                        .background(Capsule().fill(Color.white.opacity(0.9)))
                        .contentTransition(.numericText())
                } else {
                    Button {
                        onFinish()
                    } label: {
                        Text("小眼睛休息好啦，继续冒险！")
                            .font(.kidHeadline(20))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 28)
                            .padding(.vertical, 16)
                    }
                    .buttonStyle(ToyButtonStyle(fill: IslandTheme.mint, shadow: IslandTheme.mintDark))
                }

                if countdown > 0 {
                    Button("家长跳过本次休息") {
                        onFinish()
                    }
                    .font(.kidCaption(14))
                    .foregroundStyle(IslandTheme.inkSoft)
                    .padding(.top, 8)
                }
            }
            .padding(24)
        }
    }
}
