import Foundation
import Observation

enum ActivityCategory: Sendable {
    case literacy
    case math
    case english
    case story
    case habit
}

@MainActor
@Observable
final class AppStore {
    private let defaults: UserDefaults
    private let storageKey: String

    var state: PersistedAppState
    var starToastMessage: String?

    init(defaults: UserDefaults = .standard, storageKey: String = "sprout_isle_state_v1") {
        self.defaults = defaults
        self.storageKey = storageKey
        if let data = defaults.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode(PersistedAppState.self, from: data) {
            self.state = decoded
        } else {
            self.state = PersistedAppState()
        }
    }

    // MARK: - Computed Summaries

    var allHabits: [HabitItem] {
        HabitStickerCatalog.defaultHabits + state.customHabits
    }

    var allStories: [StoryBook] {
        state.customStories + StoryCatalog.builtInStories
    }

    var growthStage: SproutGrowthStage {
        SproutGrowthStage.stage(for: state.totalStars)
    }

    var growthProgress: Double {
        guard let next = growthStage.nextMilestone else { return 1.0 }
        let span = Double(max(1, next - growthStage.previousMilestone))
        let current = Double(max(0, state.totalStars - growthStage.previousMilestone))
        return min(1.0, current / span)
    }

    var todayKey: String {
        Self.dateKey(for: Date())
    }

    var todayRecord: DailyActivityRecord {
        state.dailyLogs[todayKey] ?? DailyActivityRecord(dateKey: todayKey)
    }

    var todayCompletedHabitsCount: Int {
        todayRecord.completedHabitIds.count
    }

    var mathAccuracyPercent: Int {
        guard state.mathAttempted > 0 else { return 100 }
        return Int((Double(state.mathCorrect) / Double(state.mathAttempted) * 100.0).rounded())
    }

    var currentStreakDays: Int {
        var streak = 0
        let calendar = Calendar.current
        for offset in 0..<60 {
            guard let date = calendar.date(byAdding: .day, value: -offset, to: Date()) else { break }
            let key = Self.dateKey(for: date)
            if let log = state.dailyLogs[key], log.totalActivities > 0 {
                streak += 1
            } else if offset == 0 {
                continue
            } else {
                break
            }
        }
        return streak
    }

