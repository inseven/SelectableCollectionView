import SwiftUI

#warning("TODO: Can we type this internally?")
class ShortcutItemView: NSCollectionViewItem {

    static let identifier = NSUserInterfaceItemIdentifier(rawValue: "CollectionViewItem")

    private var hostingView: NSHostingView<AnyView>?
    private var content: AnyView?
    var element: Any?

    override var isSelected: Bool {
        didSet {
            updateState()
        }
    }

    func updateState() {
        guard let content = content else {
            return
        }
        host(content)
    }

    override var highlightState: NSCollectionViewItem.HighlightState {
        didSet {
            updateState()
        }
    }

    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: .module)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func host(_ content: AnyView) {
        let modifiedContent = AnyView(content
            .environment(\.isSelected, isSelected)
            .environment(\.highlightState, highlightState))
        if let hostingView = hostingView {
            hostingView.rootView = modifiedContent
        } else {
            let newHostingView = NSHostingView(rootView: modifiedContent)
            newHostingView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(newHostingView)
            setupConstraints(for: newHostingView)
            self.hostingView = newHostingView
        }
    }

#warning("TODO: Called by the data source")
#warning("TODO: This should take an item")
    func configure(_ content: AnyView) {
        self.content = content
        host(content)
    }

    func setupConstraints(for view: NSView) {
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            view.topAnchor.constraint(equalTo: self.view.topAnchor),
            view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ])
    }

}

