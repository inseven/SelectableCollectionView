// Copyright (c) 2022-2026 Jason Morley
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

class CollectionViewCell<ID: Hashable, Content: View>: NSCollectionViewItem {

    static var identifier: NSUserInterfaceItemIdentifier {
        return NSUserInterfaceItemIdentifier(rawValue: "CollectionViewCell")
    }

    private var hostingView: NSHostingView<CollectionViewCellContent<ID, Content>>?
    private var id: ID?
    private var content: Content?
    private var parentHasFocus: Bool = false
    private var parentIsKey: Bool = false

    override var isSelected: Bool {
        didSet {
            updateState()
        }
    }

    override var highlightState: NSCollectionViewItem.HighlightState {
        didSet {
            updateState()
        }
    }

    override func loadView() {
        view = NSView()
    }

    func configure(_ content: Content?, id: ID?, parentHasFocus: Bool, parentIsKey: Bool) {
        self.content = content
        self.id = id
        self.parentHasFocus = parentHasFocus
        self.parentIsKey = parentIsKey
        host()
    }

    private func updateState() {
        host()
    }

    private func host() {

        guard content != nil || hostingView != nil else {
            return
        }

        let selectionColor = parentHasFocus && parentIsKey
            ? Color(nsColor: .selectedContentBackgroundColor)
            : Color(nsColor: .unemphasizedSelectedContentBackgroundColor)
        let rootView = CollectionViewCellContent(id: id,
                                                content: content,
                                                isSelected: isSelected,
                                                highlightState: .init(highlightState),
                                                selectionColor: selectionColor)

        guard let hostingView else {
            let hostingView = NSHostingView(rootView: rootView)
            hostingView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(hostingView)
            NSLayoutConstraint.activate([
                hostingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                hostingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                hostingView.topAnchor.constraint(equalTo: view.topAnchor),
                hostingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])
            self.hostingView = hostingView
            return
        }
        hostingView.rootView = rootView
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        configure(nil, id: nil, parentHasFocus: false, parentIsKey: false)
    }

}

#endif
