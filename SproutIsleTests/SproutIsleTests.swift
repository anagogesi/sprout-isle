import XCTest
@testable import SproutIsle

final class SproutIsleTests: XCTestCase {
    func testCatalogsAreRichAndValid() {
        XCTAssertGreaterThanOrEqual(LiteracyCatalog.hanziCards.count, 32)
        XCTAssertEqual(LiteracyCatalog.vowels.count, 6)
        XCTAssertGreaterThanOrEqual(LiteracyCatalog.blendingPairs.count, 10)
        XCTAssertEqual(EnglishCatalog.phonicsCards.count, 26)
        XCTAssertGreaterThanOrEqual(EnglishCatalog.wordCards.count, 32)
        XCTAssertGreaterThanOrEqual(StoryCatalog.builtInStories.count, 4)
        XCTAssertGreaterThanOrEqual(StoryCatalog.whyQAs.count, 16)
        XCTAssertGreaterThanOrEqual(HabitStickerCatalog.defaultHabits.count, 8)
        XCTAssertGreaterThanOrEqual(HabitStickerCatalog.stickers.count, 24)

        // Ensure unique IDs across catalogs
        XCTAssertEqual(Set(LiteracyCatalog.hanziCards.map(\.id)).count, LiteracyCatalog.hanziCards.count)
        XCTAssertEqual(Set(EnglishCatalog.wordCards.map(\.id)).count, EnglishCatalog.wordCards.count)
        XCTAssertEqual(Set(HabitStickerCatalog.stickers.map(\.id)).count, HabitStickerCatalog.stickers.count)
    }

    func testLiteracyQuizQuestionAlwaysContainsTarget() {
        for _ in 0..<25 {
            let q = LiteracyCatalog.makeQuizQuestion()
            XCTAssertEqual(q.options.count, 4)
            XCTAssertTrue(q.options.contains(q.targetHanzi))
            XCTAssertEqual(Set(q.options.map(\.id)).count, 4)
        }
    }

    func testMathGeneratorsProduceValidBounds() {
        for difficulty in MathDifficulty.allCases {
            for _ in 0..<20 {
                let counting = MathProblemGenerator.makeCountingQuestion(difficulty: difficulty)
                XCTAssertTrue((1...difficulty.maxNumber).contains(counting.count))
                XCTAssertTrue(counting.options.contains(counting.count))
                XCTAssertEqual(Set(counting.options).count, 4)

                let arithmetic = MathProblemGenerator.makeArithmeticQuestion(difficulty: difficulty)
                if arithmetic.isAddition {
                    XCTAssertEqual(arithmetic.lhs + arithmetic.rhs, arithmetic.answer)
                } else {
                    XCTAssertEqual(arithmetic.lhs - arithmetic.rhs, arithmetic.answer)
                }
                XCTAssertGreaterThanOrEqual(arithmetic.answer, 1)
                XCTAssertTrue(arithmetic.options.contains(arithmetic.answer))
                XCTAssertEqual(Set(arithmetic.options).count, 4)

                let pattern = MathProblemGenerator.makePatternQuestion(difficulty: difficulty)
                XCTAssertGreaterThanOrEqual(pattern.sequence.count, 4)
                XCTAssertTrue(pattern.options.contains(pattern.answer))
                XCTAssertEqual(Set(pattern.options).count, 3)
            }
        }
    }

    func testAIStoryJSONParsingWithMarkdownFences() {
        let fenced = """
        ```json
        {
          "title": "小兔子的彩虹船",
          "subtitle": "勇敢启航",
          "coverEmoji": "🐰",
          "moral": "勇敢就会发现奇迹！",
          "pages": [
            {
              "title": "海边出发",
              "narration": "小兔子造了一艘彩色小船。",
              "sceneEmoji": "⛵",
              "secondaryEmoji": "🐰",
              "choicePrompt": null,
              "choices": []
            },
            {
              "title": "小小选择",
              "narration": "小海豚游过来打招呼啦！",
              "sceneEmoji": "🐬",
              "secondaryEmoji": "🌊",
              "choicePrompt": "怎么回应小海豚？",
              "choices": [
                {"label": "挥手微笑", "emoji": "👋", "outcomeText": "小海豚跃出水面鼓掌！", "outcomeEmoji": "✨"}
              ]
            }
          ]
        }
        ```
        """
        let req = StoryCreationRequest(hero: "小兔子", heroEmoji: "🐰", setting: "大海", settingEmoji: "🌊", lesson: "勇敢", childName: "乐乐")
        let parsed = AIService.parseStoryJSON(fenced, fallbackRequest: req)
        XCTAssertNotNil(parsed)
        XCTAssertEqual(parsed?.title, "小兔子的彩虹船")
        XCTAssertEqual(parsed?.pages.count, 2)
        XCTAssertEqual(parsed?.pages[1].choices.count, 1)
        XCTAssertTrue(parsed?.isAIGenerated == true)
    }

