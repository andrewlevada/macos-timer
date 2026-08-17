import SwiftUI

struct PomodoroPresetEditorView: View {
    @Binding var preset: PomodoroPreset
    let onSave: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("preset")
                .font(TimerTypography.action)
                .foregroundStyle(TimerTheme.label)

            TextField("name", text: $preset.name)
                .textFieldStyle(.roundedBorder)

            Stepper("work: \(preset.workMinutes)m", value: $preset.workMinutes, in: 1...180)
            Stepper("break: \(preset.breakMinutes)m", value: $preset.breakMinutes, in: 1...60)
            Stepper("long break: \(preset.longBreakMinutes)m", value: $preset.longBreakMinutes, in: 1...60)
            Stepper("rounds before long break: \(preset.roundsBeforeLongBreak)", value: $preset.roundsBeforeLongBreak, in: 1...12)

            Toggle("auto-advance phases", isOn: $preset.autoAdvance)

            HStack {
                Button("cancel") { onCancel() }
                    .buttonStyle(SharedSecondaryActionButtonStyle())
                Spacer()
                Button("save") { onSave() }
                    .buttonStyle(SharedActionButtonStyle())
            }
        }
        .padding(16)
        .frame(width: 300)
        .background(Color(white: 0.12))
    }
}
