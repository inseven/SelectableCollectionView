// Copyright (c) 2022 Jason Morley
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#if os(macOS)

import SwiftUI

import SelectableCollectionViewMacResources

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
        super.init(nibName: nil, bundle: Resources.bundle)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func host(_ content: AnyView) {
        let modifiedContent = AnyView(content
            .environment(\.isSelected, isSelected)
            .environment(\.highlightState, .init(highlightState)))
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

#warning("TODO: Not sure if this is necessary")
    override func prepareForReuse() {
        super.prepareForReuse()
        configure(AnyView(EmptyView()))
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

#endif
