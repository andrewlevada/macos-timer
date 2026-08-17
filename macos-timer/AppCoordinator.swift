import Combine
import Foundation

@MainActor
final class AppCoordinator: ObservableObject {
    enum PanelTab: Hashable {
        case simple
        case pomodoro
    }

    let simpleTimer: TimerModel
    let pomodoro: PomodoroModel

    @Published var selectedPanel: PanelTab = .simple

    private var cancellables = Set<AnyCancellable>()

    init(simpleTimer: TimerModel, pomodoro: PomodoroModel) {
        self.simpleTimer = simpleTimer
        self.pomodoro = pomodoro
        observeTimers()
    }

    var menuBarText: String? {
        if pomodoro.isSessionActive {
            return pomodoro.menuBarText
        }
        if simpleTimer.state == .running || simpleTimer.state == .paused {
            return simpleTimer.menuBarText
        }
        if selectedPanel == .pomodoro {
            return nil
        }
        return simpleTimer.menuBarText
    }

    var menuBarShowsTomatoIcon: Bool {
        !pomodoro.isSessionActive
            && simpleTimer.state != .running
            && simpleTimer.state != .paused
            && selectedPanel == .pomodoro
    }

    func startPomodoro(preset: PomodoroPreset) {
        if simpleTimer.state == .running || simpleTimer.state == .paused {
            simpleTimer.reset()
        }
        pomodoro.start(preset: preset)
    }

    private func observeTimers() {
        simpleTimer.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self else { return }
                self.objectWillChange.send()
                if self.simpleTimer.state == .running {
                    self.pomodoro.stopSession()
                }
            }
            .store(in: &cancellables)

        pomodoro.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
}
