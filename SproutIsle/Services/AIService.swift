import Foundation
import Security

enum KeychainHelper {
    private static let service = "org.anagogesi.sproutisle.ai"
    private static let aiAccount = "openai_compatible_api_key"
    private static let ttsAccount = "openai_compatible_tts_api_key"

    static func saveAPIKey(_ key: String) {
        save(key, account: aiAccount)
    }

    static func loadAPIKey() -> String {
        load(account: aiAccount)
    }

    static func deleteAPIKey() {
        delete(account: aiAccount)
    }

    static func saveTTSAPIKey(_ key: String) {
        save(key, account: ttsAccount)
    }

    static func loadTTSAPIKey() -> String {
        load(account: ttsAccount)
    }

    static func deleteTTSAPIKey() {
        delete(account: ttsAccount)
    }

    private static func save(_ key: String, account: String) {
        let trimmed = key.trimmingCharacters(in: .whitespacesAndNewlines)
        delete(account: account)
        guard !trimmed.isEmpty, let data = trimmed.data(using: .utf8) else { return }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
        ]
        SecItemAdd(query as CFDictionary, nil)
    }

    private static func load(account: String) -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data else { return "" }
        return String(data: data, encoding: .utf8) ?? ""
    }

    private static func delete(account: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
        SecItemDelete(query as CFDictionary)
    }
}

struct AIGenerationOutcome<Value: Sendable>: Sendable {
    let value: Value
    let fromLiveAI: Bool
    let statusNote: String
}

enum AIServiceError: LocalizedError {
    case invalidURL
    case httpError(Int, String)
    case emptyResponse

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "API 地址格式不正确，请检查是否包含 http:// 或 https://"
        case let .httpError(code, body):
            return "接口返回错误 (\(code))：\(body.prefix(120))"
        case .emptyResponse:
            return "模型没有返回有效内容"
        }
    }
}

struct AIService: Sendable {
    private struct ChatMessage: Encodable {
        let role: String
        let content: String
    }

    private struct ChatCompletionRequest: Encodable {
        let model: String
        let messages: [ChatMessage]
        let temperature: Double
        let max_tokens: Int
    }

    private struct ChatCompletionResponse: Decodable {
        struct Choice: Decodable {
            struct Message: Decodable {
                let content: String?
            }
            let message: Message
        }
        let choices: [Choice]
    }

    private struct RawStoryPayload: Decodable {
        struct RawChoice: Decodable {
            let label: String
            let emoji: String?
            let outcomeText: String
            let outcomeEmoji: String?
        }
        struct RawPage: Decodable {
            let title: String
            let narration: String
            let sceneEmoji: String?
            let secondaryEmoji: String?
            let choicePrompt: String?
            let choices: [RawChoice]?
        }
        let title: String
        let subtitle: String?
        let coverEmoji: String?
        let moral: String?
        let pages: [RawPage]
    }

    private struct RawWhyPayload: Decodable {
        let shortAnswer: String
        let kidExplanation: String
        let funActivity: String?
        let emoji: String?
    }

    func testConnection(settings: AISettings, apiKey: String) async -> Result<String, Error> {
        do {
            let reply = try await sendChatCompletion(
                settings: settings,
                apiKey: apiKey,
                systemPrompt: "你是小芽岛儿童学习助手。请用一句简短温暖的中文打招呼。",
                userPrompt: "请回复：小芽岛连接成功！",
                maxTokens: 60
            )
            return .success(reply.trimmingCharacters(in: .whitespacesAndNewlines))
        } catch {
            return .failure(error)
        }
    }

