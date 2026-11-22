import SwiftUI

struct HabitsAndStickersView: View {
    @Environment(AppStore.self) private var store
    @Environment(SpeechService.self) private var speech
    @Environment(SoundEffectService.self) private var sound

    let onBack: () -> Void

    @State private var modeId: String = "habits"
    @State private var selectedStickerCategory: StickerCategory = .forest
    @State private var showAddHabitSheet: Bool = false
    @State private var confettiTrigger: Int = 0

    private let modes = [
        ModeTabOption(id: "habits", title: "好习惯打卡", emoji: "✅"),
        ModeTabOption(id: "stickers", title: "星级贴纸墙", emoji: "🎨"),
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "FFF0EE"), IslandTheme.creamCanvas],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 12) {
                IslandHeaderBar(
                    destination: .habits,
                    starCount: store.state.totalStars,
                    onBack: onBack,
                    onSpeakTip: {
                        speech.speak(
                            modeId == "habits"
                                ? "完成每天的好习惯点一点打卡，就能赢得闪闪小星星！"
                                : "用攒下来的星星解锁漂亮贴纸，把它们贴到你的小芽岛画板上吧！",
                            language: .chinese
                        )
                    }
                )

                ModePillBar(options: modes, selectedId: $modeId, accentColor: IslandTheme.coral) {
                    sound.play(.tap)
                }

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        if modeId == "habits" {
                            habitsSection
                        } else {
                            stickerWallSection
                        }
                        Spacer(minLength: 28)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 4)
                }
            }

            ConfettiBurstView(trigger: confettiTrigger)
        }
        .sheet(isPresented: $showAddHabitSheet) {
            AddHabitSheet { title, emoji in
                store.addCustomHabit(title: title, emoji: emoji)
                showAddHabitSheet = false
            }
        }
    }

    // MARK: - Daily Good Habits

    private var habitsSection: some View {
        VStack(spacing: 16) {
            // Today's Progress & Sprout Growth Banner
            ToyCard(cornerRadius: 28, padding: 18) {
                HStack(spacing: 16) {
                    SproutMascotView(
                        mood: store.todayCompletedHabitsCount >= 3 ? .cheering : .happy,
                        stage: store.growthStage,
                        size: 90
                    )

                    VStack(alignment: .leading, spacing: 8) {
                        Text("今日好习惯 \(store.todayCompletedHabitsCount) / \(store.allHabits.count)")
                            .font(.kidHeadline(20))
                            .foregroundStyle(IslandTheme.inkDark)

                        Text("当前成长阶段：\(store.growthStage.emoji) \(store.growthStage.title)")
                            .font(.kidCaption(14))
                            .foregroundStyle(IslandTheme.mintDark)

                        HStack(spacing: 10) {
                            Text("可用星星：⭐ \(store.state.availableStars)")
                                .font(.kidCaption(13))
                                .foregroundStyle(IslandTheme.amberDark)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Capsule().fill(Color(hex: "FFF3CD")))

                            Button {
                                sound.play(.tap)
                                showAddHabitSheet = true
                            } label: {
                                Label("加习惯", systemImage: "plus")
                                    .font(.kidCaption(13))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Capsule().fill(IslandTheme.coral))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    Spacer(minLength: 0)
                }
            }

            // Habit Cards Grid
            let cols = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
            LazyVGrid(columns: cols, spacing: 12) {
                ForEach(store.allHabits) { habit in
                    let done = store.isHabitCompletedToday(habit.id)
                    Button {
                        let nowCompleted = store.toggleHabit(habit)
                        if nowCompleted {
                            sound.play(.celebration)
                            confettiTrigger += 1
                            speech.speak(habit.encourageText, language: .chinese)
                        } else {
                            sound.play(.tap)
                        }
                    } label: {
                        VStack(spacing: 10) {
                            HStack {
                                Text("+\(habit.starReward)⭐")
                                    .font(.kidCaption(12))
                                    .foregroundStyle(done ? .white : IslandTheme.amberDark)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(Capsule().fill(done ? Color.white.opacity(0.25) : Color(hex: "FFF3CD")))
                                Spacer()
                                Image(systemName: done ? "checkmark.seal.fill" : "circle")
                                    .font(.system(size: 22))
                                    .foregroundStyle(done ? .white : IslandTheme.borderSoft)
                            }

                            Text(habit.emoji)
                                .font(.system(size: 46))
                                .scaleEffect(done ? 1.12 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: done)

                            Text(habit.title)
                                .font(.kidHeadline(17))
                                .foregroundStyle(done ? .white : IslandTheme.inkDark)
                                .lineLimit(1)
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, minHeight: 146)
                        .background(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(done ? IslandTheme.mint : Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                                        .strokeBorder(done ? IslandTheme.mintDark : IslandTheme.borderSoft, lineWidth: 2)
                                )
                        )
                    }
                    .buttonStyle(ToyButtonStyle(fill: Color.clear, shadow: done ? IslandTheme.mintDark : IslandTheme.borderSoft, cornerRadius: 24))
                }
            }
        }
    }

    // MARK: - Sticker Wall & Interactive Creative Canvas

    private var stickerWallSection: some View {
        VStack(spacing: 16) {
            // Interactive Draggable Sticker Canvas
            ToyCard(cornerRadius: 28, padding: 14) {
                VStack(spacing: 10) {
                    HStack {
                        Text("🖼️ 我的贴纸小岛（拖动贴纸摆造型，双击移除）")
                            .font(.kidCaption(14))
                            .foregroundStyle(IslandTheme.inkDark)
                        Spacer()
                        if !store.state.placedStickers.isEmpty {
                            Button("清空") {
                                sound.play(.tap)
                                store.clearStickerBoard()
                            }
                            .font(.kidCaption(13))
                            .foregroundStyle(IslandTheme.coralDark)
                        }
                    }

                    StickerCanvasBoard(
                        placedStickers: store.state.placedStickers,
                        onMove: { id, xRatio, yRatio in
                            store.updatePlacedStickerPosition(id: id, xRatio: xRatio, yRatio: yRatio)
                        },
                        onRemove: { id in
                            sound.play(.tap)
                            store.removePlacedSticker(id: id)
                        }
                    )
                    .frame(height: 230)
                }
            }

            // Star wallet & category filter
            HStack {
                Text("贴纸收藏盒")
                    .font(.kidHeadline(20))
                    .foregroundStyle(IslandTheme.inkDark)
                Spacer()
                Text("可兑换星星：⭐ \(store.state.availableStars)")
                    .font(.kidCaption(14))
                    .foregroundStyle(IslandTheme.amberDark)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color(hex: "FFF3CD")))
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(StickerCategory.allCases) { cat in
                        let active = cat == selectedStickerCategory
                        Button {
                            sound.play(.tap)
                            selectedStickerCategory = cat
                        } label: {
                            HStack(spacing: 5) {
                                Text(cat.emoji)
                                Text(cat.rawValue)
                                    .font(.kidCaption(14))
                            }
                            .foregroundStyle(active ? .white : IslandTheme.inkDark)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 9)
                            .background(Capsule().fill(active ? IslandTheme.coral : Color.white))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            let cols = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)
            LazyVGrid(columns: cols, spacing: 12) {
                ForEach(HabitStickerCatalog.stickers(for: selectedStickerCategory)) { sticker in
                    let unlocked = store.isStickerUnlocked(sticker.id)
                    let canAfford = store.state.availableStars >= sticker.starCost

                    Button {
                        if unlocked {
                            sound.play(.star)
                            store.placeSticker(sticker)
                        } else if store.unlockSticker(sticker) {
                            sound.play(.celebration)
                            confettiTrigger += 1
                            store.placeSticker(sticker)
                            speech.speak("恭喜解锁\(sticker.name)贴纸！", language: .chinese)
                        } else {
                            sound.play(.tryAgain)
                            speech.speak("还差一点星星哦，去学习小岛收集更多星星吧！", language: .chinese)
                        }
                    } label: {
                        VStack(spacing: 6) {
                            Text(sticker.emoji)
                                .font(.system(size: 42))
                                .opacity(unlocked ? 1.0 : 0.45)

                            Text(sticker.name)
                                .font(.kidCaption(14))
                                .foregroundStyle(IslandTheme.inkDark)

                            if unlocked {
                                Text("贴上去 +")
                                    .font(.kidCaption(12))
                                    .foregroundStyle(IslandTheme.mintDark)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 3)
                                    .background(Capsule().fill(Color(hex: "E6F8EE")))
                            } else {
                                Text("🔒 \(sticker.starCost)⭐")
                                    .font(.kidCaption(12))
                                    .foregroundStyle(canAfford ? .white : IslandTheme.inkSoft)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 3)
                                    .background(Capsule().fill(canAfford ? IslandTheme.amber : Color(hex: "F1F5F9")))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                                        .strokeBorder(unlocked ? Color(hex: sticker.tintHex).opacity(0.6) : IslandTheme.borderSoft, lineWidth: 2)
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

private struct StickerCanvasBoard: View {
    let placedStickers: [PlacedSticker]
    let onMove: (UUID, Double, Double) -> Void
    let onRemove: (UUID) -> Void

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Cute sky + grass meadow scene
                VStack(spacing: 0) {
                    LinearGradient(colors: [Color(hex: "CBEFFF"), Color(hex: "ECFAFF")], startPoint: .top, endPoint: .bottom)
                        .frame(height: geo.size.height * 0.62)
                    LinearGradient(colors: [Color(hex: "9BE5AA"), Color(hex: "64C987")], startPoint: .top, endPoint: .bottom)
                        .frame(height: geo.size.height * 0.38)
                }
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))

                if placedStickers.isEmpty {
                    Text("点下方已解锁的贴纸，装饰你的小岛吧 ✨")
                        .font(.kidCaption(14))
                        .foregroundStyle(IslandTheme.inkSoft)
                }

                ForEach(placedStickers) { placed in
                    if let sticker = HabitStickerCatalog.sticker(by: placed.stickerId) {
                        DraggableStickerToken(
                            placed: placed,
                            emoji: sticker.emoji,
                            canvasSize: geo.size,
                            onMove: { xRatio, yRatio in
                                onMove(placed.id, xRatio, yRatio)
                            },
                            onDoubleTap: {
                                onRemove(placed.id)
                            }
                        )
                    }
                }
            }
        }
    }
}

