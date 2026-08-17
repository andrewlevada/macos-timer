import SwiftUI

enum PanelLayout {
    static let width: CGFloat = 320
    static let height: CGFloat = 152
    static let contentHeight: CGFloat = 120
}

enum TimerTheme {
    static let panelBorder = Color.white.opacity(0.34)
    static let tick = Color(white: 0.72, opacity: 0.32)
    static let indicator = Color(white: 0.98, opacity: 0.95)
    static let label = Color.white
    static let labelMuted = Color(white: 0.78, opacity: 0.42)

    static let tickHeight: CGFloat = 34
    static let tickLineWidth: CGFloat = 1
}

enum TimerTypography {
    static func display(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight)
    }

    static let menuBar = display(size: 13, weight: .medium)
    static let preset = display(size: 13, weight: .medium)
    static let action = display(size: 15, weight: .medium)
    static let readout = display(size: 40, weight: .regular)
}
