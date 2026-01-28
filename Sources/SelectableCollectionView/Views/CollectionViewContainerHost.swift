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

import SwiftUI

public struct CollectionViewContainerHost<E, Content: View>
: NSViewRepresentable where E: Identifiable,
                            E: Hashable,
                            E.ID: Hashable {

    public typealias ID = E.ID
    public typealias Element = E

    public final class Coordinator: NSObject, CollectionViewContainerDelegate {

        public typealias Element = E
        public typealias CellContent = Content

        var parent: CollectionViewContainerHost<Element, Content>
        var collectionViewLayoutHash: Int = 0

        init(_ parent: CollectionViewContainerHost<Element, Content>) {
            self.parent = parent
        }

        public func collectionViewContainer(_ collectionViewContainer: CollectionViewContainer<Element, Content, Coordinator>,
                                            menuItemsForIds ids: Set<Element.ID>) -> [MenuItem] {
            return parent.contextMenu(ids)
        }

        public func collectionViewContainer(_ collectionViewContainer: CollectionViewContainer<Element, Content, Coordinator>,
                                            contentForElement element: Element) -> Content? {
            return parent.itemContent(element)
        }

        public func collectionViewContainer(_ collectionViewContainer: CollectionViewContainer<Element, Content, Coordinator>,
                                            didUpdateSelection selection: Set<Element.ID>) {
            parent.selection.wrappedValue = selection
        }

        public func collectionViewContainer(_ collectionViewContainer: CollectionViewContainer<Element, Content, Coordinator>,
                                            didDoubleClickSelection selection: Set<Element.ID>) {
            parent.primaryAction(selection)
        }

        public func collectionViewContainer(_ collectionViewContainer: CollectionViewContainer<Element, Content, Coordinator>,
                                            keyDown event: NSEvent) -> Bool {
            return parent.keyDown(event)
        }

        public func collectionViewContainer(_ collectionViewContainer: CollectionViewContainer<Element, Content, Coordinator>,
                                            keyUp event: NSEvent) -> Bool {
            return parent.keyUp(event)
        }

    }

    let items: AnyCollectionViewManagedCollection<E>
    let selection: Binding<Set<E.ID>>
    let layout: any Layoutable
    let itemContent: (E) -> Content
    let contextMenu: (Set<E.ID>) -> [MenuItem]
    let primaryAction: (Set<E.ID>) -> ()
    let keyDown: (NSEvent) -> Bool
    let keyUp: (NSEvent) -> Bool

    init(_ items: AnyCollectionViewManagedCollection<E>,
         selection: Binding<Set<E.ID>>,
         layout: any Layoutable,
         @ViewBuilder itemContent: @escaping (E) -> Content,
         @MenuItemBuilder contextMenu: @escaping (Set<E.ID>) -> [MenuItem],
         primaryAction: @escaping (Set<E.ID>) -> Void,
         keyDown: @escaping (NSEvent) -> Bool = { _ in return false },
         keyUp: @escaping (NSEvent) -> Bool = { _ in return false }) {
        self.items = items // TODO: Rename to collection??
        self.selection = selection
        self.layout = layout
        self.itemContent = itemContent
        self.contextMenu = contextMenu
        self.primaryAction = primaryAction
        self.keyDown = keyDown
        self.keyUp = keyUp
    }

    public func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    public func makeNSView(context: Context) -> CollectionViewContainer<E, Content, Coordinator> {
        let collectionView = CollectionViewContainer<E, Content, Coordinator>(layout: layout.makeLayout())
        collectionView.delegate = context.coordinator
        items.collectionViewDidConnect(collectionView)
        if !items.supportsIncrementalUpdates {
            items.update()
        }
        return collectionView
    }

    public func updateNSView(_ collectionView: CollectionViewContainer<E, Content, Coordinator>, context: Context) {
        context.coordinator.parent = self
        // TODO: There needs to be a path for preparing the selection. The filtering should be done by the collection view though.
//                let selectedElements = items.filter { selection.wrappedValue.contains($0.id) }
//        collectionView.update(Array(items), selection: Set(selectedElements))

        // First, ensure the visible items re-evaluate their hosted SwiftUI views.
        collectionView.updateVisibleItems()

        // Next, we manually apply changes to the collection view if our collection doesn't automatically apply updates.
        if !items.supportsIncrementalUpdates {
            items.collectionViewDidConnect(collectionView)
            items.update()
        }

        // And finally, we apply a new layout if necessary.
        // It actually looks like this might not be safe to do while also applying updates, so it's possible that we
        // need to somehow gate this operation.
        if context.coordinator.collectionViewLayoutHash != layout.hashValue {
            let collectionViewLayout = layout.makeLayout()
            collectionView.updateLayout(collectionViewLayout)
            context.coordinator.collectionViewLayoutHash = layout.hashValue
        }
    }
}

#endif
