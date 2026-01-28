// Copyright (c) 2022-2024 Jason Morley
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
import Combine
import SwiftUI

import SelectableCollectionViewMacResources

// TODO: Rename element to ID to avoid confusion?

public protocol CollectionViewContainerDelegate: NSObject {

    associatedtype Element: Hashable & Identifiable
    associatedtype CellContent: View

    func collectionViewContainer(_ collectionViewContainer: CollectionViewContainer<Element, CellContent, Self>,
                                 menuItemsForElements elements: Set<Element>) -> [MenuItem]
    func collectionViewContainer(_ collectionViewContainer: CollectionViewContainer<Element, CellContent, Self>,
                                 contentForElement element: Element) -> CellContent?
    func collectionViewContainer(_ collectionViewContainer: CollectionViewContainer<Element, CellContent, Self>,
                                 didUpdateSelection selection: Set<Element>)
    func collectionViewContainer(_ collectionViewContainer: CollectionViewContainer<Element, CellContent, Self>,
                                 didDoubleClickSelection selection: Set<Element>)

    func collectionViewContainer(_ collectionViewContainer: CollectionViewContainer<Element, CellContent, Self>,
                                 keyDown event: NSEvent) -> Bool
    func collectionViewContainer(_ collectionViewContainer: CollectionViewContainer<Element, CellContent, Self>,
                                 keyUp event: NSEvent) -> Bool
}

