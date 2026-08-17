import AppKit
import SwiftUI

final class GlassPanelViewController<Content: View>: NSViewController {
    private let effectView = NSVisualEffectView()
    private let frostOverlay = NSView()
    private let hostingController: NSHostingController<Content>

    init(rootView: Content) {
        hostingController = NSHostingController(rootView: rootView)
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        effectView.material = .menu
        effectView.blendingMode = .behindWindow
        effectView.state = .followsWindowActiveState
        effectView.isEmphasized = false
        effectView.wantsLayer = true
        effectView.layer?.cornerRadius = 16
        effectView.layer?.cornerCurve = .continuous
        effectView.layer?.masksToBounds = true

        frostOverlay.wantsLayer = true
        frostOverlay.layer?.backgroundColor = NSColor.white.withAlphaComponent(0.01).cgColor
        frostOverlay.translatesAutoresizingMaskIntoConstraints = false

        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.wantsLayer = true
        hostingController.view.layer?.backgroundColor = NSColor.clear.cgColor

        effectView.addSubview(frostOverlay)
        effectView.addSubview(hostingController.view)

        NSLayoutConstraint.activate([
            frostOverlay.leadingAnchor.constraint(equalTo: effectView.leadingAnchor),
            frostOverlay.trailingAnchor.constraint(equalTo: effectView.trailingAnchor),
            frostOverlay.topAnchor.constraint(equalTo: effectView.topAnchor),
            frostOverlay.bottomAnchor.constraint(equalTo: effectView.bottomAnchor),

            hostingController.view.leadingAnchor.constraint(equalTo: effectView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: effectView.trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: effectView.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: effectView.bottomAnchor),
        ])

        view = effectView
    }
}
