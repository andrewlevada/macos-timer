import AppKit
import Combine
import SwiftUI

@MainActor
final class StatusBarController: NSObject {
    private let timer: TimerModel
    private var statusItem: NSStatusItem?
    private var hostingView: NSHostingView<MenuBarTimerLabel>?
    private var popover: NSPopover?
    private var cancellables = Set<AnyCancellable>()

    init(timer: TimerModel) {
        self.timer = timer
        super.init()
        setupStatusItem()
        observeTimer()
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        guard let button = statusItem?.button else { return }

        button.action = #selector(togglePopover)
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
            let hostingView = NSHostingView(rootView: label)
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

    @objc private func togglePopover() {
        guard let button = statusItem?.button else { return }

        if let popover, popover.isShown {
            popover.performClose(nil)
            return
        }

        let popover = NSPopover()
        popover.contentSize = NSSize(width: 240, height: 320)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(
            rootView: TimerView().environmentObject(timer)
        )
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        self.popover = popover
    }
}
