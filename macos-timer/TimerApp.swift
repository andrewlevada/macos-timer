import SwiftUI

@main
struct TimerApp: App {
    @StateObject private var timer = TimerModel()

    var body: some Scene {
        MenuBarExtra {
            TimerView()
                .environmentObject(timer)
        } label: {
            Text(timer.menuBarText)
                .monospacedDigit()
        }
        .menuBarExtraStyle(.window)
    }
}
