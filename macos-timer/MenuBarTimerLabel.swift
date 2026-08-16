import SwiftUI

struct MenuBarTimerLabel: View {
    let text: String

    var body: some View {
        Text(text)
            .font(TimerTypography.menuBar)
            .monospacedDigit()
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(Color(nsColor: .labelColor).opacity(0.55), lineWidth: 1)
            }
    }
}
