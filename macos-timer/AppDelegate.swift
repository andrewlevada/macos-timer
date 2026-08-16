import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusBarController: StatusBarController?
    private let timer = TimerModel()

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusBarController = StatusBarController(timer: timer)
        timer.requestNotificationPermission()
    }
}
