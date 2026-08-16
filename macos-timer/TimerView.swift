import SwiftUI

struct TimerView: View {
    @EnvironmentObject private var timer: TimerModel

    private let presets = [1, 5, 10, 15, 25, 45, 60]

    var body: some View {
        VStack(spacing: 16) {
            Text(timer.menuBarText)
                .font(.system(size: 36, weight: .medium, design: .rounded))
                .monospacedDigit()
                .contentTransition(.numericText())

            if timer.state == .running || timer.state == .paused {
                ProgressView(value: timer.progress)
                    .progressViewStyle(.linear)
            }

            if timer.state == .idle || timer.state == .finished {
                presetGrid
                Stepper(
                    "\(timer.selectedMinutes) min",
                    value: Binding(
                        get: { timer.selectedMinutes },
                        set: { timer.setMinutes($0) }
                    ),
                    in: 1...180
                )
            }

            HStack(spacing: 8) {
                switch timer.state {
                case .idle, .finished:
                    Button("Start") { timer.start() }
                        .keyboardShortcut(.defaultAction)
                case .running:
                    Button("Pause") { timer.pause() }
                    Button("Reset") { timer.reset() }
                case .paused:
                    Button("Resume") { timer.start() }
                        .keyboardShortcut(.defaultAction)
                    Button("Reset") { timer.reset() }
                }
            }

            Divider()

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
        }
        .padding(20)
        .frame(width: 240)
        .onAppear {
            timer.requestNotificationPermission()
        }
    }

    private var presetGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))], spacing: 8) {
            ForEach(presets, id: \.self) { minutes in
                Button("\(minutes)m") {
                    timer.setMinutes(minutes)
                }
                .buttonStyle(.bordered)
                .tint(timer.selectedMinutes == minutes ? .accentColor : .secondary)
            }
        }
    }
}
