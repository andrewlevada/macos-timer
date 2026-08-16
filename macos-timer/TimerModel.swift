import Foundation
import UserNotifications

@MainActor
final class TimerModel: ObservableObject {
    enum State {
        case idle
        case running
        case paused
        case finished
    }

    @Published private(set) var state: State = .idle
    @Published private(set) var remainingSeconds: Int = 0
    @Published var selectedMinutes: Int = 5

    private var endDate: Date?
    private var tickTask: Task<Void, Never>?

    var menuBarText: String {
        switch state {
        case .idle:
            return Self.formatTime(selectedMinutes * 60)
        case .running, .paused:
            return Self.formatTime(remainingSeconds)
        case .finished:
            return Self.formatTime(0)
        }
    }

    var progress: Double {
        let total = selectedMinutes * 60
        guard total > 0 else { return 0 }
        return 1 - Double(remainingSeconds) / Double(total)
    }

    func start() {
        switch state {
        case .idle, .finished:
            remainingSeconds = selectedMinutes * 60
            endDate = Date().addingTimeInterval(TimeInterval(remainingSeconds))
            state = .running
            startTicking()
        case .paused:
            endDate = Date().addingTimeInterval(TimeInterval(remainingSeconds))
            state = .running
            startTicking()
        case .running:
            break
        }
    }

    func pause() {
        guard state == .running else { return }
        tickTask?.cancel()
        tickTask = nil
        state = .paused
    }

    func reset() {
        tickTask?.cancel()
        tickTask = nil
        endDate = nil
        remainingSeconds = selectedMinutes * 60
        state = .idle
    }

    func setMinutes(_ minutes: Int) {
        guard state == .idle || state == .finished else { return }
        selectedMinutes = max(1, min(180, minutes))
        remainingSeconds = selectedMinutes * 60
    }

    private func startTicking() {
        tickTask?.cancel()
        tickTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { break }
                self?.tick()
            }
        }
    }

    private func tick() {
        guard let endDate else { return }
        remainingSeconds = max(0, Int(endDate.timeIntervalSinceNow.rounded(.up)))

        if remainingSeconds <= 0 {
            finish()
        }
    }

    private func finish() {
        tickTask?.cancel()
        tickTask = nil
        self.endDate = nil
        remainingSeconds = 0
        state = .finished
        notifyFinished()
    }

    private func notifyFinished() {
        let content = UNMutableNotificationContent()
        content.title = "Timer finished"
        content.body = "Your \(selectedMinutes)-minute timer is done."

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    static func formatTime(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        }
        return String(format: "%02d:%02d", minutes, secs)
    }
}
