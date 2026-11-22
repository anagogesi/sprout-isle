import AVFoundation
import Foundation
import Observation
import UIKit

enum KidSoundEffect: Sendable {
    case tap
    case correct
    case tryAgain
    case star
    case celebration
}

@MainActor
@Observable
final class SoundEffectService {
    private var engine: AVAudioEngine?
    private var player: AVAudioPlayerNode?
    private let sampleRate: Double = 44_100
    var isEnabled: Bool = true

    func play(_ effect: KidSoundEffect) {
        triggerHaptic(for: effect)
        guard isEnabled else { return }

        let notes: [(frequency: Double, duration: Double, volume: Float)]
        switch effect {
        case .tap:
            notes = [(523.25, 0.08, 0.16)]
        case .correct:
            notes = [(523.25, 0.10, 0.20), (659.25, 0.10, 0.22), (783.99, 0.16, 0.24)]
        case .tryAgain:
            notes = [(392.00, 0.11, 0.15), (329.63, 0.14, 0.14)]
        case .star:
            notes = [(783.99, 0.09, 0.20), (1046.50, 0.20, 0.22)]
        case .celebration:
            notes = [(523.25, 0.09, 0.20), (659.25, 0.09, 0.21), (783.99, 0.09, 0.22), (1046.50, 0.24, 0.25)]
        }

        scheduleToneSequence(notes)
    }

    private func triggerHaptic(for effect: KidSoundEffect) {
        switch effect {
        case .tap:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .correct, .star:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .celebration:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .tryAgain:
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        }
    }

    private func ensureEngineStarted() -> (AVAudioEngine, AVAudioPlayerNode)? {
        if let engine, let player, engine.isRunning {
            return (engine, player)
        }
        let newEngine = AVAudioEngine()
        let newPlayer = AVAudioPlayerNode()
        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1) else {
            return nil
        }
        newEngine.attach(newPlayer)
        newEngine.connect(newPlayer, to: newEngine.mainMixerNode, format: format)
        do {
            try newEngine.start()
            newPlayer.play()
            self.engine = newEngine
            self.player = newPlayer
            return (newEngine, newPlayer)
        } catch {
            return nil
        }
    }

    private func scheduleToneSequence(_ notes: [(frequency: Double, duration: Double, volume: Float)]) {
        guard let (_, player) = ensureEngineStarted(),
              let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1) else {
            return
        }

        let totalFrames = notes.reduce(0) { $0 + Int(sampleRate * $1.duration) }
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(totalFrames)),
              let channelData = buffer.floatChannelData?[0] else {
            return
        }
        buffer.frameLength = AVAudioFrameCount(totalFrames)

        var cursor = 0
        for note in notes {
            let frames = Int(sampleRate * note.duration)
            for i in 0..<frames {
                let t = Double(i) / sampleRate
                let progress = Double(i) / Double(max(1, frames))
                let attack = min(1.0, progress / 0.08)
                let decay = pow(1.0 - progress, 1.8)
                let envelope = Float(attack * decay) * note.volume
                let fundamental = sin(2.0 * .pi * note.frequency * t)
                let overtone = 0.25 * sin(2.0 * .pi * note.frequency * 2.0 * t)
                channelData[cursor + i] = Float(fundamental + overtone) * envelope
            }
            cursor += frames
        }

        player.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
    }
}