    func testOfflineStoryComposerAndWhySearch() {
        let req = StoryCreationRequest(hero: "小恐龙咔咔", heroEmoji: "🦖", setting: "云朵城堡", settingEmoji: "☁️", lesson: "学会分享", childName: "朵朵")
        let story = StoryCatalog.composeOfflineStory(request: req)
        XCTAssertEqual(story.pages.count, 4)
        XCTAssertTrue(story.title.contains("小恐龙咔咔"))
        XCTAssertFalse(story.pages[2].choices.isEmpty)

        let matched = StoryCatalog.searchOfflineWhy(query: "为什么天空是蓝色的")
        XCTAssertEqual(matched.id, "why_sky")

        let fallback = StoryCatalog.searchOfflineWhy(query: "恐龙喜欢吃草莓蛋糕吗")
        XCTAssertFalse(fallback.kidExplanation.isEmpty)
    }

    @MainActor
    func testAppStorePersistenceHabitsAndStickers() {
        let suiteName = "SproutIsleTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let store = AppStore(defaults: defaults, storageKey: "test_state")
        let initialStars = store.state.totalStars

        let habit = HabitStickerCatalog.defaultHabits[0]
        XCTAssertTrue(store.toggleHabit(habit))
        XCTAssertTrue(store.isHabitCompletedToday(habit.id))
        XCTAssertEqual(store.state.totalStars, initialStars + habit.starReward)

        // Unlock a sticker with available stars
        let sticker = HabitStickerCatalog.stickers.first(where: { $0.starCost == 3 })!
        XCTAssertTrue(store.unlockSticker(sticker))
        XCTAssertTrue(store.isStickerUnlocked(sticker.id))

        // Reload from same UserDefaults and confirm persistence
        let reloaded = AppStore(defaults: defaults, storageKey: "test_state")
        XCTAssertEqual(reloaded.state.totalStars, store.state.totalStars)
        XCTAssertTrue(reloaded.isStickerUnlocked(sticker.id))
        XCTAssertTrue(reloaded.isHabitCompletedToday(habit.id))
    }

    @MainActor
    func testRealHumanVoicePackAndRoboticVoiceFilter() throws {
        // Verify Eloquence / novelty robotic voices are strictly blocked
        XCTAssertTrue(SpeechService.isRoboticVoice(identifier: "com.apple.eloquence.zh-CN.Eddy", name: "Eddy"))
        XCTAssertTrue(SpeechService.isRoboticVoice(identifier: "com.apple.speech.synthesis.voice.Albert", name: "Albert"))
        XCTAssertFalse(SpeechService.isRoboticVoice(identifier: "com.apple.voice.enhanced.zh-CN.Tingting", name: "Tingting"))
        XCTAssertFalse(SpeechService.isRoboticVoice(identifier: "com.apple.ttsbundle.siri_Yu-shu_zh-CN_compact", name: "Yu-shu"))

        // Verify bundled neural voice manifest loads and resolves greeting audio
        let speech = SpeechService()
        XCTAssertGreaterThan(speech.bundledVoiceCount, 100)
        XCTAssertNotNil(speech.bundledVoiceURL(for: "你好呀！今天想去哪座小岛探险呢？"))
        XCTAssertNotNil(speech.bundledVoiceURL(for: "A is for Apple!"))

        // Verify backward-compatible PersistedAppState decoding without ttsSettings key
        let legacyJSON = #"{"totalStars": 12}"#.data(using: .utf8)!
        let decoded = try JSONDecoder().decode(PersistedAppState.self, from: legacyJSON)
        XCTAssertEqual(decoded.totalStars, 12)
        XCTAssertTrue(decoded.ttsSettings.useBundledNeuralVoices)
        XCTAssertTrue(decoded.ttsSettings.preferParentRecordings)
    }
}