    func generatePictureBook(
        request: StoryCreationRequest,
        settings: AISettings,
        apiKey: String
    ) async -> AIGenerationOutcome<StoryBook> {
        guard settings.isEnabled else {
            return AIGenerationOutcome(
                value: StoryCatalog.composeOfflineStory(request: request),
                fromLiveAI: false,
                statusNote: "离线童话工坊已创作完成（可在家长小屋开启 AI 实时创作）"
            )
        }

        let systemPrompt = """
        你是一位专门给 3-6 岁中国小朋友写睡前绘本的温暖童话作家。
        要求：
        1. 语言温柔、有画面感、积极安全，绝对不出现恐怖、暴力或危险情节。
        2. 严格返回纯 JSON，不要加任何解释文字。
        3. JSON 结构为：
        {"title":"故事名","subtitle":"副标题","coverEmoji":"🐰","moral":"一句暖心寄语","pages":[{"title":"页标题","narration":"40-70字绘本旁白","sceneEmoji":"🌟","secondaryEmoji":"🌿","choicePrompt":null,"choices":[]}]}
        4. 共 4 页，在第 3 页提供 2 个互动 choices（每个含 label, emoji, outcomeText, outcomeEmoji）。
        """

        let userPrompt = "请为 \(request.childName) 写一个 4 页绘本：主角是\(request.hero)，场景在\(request.setting)，主题是「\(request.lesson)」。"

        do {
            let content = try await sendChatCompletion(
                settings: settings,
                apiKey: apiKey,
                systemPrompt: systemPrompt,
                userPrompt: userPrompt,
                maxTokens: 900
            )
            if let book = Self.parseStoryJSON(content, fallbackRequest: request) {
                return AIGenerationOutcome(
                    value: book,
                    fromLiveAI: true,
                    statusNote: "AI 魔法绘本已为你量身创作！"
                )
            }
            let fallback = StoryCatalog.composeOfflineStory(request: request)
            return AIGenerationOutcome(
                value: fallback,
                fromLiveAI: false,
                statusNote: "AI 返回格式不完整，已自动切换离线童话工坊完成创作"
            )
        } catch {
            let fallback = StoryCatalog.composeOfflineStory(request: request)
            return AIGenerationOutcome(
                value: fallback,
                fromLiveAI: false,
                statusNote: "AI 暂未连上，已用离线魔法为你生成专属故事"
            )
        }
    }

    func askWhy(
        question: String,
        childAge: Int,
        settings: AISettings,
        apiKey: String
    ) async -> AIGenerationOutcome<WhyQAItem> {
        let trimmed = question.trimmingCharacters(in: .whitespacesAndNewlines)
        guard settings.isEnabled else {
            return AIGenerationOutcome(
                value: StoryCatalog.searchOfflineWhy(query: trimmed),
                fromLiveAI: false,
                statusNote: "来自小芽岛离线十万个为什么"
            )
        }

        let systemPrompt = """
        你是「小芽宝」，专门给 \(childAge) 岁小朋友回答「十万个为什么」的温暖科普老师。
        要求：
        1. 用简单可爱的比喻讲解科学道理，安全友善，不超过 120 字。
        2. 优先返回纯 JSON：{"shortAnswer":"一句话答案","kidExplanation":"通俗温暖的讲解","funActivity":"一个亲子小观察或小互动","emoji":"🌟"}
        """

        do {
            let content = try await sendChatCompletion(
                settings: settings,
                apiKey: apiKey,
                systemPrompt: systemPrompt,
                userPrompt: trimmed,
                maxTokens: 320
            )
            let item = Self.parseWhyResponse(content, question: trimmed)
            return AIGenerationOutcome(value: item, fromLiveAI: true, statusNote: "由 AI 科普老师实时解答")
        } catch {
            return AIGenerationOutcome(
                value: StoryCatalog.searchOfflineWhy(query: trimmed),
                fromLiveAI: false,
                statusNote: "AI 暂未连上，已从离线百科为你解答"
            )
        }
    }

    // MARK: - Networking

    private func sendChatCompletion(
        settings: AISettings,
        apiKey: String,
        systemPrompt: String,
        userPrompt: String,
        maxTokens: Int
    ) async throws -> String {
        let base = settings.baseURL.trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let endpoint = base.hasSuffix("/chat/completions") ? base : "\(base)/chat/completions"
        guard let url = URL(string: endpoint), let scheme = url.scheme, (scheme == "http" || scheme == "https") else {
            throw AIServiceError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.timeoutInterval = 25
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        }

        let body = ChatCompletionRequest(
            model: settings.modelName.isEmpty ? "llm-lab" : settings.modelName,
            messages: [
                ChatMessage(role: "system", content: systemPrompt),
                ChatMessage(role: "user", content: userPrompt),
            ],
            temperature: 0.75,
            max_tokens: maxTokens
        )
        urlRequest.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            let errBody = String(data: data, encoding: .utf8) ?? ""
            throw AIServiceError.httpError(http.statusCode, errBody)
        }