    func recent7DayRecords() -> [(label: String, record: DailyActivityRecord)] {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M/d"

        return (0..<7).reversed().compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: Date()) else { return nil }
            let key = Self.dateKey(for: date)
            let record = state.dailyLogs[key] ?? DailyActivityRecord(dateKey: key)
            return (formatter.string(from: date), record)
        }
    }

    // MARK: - Mutations

    func awardStars(_ amount: Int, category: ActivityCategory, toast: String? = nil) {
        guard amount > 0 else { return }
        state.totalStars += amount
        var today = todayRecord
        today.starsEarned += amount
        switch category {
        case .literacy: today.literacyCount += 1
        case .math: today.mathCount += 1
        case .english: today.englishCount += 1
        case .story: today.storiesRead += 1
        case .habit: break
        }
        state.dailyLogs[todayKey] = today
        save()
        if let toast {
            showToast(toast)
        }
    }

    func markHanziMastered(_ hanzi: HanziCard) -> Bool {
        let isNew = state.masteredHanziIds.insert(hanzi.id).inserted
        awardStars(isNew ? 2 : 1, category: .literacy, toast: isNew ? "学会新字「\(hanzi.character)」！+2⭐" : "复习「\(hanzi.character)」真认真！+1⭐")
        return isNew
    }

    func recordMathResult(isCorrect: Bool) {
        state.mathAttempted += 1
        if isCorrect {
            state.mathCorrect += 1
            awardStars(1, category: .math, toast: "答对啦！数学小天才 +1⭐")
        } else {
            save()
        }
    }

    func markEnglishMastered(_ wordId: String, label: String) -> Bool {
        let isNew = state.masteredEnglishIds.insert(wordId).inserted
        awardStars(isNew ? 2 : 1, category: .english, toast: isNew ? "Awesome! 学会 \(label) +2⭐" : "Great! \(label) +1⭐")
        return isNew
    }

    func markStoryRead(_ story: StoryBook) {
        let isNew = state.readStoryIds.insert(story.id).inserted
        awardStars(isNew ? 3 : 1, category: .story, toast: isNew ? "读完《\(story.title)》！+3⭐" : "又听了一遍《\(story.title)》+1⭐")
    }

    func addCustomStory(_ story: StoryBook) {
        state.customStories.insert(story, at: 0)
        save()
    }

    func isHabitCompletedToday(_ habitId: String) -> Bool {
        todayRecord.completedHabitIds.contains(habitId)
    }

    func toggleHabit(_ habit: HabitItem) -> Bool {
        var today = todayRecord
        if today.completedHabitIds.contains(habit.id) {
            today.completedHabitIds.remove(habit.id)
            state.dailyLogs[todayKey] = today
            save()
            return false
        } else {
            today.completedHabitIds.insert(habit.id)
            today.starsEarned += habit.starReward
            state.totalStars += habit.starReward
            state.dailyLogs[todayKey] = today
            save()
            showToast("\(habit.emoji) \(habit.title)完成！+\(habit.starReward)⭐")
            return true
        }
    }

    func addCustomHabit(title: String, emoji: String) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let item = HabitItem(
            id: "custom_hab_\(UUID().uuidString.prefix(8))",
            title: trimmed,
            emoji: emoji.isEmpty ? "🌟" : emoji,
            encourageText: "太棒啦！完成了「\(trimmed)」！",
            starReward: 2,
            isCustom: true
        )
        state.customHabits.append(item)
        save()
    }

    func isStickerUnlocked(_ stickerId: String) -> Bool {
        state.unlockedStickerIds.contains(stickerId)
    }

    @discardableResult
    func unlockSticker(_ sticker: StickerItem) -> Bool {
        guard !state.unlockedStickerIds.contains(sticker.id) else { return true }
        guard state.availableStars >= sticker.starCost else { return false }
        state.spentStars += sticker.starCost
        state.unlockedStickerIds.insert(sticker.id)
        save()
        showToast("解锁新贴纸「\(sticker.name)」\(sticker.emoji)")
        return true
    }

    func placeSticker(_ sticker: StickerItem, xRatio: Double = 0.5, yRatio: Double = 0.5) {
        guard state.unlockedStickerIds.contains(sticker.id) else { return }
        let jitterX = Double.random(in: -0.18...0.18)
        let jitterY = Double.random(in: -0.18...0.18)
        let placed = PlacedSticker(
            stickerId: sticker.id,
            xRatio: min(0.88, max(0.12, xRatio + jitterX)),
            yRatio: min(0.85, max(0.15, yRatio + jitterY)),
            scale: 1.0,
            rotationDegrees: Double.random(in: -8...8)
        )
        state.placedStickers.append(placed)
        save()
    }

    func updatePlacedStickerPosition(id: UUID, xRatio: Double, yRatio: Double) {
        guard let index = state.placedStickers.firstIndex(where: { $0.id == id }) else { return }
        state.placedStickers[index].xRatio = min(0.92, max(0.08, xRatio))
        state.placedStickers[index].yRatio = min(0.90, max(0.10, yRatio))
        save()
    }

    func removePlacedSticker(id: UUID) {
        state.placedStickers.removeAll { $0.id == id }
        save()
    }

    func clearStickerBoard() {
        state.placedStickers.removeAll()
        save()
    }

    func updateProfile(_ transform: (inout ChildProfile) -> Void) {
        transform(&state.profile)
        save()
    }

    func updateAISettings(_ transform: (inout AISettings) -> Void) {
        transform(&state.aiSettings)
        save()
    }

    func resetProgress() {
        let preservedProfile = state.profile
        let preservedAI = state.aiSettings
        state = PersistedAppState()
        state.profile = preservedProfile
        state.aiSettings = preservedAI
        save()
    }

    func save() {
        if let data = try? JSONEncoder().encode(state) {
            defaults.set(data, forKey: storageKey)
        }
    }

    private func showToast(_ message: String) {
        starToastMessage = message
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(2.2))
            if self.starToastMessage == message {
                self.starToastMessage = nil
            }
        }
    }

    static func dateKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
