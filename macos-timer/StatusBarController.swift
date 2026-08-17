import AppKit
import Combine
import SwiftUI

@MainActor
final class StatusBarController: NSObject {
    private let timer: TimerModel
    private var statusItem: NSStatusItem?
    private var hostingView: MenuBarHostingView<MenuBarTimerLabel>?
    private var panel: TimerFloatingPanel?
    private var localClickMonitor: Any?
    private var globalClickMonitor: Any?
    private var resignActiveObserver: NSObjectProtocol?
    private var cancellables = Set<AnyCancellable>()

    init(timer: TimerModel) {
        self.timer = timer
        super.init()
        setupStatusItem()
        observeTimer()
    }

    deinit {
        if let localClickMonitor {
            NSEvent.removeMonitor(localClickMonitor)
        }
        if let globalClickMonitor {
            NSEvent.removeMonitor(globalClickMonitor)
        }
        if let resignActiveObserver {
            NotificationCenter.default.removeObserver(resignActiveObserver)
        }
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        guard let button = statusItem?.button else { return }

        button.action = #selector(togglePanel)
        button.target = self
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])

        updateLabel()
    }

    private func observeTimer() {
        timer.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateLabel()
            }
            .store(in: &cancellables)
    }

    private func updateLabel() {
        guard let button = statusItem?.button else { return }

        let label = MenuBarTimerLabel(text: timer.menuBarText)

        if let hostingView {
            hostingView.rootView = label
            hostingView.invalidateIntrinsicContentSize()
        } else {
            let hostingView = MenuBarHostingView(rootView: label)
            hostingView.translatesAutoresizingMaskIntoConstraints = false
            button.addSubview(hostingView)
            NSLayoutConstraint.activate([
                hostingView.leadingAnchor.constraint(equalTo: button.leadingAnchor),
                hostingView.trailingAnchor.constraint(equalTo: button.trailingAnchor),
                hostingView.topAnchor.constraint(equalTo: button.topAnchor),
                hostingView.bottomAnchor.constraint(equalTo: button.bottomAnchor),
            ])
            self.hostingView = hostingView
        }

        let size = hostingView?.fittingSize ?? .zero
        statusItem?.length = max(size.width, 44)
    }

    @objc private func togglePanel() {
        if let panel, panel.isVisible {
            closePanel()
            return
        }

        guard let button = statusItem?.button else { return }

        let hostingController = NSHostingController(
            rootView: TimerView().environmentObject(timer)
        )
        hostingController.view.wantsLayer = true
        hostingController.view.layer?.backgroundColor = NSColor.clear.cgColor

        let panel = TimerFloatingPanel(contentViewController: hostingController)
        self.panel = panel

        let panelWidth: CGFloat = 320
        let panelHeight: CGFloat = 190
        let origin = panelOrigin(for: button, width: panelWidth, height: panelHeight)
        panel.setFrame(NSRect(origin: origin, size: NSSize(width: panelWidth, height: panelHeight)), display: true)
        panel.makeKeyAndOrderFront(nil)
        startOutsideClickMonitoring()
    }

    private func panelOrigin(for button: NSStatusBarButton, width: CGFloat, height: CGFloat) -> NSPoint {
        if let window = button.window {
            let buttonFrame = button.convert(button.bounds, to: nil)
            let screenFrame = window.convertToScreen(buttonFrame)
            return NSPoint(
                x: screenFrame.midX - width / 2,
                y: screenFrame.minY - height - 8
            )
        }

        let mouseLocation = NSEvent.mouseLocation
        return NSPoint(
            x: mouseLocation.x - width / 2,
            y: mouseLocation.y - height - 8
        )
    }

    private func startOutsideClickMonitoring() {
        stopOutsideClickMonitoring()

        localClickMonitor = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            guard let self else { return event }

            if event.window === self.panel || self.isClickOnStatusItem() {
                return event
            }

            Task { @MainActor in
                self.closePanel()
            }

            return event
        }

        globalClickMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            Task { @MainActor in
                self?.closePanel()
            }
        }

        resignActiveObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didResignActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.closePanel()
            }
        }
    }

    private func stopOutsideClickMonitoring() {
        if let localClickMonitor {
            NSEvent.removeMonitor(localClickMonitor)
            self.localClickMonitor = nil
        }

        if let globalClickMonitor {
            NSEvent.removeMonitor(globalClickMonitor)
            self.globalClickMonitor = nil
        }

        if let resignActiveObserver {
            NotificationCenter.default.removeObserver(resignActiveObserver)
            self.resignActiveObserver = nil
        }
    }

    private func closePanel() {
        guard let panel, panel.isVisible else { return }
        stopOutsideClickMonitoring()
        panel.orderOut(nil)
    }

    private func isClickOnStatusItem() -> Bool {
        guard let button = statusItem?.button, let window = button.window else { return false }

        let clickLocation = NSEvent.mouseLocation
        let buttonFrame = window.convertToScreen(button.convert(button.bounds, to: nil))
        return buttonFrame.contains(clickLocation)
    }
}