private struct DraggableStickerToken: View {
    let placed: PlacedSticker
    let emoji: String
    let canvasSize: CGSize
    let onMove: (Double, Double) -> Void
    let onDoubleTap: () -> Void

    @State private var dragOffset: CGSize = .zero

    var body: some View {
        let baseX = canvasSize.width * placed.xRatio
        let baseY = canvasSize.height * placed.yRatio

        Text(emoji)
            .font(.system(size: 46))
            .rotationEffect(.degrees(placed.rotationDegrees))
            .shadow(color: .black.opacity(0.15), radius: 3, y: 2)
            .position(x: baseX + dragOffset.width, y: baseY + dragOffset.height)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = value.translation
                    }
                    .onEnded { value in
                        let newX = (baseX + value.translation.width) / max(1, canvasSize.width)
                        let newY = (baseY + value.translation.height) / max(1, canvasSize.height)
                        dragOffset = .zero
                        onMove(newX, newY)
                    }
            )
            .onTapGesture(count: 2) {
                onDoubleTap()
            }
    }
}

private struct AddHabitSheet: View {
    @Environment(\.dismiss) private var dismiss
    let onSave: (String, String) -> Void

    @State private var title: String = ""
    @State private var selectedEmoji: String = "🌟"
    private let emojiChoices = ["🌟", "🎵", "🎨", "🏃", "🥛", "👟", "🪴", "🐶"]

    var body: some View {
        NavigationStack {
            Form {
                Section("习惯名称") {
                    TextField("例如：自己穿鞋子、整理绘本", text: $title)
                }
                Section("选一个小图标") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                        ForEach(emojiChoices, id: \.self) { emoji in
                            Button {
                                selectedEmoji = emoji
                            } label: {
                                Text(emoji)
                                    .font(.system(size: 32))
                                    .frame(width: 52, height: 52)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(selectedEmoji == emoji ? IslandTheme.coral.opacity(0.2) : Color.clear)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 6)
                }
            }
            .navigationTitle("添加新习惯")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        onSave(title, selectedEmoji)
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
