import SwiftUI

struct TimerView: View {
    @EnvironmentObject private var timer: TimerModel

    private let presets = [5, 10, 15, 30, 45, 60]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            DurationScrubberView(
                seconds: Binding(
                    get: { timer.selectedSeconds },
                    set: { timer.setDuration($0) }
                ),
                isEnabled: timer.isEditable
            )
            .frame(maxWidth: .infinity)

            presetRow

            bottomRow

            if !timer.isEditable {
                HStack {
                    Button("reset") {
                        timer.reset()
                    }
                    .buttonStyle(SecondaryActionButtonStyle())

                    Spacer()
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 10)
        .padding(.top, 6)
        .padding(.bottom, 9)
        .frame(width: 320)
        .background {
            ZStack {
                GlassBackground(cornerRadius: 16)

                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(TimerTheme.glassTint)

                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [TimerTheme.glassHighlight, .clear],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )

                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(TimerTheme.panelBorder, lineWidth: 0.5)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .onAppear {
            timer.requestNotificationPermission()
        }
    }

    private var presetRow: some View {
        HStack(spacing: 0) {
            HStack(spacing: 16) {
                ForEach(presets, id: \.self) { minutes in
                    Button(presetLabel(for: minutes)) {
                        timer.setPreset(minutes: minutes)
                    }
                    .buttonStyle(PresetButtonStyle())
                    .disabled(!timer.isEditable)
                }
            }

            Spacer(minLength: 8)

            Menu {
                Button("quit") {
                    NSApplication.shared.terminate(nil)
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(TimerTheme.labelMuted)
            }
            .menuStyle(.borderlessButton)
            .menuIndicator(.hidden)
            .fixedSize()
        }
        .frame(maxWidth: .infinity)
    }

    private var bottomRow: some View {
        HStack(alignment: .lastTextBaseline) {
            Button(primaryActionTitle) {
                performPrimaryAction()
            }
            .buttonStyle(ActionButtonStyle())
            .disabled(timer.state == .finished)

            Spacer()

            Text(TimerModel.formatTime(timer.readoutSeconds))
                .font(TimerTypography.readout)
                .monospacedDigit()
                .foregroundStyle(TimerTheme.label)
                .contentTransition(.numericText())
        }
    }

    private func presetLabel(for minutes: Int) -> String {
        minutes == 60 ? "1h" : "\(minutes)m"
    }

    private var primaryActionTitle: String {
        switch timer.state {
        case .idle, .finished:
            return "start"
        case .running:
            return "pause"
        case .paused:
            return "resume"
        }
    }

    private func performPrimaryAction() {
        switch timer.state {
        case .idle, .finished:
            timer.start()
        case .running:
            timer.pause()
        case .paused:
            timer.start()
        }
    }
}

private struct PresetButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(TimerTypography.preset)
            .foregroundStyle(TimerTheme.label)
            .opacity(configuration.isPressed ? 0.65 : 1)
    }
}

private struct ActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(TimerTypography.action)
            .foregroundStyle(TimerTheme.label)
            .opacity(configuration.isPressed ? 0.65 : 1)
    }
}

private struct SecondaryActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(TimerTypography.preset)
            .foregroundStyle(TimerTheme.labelMuted)
            .opacity(configuration.isPressed ? 0.65 : 1)
    }
}