public class CollectionViewContainer<Element: Hashable, Content: View, Delegate: CollectionViewContainerDelegate>
: NSView,
  NSCollectionViewDelegate,
  CollectionViewInteractionDelegate,
  CollectionViewProxy,
  NSCollectionViewDelegateFlowLayout where Delegate.Element == Element,
                                           Delegate.CellContent == Content {

    weak var delegate: Delegate?

    enum Section {
        case none
    }

    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Element>
    typealias DataSource = NSCollectionViewDiffableDataSource<Section, Element>
    typealias Cell = ShortcutItemView

    private let scrollView: CustomScrollView
    private let collectionView: InteractiveCollectionView
    private var dataSource: DataSource! = nil
    private var cancellables: Set<AnyCancellable> = []

    var provider: ((Element) -> Content?)? = nil

    init(layout: NSCollectionViewLayout) {

        scrollView = CustomScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = true
        scrollView.autohidesScrollers = false

        collectionView = InteractiveCollectionView()
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.collectionViewLayout = layout
        super.init(frame: .zero)

        dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, item in
            guard let view = collectionView.makeItem(withIdentifier: ShortcutItemView.identifier, for: indexPath) as? ShortcutItemView,
                  let content = self.delegate?.collectionViewContainer(self, contentForElement: item)
            else {
                return ShortcutItemView()
            }
            view.configure(AnyView(content),
                           parentHasFocus: collectionView.isFirstResponder,
                           parentIsKey: collectionView.window?.isKeyWindow ?? false)
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
        collectionView.interactionDelegate = self

        let itemNib = NSNib(nibNamed: "ShortcutItemView", bundle: Resources.bundle)
        collectionView.register(itemNib, forItemWithIdentifier: ShortcutItemView.identifier)
        collectionView.register(ShortcutItemView.self, forItemWithIdentifier: ShortcutItemView.identifier)

        collectionView.isSelectable = true
        collectionView.allowsMultipleSelection = true

        // Observe application activity notifications to allow us to update the selection color.
        let notificationCenter = NotificationCenter.default
        notificationCenter
            .publisher(for: NSApplication.didBecomeActiveNotification)
            .combineLatest(notificationCenter
                .publisher(for: NSApplication.didResignActiveNotification))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateSelection()
            }
            .store(in: &cancellables)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // TODO: Take in a set of items to compare with and we can maybe do an intersection?
    private func updateVisibleItems() {
        // Update the hosted item content.
        for item in collectionView.visibleItems() {
            guard let item = item as? ShortcutItemView,
                  let element = item.element as? Element else {
                continue
            }
            let content = self.delegate?.collectionViewContainer(self, contentForElement: element)
            item.configure(AnyView(content),
                           parentHasFocus: collectionView.isFirstResponder,
                           parentIsKey: collectionView.window?.isKeyWindow ?? false)
        }
    }

    @MainActor private func update(_ items: [Element], selection: Set<Element>) {

        // Update the items.
        var snapshot = Snapshot()
        snapshot.appendSections([.none])
        snapshot.appendItems(items, toSection: Section.none)
        dataSource.apply(snapshot, animatingDifferences: true)

        updateVisibleItems()

        // Update the selection
        let indexPaths = selection.compactMap { element in
            return dataSource?.indexPath(for: element)
        }

        // Updating the selection at the same time as the items seems to cause some form of loop or deadlock, so we
        // break that by dispatching back to the main queue.
        DispatchQueue.main.async {
            self.collectionView.selectionIndexPaths = Set(indexPaths)
        }

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

    func contextMenu(for menuItems: [MenuItem]) -> NSMenu {
        let menu = NSMenu()
        menu.items = menuItems.map { menuItem in
            switch menuItem.itemType {
            case .item(let title, let systemImage, _, let action):
                let menuItem = NSMenuItem(title: title,
                                          action: menuItem.isDisabled ? nil : #selector(menuItem(sender:)),
                                          keyEquivalent: "")
                if let systemImage {
                    menuItem.image = NSImage(systemSymbolName: systemImage, accessibilityDescription: nil)
                }
                menuItem.representedObject = action
                return menuItem
            case .separator:
                return NSMenuItem.separator()
            case .menu(let title, _, let menuItems):
                let menuItem = NSMenuItem(title: title, action: nil, keyEquivalent: "")
                menuItem.submenu = contextMenu(for: menuItems)
                return menuItem
            }
        }
        return menu
    }

    func collectionView(_ collectionView : InteractiveCollectionView,
                        contextMenuForSelection _: Set<IndexPath>) -> NSMenu? {

        guard let menuItems = delegate?.collectionViewContainer(self, menuItemsForElements: selectedElements),
              !menuItems.isEmpty
        else {
            return nil
        }
        return contextMenu(for: menuItems)
    }

    var selectedElements: Set<Element> {
        return Set(collectionView.selectionIndexPaths.compactMap { dataSource?.itemIdentifier(for: $0) })
    }

    func updateSelection() {
        // We dispatch this back onto the main loop to ensure we're not updating state in a SwiftUI render.
        DispatchQueue.main.async {
            self.delegate?.collectionViewContainer(self, didUpdateSelection: self.selectedElements)
        }
    }

    func collectionView(_ collectionView: InteractiveCollectionView, didUpdateSelection selection: Set<IndexPath>) {
        updateSelection()
    }

    func collectionView(_ collectionView: InteractiveCollectionView, didDoubleClickSelection selection: Set<IndexPath>) {
        delegate?.collectionViewContainer(self, didDoubleClickSelection: selectedElements)
    }

    func collectionView(_ collectionView: InteractiveCollectionView, didUpdateFocus isFirstResponder: Bool) {
        updateSelection()
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

    public func setItems(_ items: [Element]) {
        dispatchPrecondition(condition: .onQueue(.main))

        var snapshot = Snapshot()
        snapshot.appendSections([.none])
        snapshot.appendItems(items, toSection: Section.none)

        dataSource.apply(snapshot, animatingDifferences: true)

        // TODO: Update the selection?
    }

    public func insertItem(_ item: Element, atIndex index: Int, items: [Element]) {
        dispatchPrecondition(condition: .onQueue(.main))

        var snapshot = dataSource.snapshot()
        if snapshot.numberOfSections < 1 {
            snapshot.appendSections([.none])
        }
        if index < snapshot.itemIdentifiers.count {
            let beforeItem = snapshot.itemIdentifiers[index]
            snapshot.insertItems([item], beforeItem: beforeItem)
        } else if index == snapshot.itemIdentifiers.count {
            snapshot.appendItems([item])
        } else {
            fatalError("Attempting to insert an item at an index beyond the end of the list.")
        }

        dataSource.apply(snapshot, animatingDifferences: true)
    }

    public func updateItem(_ item: Element, atIndex index: Int, items: [Element]) {
        dispatchPrecondition(condition: .onQueue(.main))
        var snapshot = dataSource.snapshot()
        snapshot.reloadItems([item])
        dataSource.apply(Snapshot(), animatingDifferences: true)
    }

    public func removeItem(_ item: Element, atIndex index: Int, items: [Element]) {
        dispatchPrecondition(condition: .onQueue(.main))
        var snapshot = dataSource.snapshot()
        guard snapshot.itemIdentifiers.contains(item) else {
            fatalError("Attempted to remove item not in list.")
        }
        snapshot.deleteItems([item])
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    // Apple's API always assumes the to index is the place to move _before_.
    public func moveItem(_ item: Element, toIndex index: Int, items: [Element]) {
        dispatchPrecondition(condition: .onQueue(.main))
        var snapshot = dataSource.snapshot()
        guard let fromIndex = snapshot.indexOfItem(item) else {
            fatalError("Attempted to move item not in list.")
        }
        if fromIndex == index || fromIndex + 1 == index {  // TODO: Make this a guard.
            return
        }
        guard fromIndex < snapshot.itemIdentifiers.count else {
            fatalError("Attempted to move item from an index beyond the end of the list.")
        }
        guard index <= snapshot.itemIdentifiers.count else {
            fatalError("Attempted to move item to an index beyond the end of the list.")
        }

        // We have to be incredibly careful of the ordering here as the destination index is dependent on whether the
        // source locaiton is after or before.

        if index == snapshot.itemIdentifiers.count {
            snapshot.moveItem(item, afterItem: snapshot.itemIdentifiers.last!)
        } else {
            snapshot.moveItem(item, beforeItem: snapshot.itemIdentifiers[index])
        }

//        if toIndex == 0 {
//            snapshot.moveItem(item, beforeItem: snapshot.itemIdentifiers[toIndex])
//        } else {
//            snapshot.moveItem(item, afterItem: snapshot.itemIdentifiers[toIndex - 1])
//        }
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    // TODO: Support moves.

}

#endif
