import SwiftUI

enum TimerTypography {
    static func display(size: CGFloat) -> Font {
        .system(size: size, weight: .medium)
    }

    static let menuBar = display(size: 13)
    static let popover = display(size: 36)
}