        let decoded = try JSONDecoder().decode(ChatCompletionResponse.self, from: data)
        guard let content = decoded.choices.first?.message.content, !content.isEmpty else {
            throw AIServiceError.emptyResponse
        }
        return content
    }

    // MARK: - Pure Parsers (unit-tested)

    static func extractJSONString(from raw: String) -> String {
        var text = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.hasPrefix("```") {
            if let firstNewline = text.firstIndex(of: "\n") {
                text = String(text[text.index(after: firstNewline)...])
            }
            if let closingRange = text.range(of: "```", options: .backwards) {
                text = String(text[..<closingRange.lowerBound])
            }
        }
        if let start = text.firstIndex(of: "{"), let end = text.lastIndex(of: "}") {
            return String(text[start...end])
        }
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func parseStoryJSON(_ raw: String, fallbackRequest: StoryCreationRequest) -> StoryBook? {
        let jsonString = extractJSONString(from: raw)
        guard let data = jsonString.data(using: .utf8),
              let payload = try? JSONDecoder().decode(RawStoryPayload.self, from: data),
              !payload.pages.isEmpty else {
            return nil
        }

        let palettes: [[String]] = [
            ["4EA8DE", "72EFDD"],
            ["FFB703", "FB8500"],
            ["9B72CF", "C77DFF"],
            ["34B37E", "80ED99"],
        ]

        let pages: [StoryPage] = payload.pages.enumerated().map { idx, page in
            let choices: [StoryChoice] = (page.choices ?? []).enumerated().map { cIdx, choice in
                StoryChoice(
                    id: "ai_c_\(idx)_\(cIdx)",
                    label: choice.label,
                    emoji: choice.emoji ?? "✨",
                    outcomeText: choice.outcomeText,
                    outcomeEmoji: choice.outcomeEmoji ?? "🎉"
                )
            }
            return StoryPage(
                id: "ai_p_\(idx)",
                title: page.title,
                narration: page.narration,
                sceneEmoji: page.sceneEmoji ?? fallbackRequest.heroEmoji,
                secondaryEmoji: page.secondaryEmoji ?? fallbackRequest.settingEmoji,
                gradientHexes: palettes[idx % palettes.count],
                choicePrompt: choices.isEmpty ? nil : (page.choicePrompt ?? "帮主角选一选："),
                choices: choices
            )
        }

        return StoryBook(
            id: "ai_story_\(UUID().uuidString.prefix(8))",
            title: payload.title,
            subtitle: payload.subtitle ?? "AI 为\(fallbackRequest.childName)创作的童话",
            coverEmoji: payload.coverEmoji ?? fallbackRequest.heroEmoji,
            themeTag: fallbackRequest.lesson,
            accentHex: "9B72CF",
            isAIGenerated: true,
            pages: pages,
            moral: payload.moral ?? "勇敢和好奇会陪你天天长大！"
        )
    }

    static func parseWhyResponse(_ raw: String, question: String) -> WhyQAItem {
        let jsonString = extractJSONString(from: raw)
        if let data = jsonString.data(using: .utf8),
           let payload = try? JSONDecoder().decode(RawWhyPayload.self, from: data) {
            return WhyQAItem(
                id: "ai_why_\(UUID().uuidString.prefix(8))",
                question: question,
                shortAnswer: payload.shortAnswer,
                kidExplanation: payload.kidExplanation,
                funActivity: payload.funActivity ?? "和爸爸妈妈一起聊一聊你最喜欢的发现吧！",
                emoji: payload.emoji ?? "💡",
                category: .life
            )
        }

        let cleanText = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        return WhyQAItem(
            id: "ai_why_\(UUID().uuidString.prefix(8))",
            question: question,
            shortAnswer: "小芽宝为你找到答案啦！",
            kidExplanation: cleanText,
            funActivity: "和爸爸妈妈分享今天学到的新知识吧！",
            emoji: "✨",
            category: .life
        )
    }
}
