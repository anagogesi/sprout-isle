import Foundation
import Observation

@MainActor
@Observable
final class EyeCareTimerService {
    var elapsedSeconds: Int = 0
    var showBreakOverlay: Bool = false
    var restCountdownSeconds: Int = 20

    private var sessionTask: Task<Void, Never>?
    private var restTask: Task<Void, Never>?

    func startMonitoring(limitMinutesProvider: @escaping @MainActor () -> Int) {
        sessionTask?.cancel()
        sessionTask = Task { @MainActor [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard let self else { return }
                let limitMinutes = limitMinutesProvider()
                guard limitMinutes > 0, !self.showBreakOverlay else { continue }
                self.elapsedSeconds += 1
                if self.elapsedSeconds >= limitMinutes * 60 {
                    self.triggerEyeCareBreak()
                }
            }
        }
    }

    func triggerEyeCareBreak() {
        showBreakOverlay = true
        restCountdownSeconds = 20
        restTask?.cancel()
        restTask = Task { @MainActor [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard let self else { return }
                if self.restCountdownSeconds > 0 {
                    self.restCountdownSeconds -= 1
                } else {
                    break
                }
            }
        }
    }

    func finishBreak() {
        restTask?.cancel()
        showBreakOverlay = false
        elapsedSeconds = 0
    }

    func stop() {
        sessionTask?.cancel()
        restTask?.cancel()
    }
}
