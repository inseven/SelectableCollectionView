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

import Carbon
import SwiftUI

import SelectableCollectionViewMacResources

import Interact

#warning("TODO: Rename element to ID to avoid confusion?")

protocol CollectionViewContainerDelegate: NSObject {
    func collectionViewContainer<Element, Content>(_ collectionViewContainer: CollectionViewContainer<Element, Content>,
                                                   menuItemsForElements elements: Set<Element>) -> [MenuItem]
    func collectionViewContainer<Element, Content>(_ collectionViewContainer: CollectionViewContainer<Element, Content>,
                                                   contentForElement element: Element) -> Content?
    func collectionViewContainer<Element, Content>(_ collectionViewContainer: CollectionViewContainer<Element, Content>,
                                                   didUpdateSelection selection: Set<Element>)
    func collectionViewContainer<Element, Content>(_ collectionViewContainer: CollectionViewContainer<Element, Content>,
                                                   didDoubleClickSelection selection: Set<Element>)

    func collectionViewContainer<Element, Content>(_ collectionViewContainer: CollectionViewContainer<Element, Content>,
                                                   keyDown event: NSEvent) -> Bool
    func collectionViewContainer<Element, Content>(_ collectionViewContainer: CollectionViewContainer<Element, Content>,
                                                   keyUp event: NSEvent) -> Bool
}

class CustomScrollView: NSScrollView {

    override func keyDown(with event: NSEvent) {
        if event.keyCode == kVK_Space {
            nextResponder?.keyDown(with: event)
            return
        }
        super.keyDown(with: event)
    }

    override func keyUp(with event: NSEvent) {
        if event.keyCode == kVK_Space {
            nextResponder?.keyUp(with: event)
            return
        }
        super.keyUp(with: event)
    }

}

public class CollectionViewContainer<Element: Hashable, Content: View>: NSView, NSCollectionViewDelegate, CustomCollectionViewMenuDelegate, NSCollectionViewDelegateFlowLayout {

    weak var delegate: CollectionViewContainerDelegate?

    enum Section {
        case none
    }

    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Element>
    typealias DataSource = NSCollectionViewDiffableDataSource<Section, Element>
    typealias Cell = ShortcutItemView

    private let scrollView: CustomScrollView
    private let collectionView: CustomCollectionView
    private var dataSource: DataSource? = nil

    var provider: ((Element) -> Content?)? = nil

    init(layout: NSCollectionViewLayout) {

        scrollView = CustomScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = true
        scrollView.autohidesScrollers = false

        collectionView = CustomCollectionView()
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.collectionViewLayout = layout
        super.init(frame: .zero)

        dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, item in
            guard let view = collectionView.makeItem(withIdentifier: ShortcutItemView.identifier, for: indexPath) as? ShortcutItemView,
                  let content = self.delegate?.collectionViewContainer(self, contentForElement: item)
            else {
                return ShortcutItemView()
            }
            view.configure(AnyView(content))
            view.element = item
            return view
        }

        self.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        scrollView.documentView = collectionView
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        collectionView.menuDelegate = self

        let itemNib = NSNib(nibNamed: "ShortcutItemView", bundle: Resources.bundle)
        collectionView.register(itemNib, forItemWithIdentifier: ShortcutItemView.identifier)
        collectionView.register(ShortcutItemView.self, forItemWithIdentifier: ShortcutItemView.identifier)

        collectionView.isSelectable = true
        collectionView.allowsMultipleSelection = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @MainActor func update(_ items: [Element], selection: Set<Element>) {

        // Update the items.
        var snapshot = Snapshot()
        snapshot.appendSections([.none])
        snapshot.appendItems(items, toSection: Section.none)
        dataSource!.apply(snapshot, animatingDifferences: true)

        // Update the hosted item content.
        for item in collectionView.visibleItems() {
            guard let item = item as? ShortcutItemView,
                  let element = item.element as? Element else {
                continue
            }
            let content = self.delegate?.collectionViewContainer(self, contentForElement: element)
            item.configure(AnyView(content))
        }

        // Update the selection
        let indexPaths = selection.compactMap { element in
            return dataSource?.indexPath(for: element)
        }
        collectionView.selectionIndexPaths = Set(indexPaths)

    }

    @MainActor func updateLayout(_ layout: NSCollectionViewLayout) {
        collectionView.animator().collectionViewLayout = layout
    }

    @objc func menuItem(sender: NSMenuItem) {
        guard let action = sender.representedObject as? () -> Void else {
            return
        }
        action()
    }

    func customCollectionView(_ customCollectionView: CustomCollectionView,
                              contextMenuForSelection _: IndexSet) -> NSMenu? {

        guard let menuItems = delegate?.collectionViewContainer(self, menuItemsForElements: selectedElements),
              !menuItems.isEmpty
        else {
            return nil
        }
        let menu = NSMenu()
        menu.items = menuItems.map { menuItem in
            switch menuItem.itemType {
            case .item(let title, _, _, let action):
                let menuItem = NSMenuItem(title: title,
                                          action: menuItem.isDisabled ? nil : #selector(menuItem(sender:)),
                                          keyEquivalent: "")
                menuItem.representedObject = action
                return menuItem
            case .separator:
                return NSMenuItem.separator()
            }
        }
        return menu
    }

    var selectedElements: Set<Element> {
        return Set(collectionView.selectionIndexPaths.compactMap { dataSource?.itemIdentifier(for: $0) })
    }

    func updateSelection() {
        delegate?.collectionViewContainer(self, didUpdateSelection: selectedElements)
    }

    func customCollectionView(_ customCollectionView: CustomCollectionView, didUpdateSelection selection: Set<IndexPath>) {
        updateSelection()
    }

    func customCollectionView(_ customCollectionView: CustomCollectionView, didDoubleClickSelection selection: Set<IndexPath>) {
        delegate?.collectionViewContainer(self, didDoubleClickSelection: selectedElements)
    }

    public func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        updateSelection()
    }

    public func collectionView(_ collectionView: NSCollectionView, didDeselectItemsAt indexPaths: Set<IndexPath>) {
        updateSelection()
    }

    var collectionViewLayout: NSCollectionViewLayout? {
        return collectionView.collectionViewLayout
    }

    public override func keyDown(with event: NSEvent) {
        if delegate?.collectionViewContainer(self, keyDown: event) ?? false {
            return
        }
        super.keyDown(with: event)
    }

    public override func keyUp(with event: NSEvent) {
        if delegate?.collectionViewContainer(self, keyUp: event) ?? false {
            return
        }
        super.keyUp(with: event)
    }

}

#endif
