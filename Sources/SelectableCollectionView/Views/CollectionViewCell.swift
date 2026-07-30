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

/**
 * Hosts a cell's content, injecting the state the collection view holds about it.
 *
 * Keeping this a named type means the hosting view has a single concrete root view type for the lifetime of the cell,
 * so updating the content is a plain `rootView` assignment that SwiftUI can diff.
 *
 * The content is tagged with the identifier of the element it represents. Cells are recycled, and a recycled cell is
 * reconfigured with its new content in the same turn of the run loop that empties it, so SwiftUI never observes the
 * intermediate empty state and would otherwise carry the previous element's `State` over to the new one -- showing, for
 * example, a stale image until the replacement loads. Tying identity to the element instead makes SwiftUI discard that
 * state whenever the cell changes element, regardless of how it was recycled.
 */
struct CollectionViewCellContent<ID: Hashable, Content: View>: View {

    let id: ID?
    let content: Content?
    let isSelected: Bool
    let highlightState: CollectionViewItemHighlightState
    let selectionColor: Color

    var body: some View {
        if let content, let id {
            content
                .environment(\.isSelected, isSelected)
                .environment(\.highlightState, highlightState)
                .environment(\.selectionColor, selectionColor)
                .id(id)
        }
    }

}

/**
 * A collection view item which hosts SwiftUI content of a known type.
 *
 * Being generic over the content type means neither the cell nor the collection view has to erase to `AnyView`, letting
 * SwiftUI diff the hosted content and preserve its state across updates.
 */
class CollectionViewCell<ID: Hashable, Content: View>: NSCollectionViewItem {

    // Static stored properties aren't permitted in generic types, but a computed one is fine. Each collection view
    // hosts exactly one content type, so a single identifier is sufficient.
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

    // `NSCollectionViewItem` needs a view, which would usually come from a nib. Since `NSViewController` finds that nib
    // by class name and a specialized generic class has a mangled runtime name, we create the view in code instead.
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

        // Avoid loading the view -- and creating a hosting view -- just to show nothing. This also stops selection
        // changes during initialization from forcing the view to load early.
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
