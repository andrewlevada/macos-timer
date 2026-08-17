import SwiftUI

struct MenuBarTimerLabel: View {
    let text: String?
    let showsTomatoIcon: Bool

    init(text: String) {
        self.text = text
        self.showsTomatoIcon = false
    }

    init(text: String?, showsTomatoIcon: Bool) {
        self.text = text
        self.showsTomatoIcon = showsTomatoIcon
    }

    var body: some View {
        HStack(spacing: 4) {
            if showsTomatoIcon {
                TomatoIcon()
                    .frame(width: 13, height: 13)
            }

            if let text {
                Text(text)
                    .font(TimerTypography.menuBar)
                    .monospacedDigit()
            }
        }
        .padding(.horizontal, 7)
        .padding(.vertical, 3)
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .strokeBorder(Color(nsColor: .labelColor).opacity(0.55), lineWidth: 1)
        }
    }
}
