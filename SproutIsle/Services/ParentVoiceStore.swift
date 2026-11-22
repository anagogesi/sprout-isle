import AVFoundation
import Foundation
import Observation

enum ParentVoiceCategory: String, CaseIterable, Identifiable, Sendable {
    case greetings = "欢迎与鼓励"
    case habits = "好习惯表扬"
    case stories = "绘本故事朗读"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .greetings: return "💛"
        case .habits: return "🌟"
        case .stories: return "📖"
        }
    }
}

struct ParentVoiceSlot: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let scriptText: String
    let category: ParentVoiceCategory
    let emoji: String
}

@MainActor
@Observable
final class ParentVoiceStore: NSObject {
    private let directoryURL: URL
    private var recorder: AVAudioRecorder?
    private var meterTask: Task<Void, Never>?

    var recordedSlotIds: Set<String> = []
    var activeRecordingSlotId: String?
    var recordingLevel: Float = 0
    var recordingDuration: TimeInterval = 0
    var recorderNotice: String?

    private(set) var allSlots: [ParentVoiceSlot] = []
    private var slotIdByExactText: [String: String] = [:]

    override init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        self.directoryURL = docs.appendingPathComponent("ParentVoices", isDirectory: true)
        super.init()
        try? FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        buildCatalog()
        refreshRecordedIds()
    }

    private func buildCatalog() {
        var slots: [ParentVoiceSlot] = [
            ParentVoiceSlot(
                id: "greet_home",
                title: "首页问候语",
                scriptText: "你好呀！今天想去哪座小岛探险呢？",
                category: .greetings,
                emoji: "🌱"
            ),
            ParentVoiceSlot(
                id: "greet_literacy",
                title: "进入汉字谷",
                scriptText: "欢迎来到汉字谷！我们来认识汉字和拼音吧！",
                category: .greetings,
                emoji: "📖"
            ),
            ParentVoiceSlot(
                id: "greet_math",
                title: "进入数字屋",
                scriptText: "欢迎来到数字屋！一起数一数，算一算！",
                category: .greetings,
                emoji: "🔢"
            ),
            ParentVoiceSlot(
                id: "greet_stories",
                title: "进入故事树",
                scriptText: "欢迎来到故事树！想听绘本故事，还是问十万个为什么呢？",
                category: .greetings,
                emoji: "🌳"
            ),
            ParentVoiceSlot(
                id: "praise_story_done",
                title: "读完绘本表扬",
                scriptText: "故事讲完啦！你真棒！",
                category: .greetings,
                emoji: "🏆"
            ),
        ]

        for habit in HabitStickerCatalog.defaultHabits {
            slots.append(
                ParentVoiceSlot(
                    id: "habit_\(habit.id)",
                    title: "表扬：\(habit.title)",
                    scriptText: habit.encourageText,
                    category: .habits,
                    emoji: habit.emoji
                )
            )
        }

        for book in StoryCatalog.builtInStories {
            for (idx, page) in book.pages.enumerated() {
                slots.append(
                    ParentVoiceSlot(
                        id: "story_\(page.id)",
                        title: "《\(book.title)》第 \(idx + 1) 页 · \(page.title)",
                        scriptText: "\(page.title)。\(page.narration)",
                        category: .stories,
                        emoji: book.coverEmoji
                    )
                )
            }
        }

        self.allSlots = slots
        var map: [String: String] = [:]
        for slot in slots {
            map[slot.scriptText.trimmingCharacters(in: .whitespacesAndNewlines)] = slot.id
        }
        self.slotIdByExactText = map
    }

    func slots(for category: ParentVoiceCategory) -> [ParentVoiceSlot] {
        allSlots.filter { $0.category == category }
    }

    func fileURL(for slotId: String) -> URL {
        directoryURL.appendingPathComponent("\(slotId).m4a")
    }

    func hasRecording(for slotId: String) -> Bool {
        recordedSlotIds.contains(slotId)
    }

    func recordedURL(for slotKey: String?, matchingText text: String) -> URL? {
        if let slotKey, recordedSlotIds.contains(slotKey) {
            let url = fileURL(for: slotKey)
            if FileManager.default.fileExists(atPath: url.path) {
                return url
            }
        }
        let cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if let matchedId = slotIdByExactText[cleaned], recordedSlotIds.contains(matchedId) {
            let url = fileURL(for: matchedId)
            if FileManager.default.fileExists(atPath: url.path) {
                return url
            }
        }
        return nil
    }

    func refreshRecordedIds() {
        let files = (try? FileManager.default.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil)) ?? []
        recordedSlotIds = Set(files.filter { $0.pathExtension == "m4a" }.map { $0.deletingPathExtension().lastPathComponent })
    }

    func startRecording(for slot: ParentVoiceSlot) {
        stopRecording()
        recorderNotice = nil

        Task { @MainActor in
            let granted = await AVAudioApplication.requestRecordPermission()
            guard granted else {
                self.recorderNotice = "请在系统设置中允许小芽岛使用麦克风，才能录制爸爸妈妈的声音哦。"
                return
            }
            self.beginRecorder(for: slot)
        }
    }

    private func beginRecorder(for slot: ParentVoiceSlot) {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try session.setActive(true)
        } catch {
            recorderNotice = "麦克风初始化失败：\(error.localizedDescription)"
            return
        }

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44_100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
            AVEncoderBitRateKey: 64_000,
        ]

        let targetURL = fileURL(for: slot.id)
        do {
            let newRecorder = try AVAudioRecorder(url: targetURL, settings: settings)
            newRecorder.isMeteringEnabled = true
            guard newRecorder.record() else {
                recorderNotice = "当前设备无法开启录音（模拟器可连接 Mac 麦克风或在真机录制）。"
                return
            }
            recorder = newRecorder
            activeRecordingSlotId = slot.id
            recordingDuration = 0
            startMetering()
        } catch {
            recorderNotice = "录音启动失败：\(error.localizedDescription)"
        }
    }

    func stopRecording() {
        meterTask?.cancel()
        meterTask = nil
        if let recorder {
            recorder.stop()
            self.recorder = nil
        }
        activeRecordingSlotId = nil
        recordingLevel = 0
        refreshRecordedIds()
    }

    func deleteRecording(for slotId: String) {
        if activeRecordingSlotId == slotId {
            stopRecording()
        }
        try? FileManager.default.removeItem(at: fileURL(for: slotId))
        refreshRecordedIds()
    }

    private func startMetering() {
        meterTask?.cancel()
        meterTask = Task { @MainActor [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(80))
                guard let self, let recorder = self.recorder, recorder.isRecording else { break }
                recorder.updateMeters()
                let power = recorder.averagePower(forChannel: 0)
                let normalized = max(0.05, min(1.0, (power + 50) / 50))
                self.recordingLevel = normalized
                self.recordingDuration = recorder.currentTime
            }
        }
    }
}
