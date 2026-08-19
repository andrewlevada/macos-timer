import AppKit
import SwiftUI

final class GlassPanelViewController<Content: View>: NSViewController {
    private let effectView = NSVisualEffectView()
    private let hostingView: PanelHostingView<Content>

    init(rootView: Content) {
        hostingView = PanelHostingView(rootView: rootView)
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let cornerRadius = PanelLayout.cornerRadius

        effectView.material = .menu
        effectView.blendingMode = .behindWindow
        effectView.state = .followsWindowActiveState
        effectView.isEmphasized = false
        effectView.wantsLayer = true
        effectView.layer?.cornerRadius = cornerRadius
        effectView.layer?.cornerCurve = .continuous
        effectView.layer?.masksToBounds = true

        hostingView.translatesAutoresizingMaskIntoConstraints = false

        effectView.addSubview(hostingView)

        NSLayoutConstraint.activate([
            hostingView.leadingAnchor.constraint(equalTo: effectView.leadingAnchor),
            hostingView.trailingAnchor.constraint(equalTo: effectView.trailingAnchor),
            hostingView.topAnchor.constraint(equalTo: effectView.topAnchor),
            hostingView.bottomAnchor.constraint(equalTo: effectView.bottomAnchor),
        ])

        view = effectView
    }
}

final class PanelHostingView<Content: View>: NSHostingView<Content> {
    override var isOpaque: Bool { false }

    required init(rootView: Content) {
        super.init(rootView: rootView)
        configureLayer()
    }

    @MainActor
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureLayer() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
        layer?.cornerRadius = PanelLayout.cornerRadius
        layer?.cornerCurve = .continuous
        layer?.masksToBounds = true
    }
}
