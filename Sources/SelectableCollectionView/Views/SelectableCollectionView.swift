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

import SwiftUI

public struct SelectableCollectionView<Data: RandomAccessCollection, Content: View>: NSViewRepresentable where Data.Element: Identifiable, Data.Element: Hashable, Data.Element.ID: Hashable {

    public typealias ID = Data.Element.ID
    public typealias Element = Data.Element

    public class Coordinator: NSObject, CollectionViewContainerDelegate {

        var parent: SelectableCollectionView<Data, Content>

        init(_ parent: SelectableCollectionView<Data, Content>) {
            self.parent = parent
        }

        func collectionViewContainer<Element, Content>(_ collectionViewContainer: CollectionViewContainer<Element, Content>,
                                                       menuItemsForElements elements: Set<Element>) -> [MenuItem] where Element : Hashable, Content : View {
            guard let elements = elements as? Set<Data.Element> else {
                return []
            }
            return parent.contextMenu(elements)
        }

        func collectionViewContainer<Element, Content>(_ collectionViewContainer: CollectionViewContainer<Element, Content>, contentForElement element: Element) -> Content? where Element : Hashable, Content : View {
#warning("TODO: These guards shouldn't be necessary?")
            guard let element = element as? Data.Element,
                  let content = parent.rowContent(element) as? Content else {
                return nil
            }
            return content
        }

        func collectionViewContainer<Element, Content>(_ collectionViewContainer: CollectionViewContainer<Element, Content>, didUpdateSelection selection: Set<Element>) where Element : Hashable, Content : View {
            guard let selection = selection as? Set<Data.Element> else {
                return
            }
            let ids = selection.map({ $0.id })
            parent.selection.wrappedValue = Set(ids)
        }

    }

#warning("TODO: These should be lets")
    let items: Data
    let selection: Binding<Set<Data.Element.ID>>
    let layout: any Layoutable
    let rowContent: (Data.Element) -> Content
    let contextMenu: (Set<Data.Element>) -> [MenuItem]

    func element(for id: Data.Element.ID) -> Data.Element? {
#warning("TODO: This doesn't perform well.")
        return items.first { $0.id == id }
    }

    public init(_ items: Data,
                selection: Binding<Set<Data.Element.ID>>,
                layout: any Layoutable,
                @ViewBuilder rowContent: @escaping (Data.Element) -> Content,
                @MenuItemBuilder contextMenu: @escaping (Set<Data.Element>) -> [MenuItem]) {
        self.items = items
        self.selection = selection
        self.layout = layout
        self.rowContent = rowContent
        self.contextMenu = contextMenu
    }

    public func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    public func makeNSView(context: Context) -> CollectionViewContainer<Element, Content> {
        let collectionView = CollectionViewContainer<Element, Content>(layout: layout.makeLayout())
        collectionView.delegate = context.coordinator
        return collectionView
    }

    public func updateNSView(_ collectionView: CollectionViewContainer<Element, Content>, context: Context) {
        context.coordinator.parent = self
        // TODO: We shouldn't need to copy this into an array?
        let selectedElements = items.filter { selection.wrappedValue.contains($0.id) }
        collectionView.update(Array(items), selection: Set(selectedElements))
    }

}
