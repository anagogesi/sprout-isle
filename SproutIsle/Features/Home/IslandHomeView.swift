import SwiftUI

struct IslandHomeView: View {
    @Environment(AppStore.self) private var store
    @Environment(SpeechService.self) private var speech
    @Environment(SoundEffectService.self) private var sound
    @Environment(\.horizontalSizeClass) private var sizeClass

    let onSelectIsland: (IslandDestination) -> Void
    let onOpenParentGate: () -> Void

    @State private var mascotMood: SproutMood = .happy
    @State private var mascotLine: String = "你好呀！今天想去哪座小岛探险呢？"
    @State private var cloudDrift = false

    private let mascotGreetings: [String] = [
        "你好呀！今天想去哪座小岛探险呢？",
        "点点小岛卡片，我们一起玩着学本领！",
        "收集亮晶晶的小星星，帮我长成魔法大树吧！",
        "你真是个爱学习的小天才，为你点赞！",
        "记得每天去星星塔打卡好习惯哦！",
    ]

    var body: some View {
        ZStack {
            // Sunlit Island Background
            LinearGradient(
                colors: [IslandTheme.skyTop, IslandTheme.skyMid, IslandTheme.meadowLight],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Decorative drifting clouds
            VStack {
                HStack {
                    Text("☁️")
                        .font(.system(size: 42))
                        .opacity(0.45)
                        .offset(x: cloudDrift ? 18 : -10)
                    Spacer()
                    Text("☁️")
                        .font(.system(size: 38))
                        .opacity(0.4)
                        .offset(x: cloudDrift ? -16 : 14)
                }
                .padding(.horizontal, 28)
                .padding(.top, 8)
                Spacer()
            }
            .allowsHitTesting(false)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    topBar
                    mascotWelcomeCard
                    islandGrid
                    Spacer(minLength: 28)
                }
                .padding(.horizontal, 18)
                .padding(.top, 10)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 6.5).repeatForever(autoreverses: true)) {
                cloudDrift = true
            }
        }
    }

    private var topBar: some View {
        HStack(spacing: 10) {
            HStack(spacing: 8) {
                Text(store.state.profile.avatarEmoji)
                    .font(.system(size: 28))
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Color.white))
                    .shadow(color: .black.opacity(0.08), radius: 4, y: 2)

                VStack(alignment: .leading, spacing: 1) {
                    Text("小芽岛")
                        .font(.kidHeadline(19))
                        .foregroundStyle(IslandTheme.inkDark)
                    Text("\(store.state.profile.name) · \(store.state.profile.age)岁")
                        .font(.kidCaption(13))
                        .foregroundStyle(IslandTheme.inkSoft)
                }
            }

            Spacer()

            HStack(spacing: 5) {
                Text("⭐")
                Text("\(store.state.totalStars)")
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

            if store.currentStreakDays > 0 {
                HStack(spacing: 3) {
                    Text("🔥")
                    Text("\(store.currentStreakDays)天")
                        .font(.kidCaption(14))
                        .foregroundStyle(IslandTheme.coralDark)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color(hex: "FFE5E5"))
                )
            }

            Button(action: onOpenParentGate) {
                HStack(spacing: 4) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 14, weight: .bold))
                    Text("家长")
                        .font(.kidCaption(13))
                }
                .foregroundStyle(IslandTheme.inkDark)
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.95))
                        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
                )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("家长小屋")
        }
    }

    private var mascotWelcomeCard: some View {
        ToyCard(background: Color.white.opacity(0.92), cornerRadius: 28, padding: 16) {
            HStack(spacing: 14) {
                Button {
                    sound.play(.star)
                    mascotMood = .cheering
                    mascotLine = mascotGreetings.randomElement() ?? mascotGreetings[0]
                    speech.speak(mascotLine, language: .chinese)
                    Task { @MainActor in
                        try? await Task.sleep(for: .seconds(1.5))
                        mascotMood = .happy
                    }
                } label: {
                    SproutMascotView(mood: mascotMood, stage: store.growthStage, size: 96)
                }
                .buttonStyle(.plain)

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(store.growthStage.emoji + " " + store.growthStage.title)
                            .font(.kidCaption(13))
                            .foregroundStyle(IslandTheme.mintDark)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(Color(hex: "E6F8EE")))

                        Spacer()

                        Button {
                            speech.speak(mascotLine, language: .chinese)
                        } label: {
                            Image(systemName: "speaker.wave.2.fill")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(IslandTheme.mint)
                        }
                        .buttonStyle(.plain)
                    }

                    Text(mascotLine)
                        .font(.kidHeadline(16))
                        .foregroundStyle(IslandTheme.inkDark)
                        .fixedSize(horizontal: false, vertical: true)

                    // Growth progress bar
                    VStack(alignment: .leading, spacing: 4) {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color(hex: "E9F5EC"))
                                    .frame(height: 10)
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(hex: "52D18E"), IslandTheme.amber],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: max(14, geo.size.width * store.growthProgress), height: 10)
                            }
                        }
                        .frame(height: 10)

                        if let next = store.growthStage.nextMilestone {
                            Text("再收集 \(max(0, next - store.state.totalStars)) 颗 ⭐ 就能长大升级啦！")
                                .font(.kidCaption(12))
                                .foregroundStyle(IslandTheme.inkSoft)
                        } else {
                            Text("哇！已经长成最厉害的魔法智慧树啦！")
                                .font(.kidCaption(12))
                                .foregroundStyle(IslandTheme.mintDark)
                        }
                    }
                }
            }
        }
    }

    private var islandGrid: some View {
        let learningIslands: [IslandDestination] = [.literacy, .math, .english, .stories]
        let columnsCount = sizeClass == .regular ? 4 : 2
        let columns = Array(repeating: GridItem(.flexible(), spacing: 14), count: columnsCount)

        return VStack(spacing: 16) {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(learningIslands) { island in
                    islandCard(island)
                }
            }
            wideHabitsBanner(.habits)
        }
    }

    private func wideHabitsBanner(_ island: IslandDestination) -> some View {
        Button {
            onSelectIsland(island)
        } label: {
            HStack(spacing: 14) {
                Text(island.emoji)
                    .font(.system(size: 42))
                    .frame(width: 62, height: 62)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color.white.opacity(0.28))
                    )

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(island.title)
                            .font(.kidTitle(22))
                            .foregroundStyle(.white)
                        Text(progressBadge(for: island))
                            .font(.kidCaption(12))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)
                            .padding(.horizontal, 9)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(Color.black.opacity(0.18)))
                    }
                    Text(island.subtitle)
                        .font(.kidCaption(14))
                        .foregroundStyle(.white.opacity(0.94))
                }

                Spacer(minLength: 4)

                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.white.opacity(0.95))
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(
                    colors: island.gradientColors,
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
            )
        }
        .buttonStyle(ToyButtonStyle(fill: Color.clear, shadow: island.darkColor, cornerRadius: 26))
    }

    private func islandCard(_ island: IslandDestination) -> some View {
        Button {
            onSelectIsland(island)
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top, spacing: 6) {
                    Text(island.emoji)
                        .font(.system(size: 40))
                        .frame(width: 58, height: 58)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(Color.white.opacity(0.28))
                        )

                    Spacer(minLength: 4)

                    Text(progressBadge(for: island))
                        .font(.kidCaption(11))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(Color.black.opacity(0.18)))
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(island.title)
                        .font(.kidTitle(22))
                        .foregroundStyle(.white)
                    Text(island.subtitle)
                        .font(.kidCaption(13))
                        .foregroundStyle(.white.opacity(0.92))
                        .lineLimit(2)
                        .minimumScaleFactor(0.9)
                }

                HStack {
                    Text("开始玩")
                        .font(.kidCaption(13))
                        .foregroundStyle(island.darkColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(Color.white.opacity(0.95)))
                    Spacer()
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(.white.opacity(0.95))
                }
            }
            .padding(15)
            .frame(maxWidth: .infinity, minHeight: 184, alignment: .topLeading)
            .background(
                LinearGradient(
                    colors: island.gradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
            )
        }
        .buttonStyle(ToyButtonStyle(fill: Color.clear, shadow: island.darkColor, cornerRadius: 26))
    }

    private func progressBadge(for island: IslandDestination) -> String {
        switch island {
        case .literacy:
            return "\(store.state.masteredHanziIds.count)/\(LiteracyCatalog.hanziCards.count) 字"
        case .math:
            return "答对 \(store.state.mathCorrect) 题"
        case .english:
            return "\(store.state.masteredEnglishIds.count) 词"
        case .stories:
            return "\(store.allStories.count) 本绘本"
        case .habits:
            return "今日 \(store.todayCompletedHabitsCount)/\(store.allHabits.count)"
        }
    }
}
