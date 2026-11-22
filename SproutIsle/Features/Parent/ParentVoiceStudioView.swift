import SwiftUI

struct ParentVoiceStudioView: View {
    @Environment(ParentVoiceStore.self) private var parentVoices
    @Environment(SpeechService.self) private var speech

    @State private var selectedCategory: ParentVoiceCategory = .greetings

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Intro Banner
                ToyCard(background: Color(hex: "FFF9EC"), border: IslandTheme.amber.opacity(0.6), cornerRadius: 24, padding: 16) {
                    HStack(spacing: 12) {
                        Text("🎙️")
                            .font(.system(size: 40))
                        VStack(alignment: .leading, spacing: 4) {
                            Text("录制爸爸妈妈的专属声音")
                                .font(.kidHeadline(18))
                                .foregroundStyle(IslandTheme.inkDark)
                            Text("录好后，宝贝在首页、打卡和读绘本时会优先听到你的真实声音（已录制 \(parentVoices.recordedSlotIds.count) 段）。")
                                .font(.kidCaption(13))
                                .foregroundStyle(IslandTheme.inkSoft)
                        }
                    }
                }

                if let notice = parentVoices.recorderNotice {
                    Text(notice)
                        .font(.kidCaption(14))
                        .foregroundStyle(IslandTheme.coralDark)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(RoundedRectangle(cornerRadius: 14).fill(Color(hex: "FFE8E8")))
                }

                // Category tabs
                HStack(spacing: 8) {
                    ForEach(ParentVoiceCategory.allCases) { cat in
                        let active = cat == selectedCategory
                        Button {
                            selectedCategory = cat
                        } label: {
                            HStack(spacing: 5) {
                                Text(cat.emoji)
                                Text(cat.rawValue)
                                    .font(.kidCaption(14))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.85)
                            }
                            .foregroundStyle(active ? .white : IslandTheme.inkDark)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(active ? IslandTheme.mint : Color.white)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }

                // Recording slots list
                VStack(spacing: 12) {
                    ForEach(parentVoices.slots(for: selectedCategory)) { slot in
                        slotCard(slot)
                    }
                }
            }
            .padding(16)
        }
        .background(IslandTheme.creamCanvas.ignoresSafeArea())
        .navigationTitle("爸妈亲声录制室")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            parentVoices.stopRecording()
            speech.stopSpeaking()
        }
    }

    private func slotCard(_ slot: ParentVoiceSlot) -> some View {
        let isRecording = parentVoices.activeRecordingSlotId == slot.id
        let hasRecorded = parentVoices.hasRecording(for: slot.id)

        return ToyCard(cornerRadius: 22, padding: 14) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("\(slot.emoji) \(slot.title)")
                        .font(.kidHeadline(16))
                        .foregroundStyle(IslandTheme.inkDark)
                    Spacer()
                    if hasRecorded {
                        Text("💛 已录制")
                            .font(.kidCaption(12))
                            .foregroundStyle(IslandTheme.mintDark)
                            .padding(.horizontal, 9)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(Color(hex: "E6F8EE")))
                    }
                }

                Text("“\(slot.scriptText)”")
                    .font(.kidBody(15))
                    .foregroundStyle(IslandTheme.inkSoft)
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(hex: "F8FAFC")))

                if isRecording {
                    HStack(spacing: 10) {
                        Circle()
                            .fill(IslandTheme.coral)
                            .frame(width: 10, height: 10)
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule().fill(Color(hex: "FFE5E5"))
                                Capsule()
                                    .fill(IslandTheme.coral)
                                    .frame(width: max(12, geo.size.width * CGFloat(parentVoices.recordingLevel)))
                                    .animation(.linear(duration: 0.08), value: parentVoices.recordingLevel)
                            }
                        }
                        .frame(height: 10)
                        Text(String(format: "%.1fs", parentVoices.recordingDuration))
                            .font(.kidCaption(13))
                            .foregroundStyle(IslandTheme.coralDark)
                            .monospacedDigit()
                    }
                }

                HStack(spacing: 10) {
                    Button {
                        if isRecording {
                            parentVoices.stopRecording()
                        } else {
                            speech.stopSpeaking()
                            parentVoices.startRecording(for: slot)
                        }
                    } label: {
                        Label(isRecording ? "停止录音" : (hasRecorded ? "重新录制" : "开始录音"),
                              systemImage: isRecording ? "stop.fill" : "mic.fill")
                            .font(.kidCaption(14))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 9)
                            .background(Capsule().fill(isRecording ? IslandTheme.coral : IslandTheme.mint))
                    }
                    .buttonStyle(.plain)

                    if hasRecorded && !isRecording {
                        Button {
                            speech.previewAudioFile(at: parentVoices.fileURL(for: slot.id), source: .parentRecording)
                        } label: {
                            Label("试听原声", systemImage: "play.fill")
                                .font(.kidCaption(14))
                                .foregroundStyle(IslandTheme.lagoonDark)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 9)
                                .background(Capsule().fill(Color(hex: "E6F4FC")))
                        }
                        .buttonStyle(.plain)

                        Spacer()

                        Button(role: .destructive) {
                            parentVoices.deleteRecording(for: slot.id)
                        } label: {
                            Image(systemName: "trash")
                                .font(.system(size: 15))
                                .foregroundStyle(IslandTheme.coralDark)
                                .padding(8)
                        }
                        .buttonStyle(.plain)
                    } else {
                        Button {
                            speech.speak(slot.scriptText, language: .chinese)
                        } label: {
                            Label("听默认范读", systemImage: "speaker.wave.2")
                                .font(.kidCaption(13))
                                .foregroundStyle(IslandTheme.inkSoft)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 9)
                                .background(Capsule().fill(Color(hex: "F1F5F9")))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}
