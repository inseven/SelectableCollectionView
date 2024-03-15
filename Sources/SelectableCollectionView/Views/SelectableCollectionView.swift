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

import Interact

#if os(macOS)

public struct SelectableCollectionView<Data: RandomAccessCollection,
                                       Content: View>: View where Data.Element: Identifiable,
                                                                  Data.Element: Hashable,
                                                                  Data.Element.ID: Hashable {

    let items: Data
    let selection: Binding<Set<Data.Element.ID>>
    let layout: any Layoutable
    let itemContent: (Data.Element) -> Content
    let contextMenu: (Set<Data.Element.ID>) -> [MenuItem]
    let primaryAction: (Set<Data.Element.ID>) -> ()
    let keyDown: (NSEvent) -> Bool
    let keyUp: (NSEvent) -> Bool

    public init(_ items: Data,
                selection: Binding<Set<Data.Element.ID>>,
                columns: [GridItem],
                spacing: CGFloat? = nil,
                @ViewBuilder itemContent: @escaping (Data.Element) -> Content,
                @MenuItemBuilder contextMenu: @escaping (Set<Data.Element.ID>) -> [MenuItem],
                primaryAction: @escaping (Set<Data.Element.ID>) -> Void,
                keyDown: @escaping (NSEvent) -> Bool = { _ in return false },
                keyUp: @escaping (NSEvent) -> Bool = { _ in return false }) {
        self.items = items
        self.selection = selection
        self.layout = GridItemLayout(columns: columns, spacing: spacing)
        self.itemContent = itemContent
        self.contextMenu = contextMenu
        self.primaryAction = primaryAction
        self.keyDown = keyDown
        self.keyUp = keyUp
    }

    public init(_ items: Data,
                selection: Binding<Set<Data.Element.ID>>,
                layout: any Layoutable,
                @ViewBuilder itemContent: @escaping (Data.Element) -> Content,
                @MenuItemBuilder contextMenu: @escaping (Set<Data.Element.ID>) -> [MenuItem],
                primaryAction: @escaping (Set<Data.Element.ID>) -> Void,
                keyDown: @escaping (NSEvent) -> Bool = { _ in return false },
                keyUp: @escaping (NSEvent) -> Bool = { _ in return false }) {
        self.items = items
        self.selection = selection
        self.layout = layout
        self.itemContent = itemContent
        self.contextMenu = contextMenu
        self.primaryAction = primaryAction
        self.keyDown = keyDown
        self.keyUp = keyUp
    }

    public var body: some View {
        CollectionViewContainerHost(items,
                                    selection: selection,
                                    layout: layout,
                                    itemContent: itemContent,
                                    contextMenu: contextMenu,
                                    primaryAction: primaryAction,
                                    keyDown: keyDown,
                                    keyUp: keyUp)
        .ignoresSafeArea()
    }

}

#else

public struct SelectableCollectionView<Data: RandomAccessCollection,
                                       Content: View>: View where Data.Element: Identifiable,
                                                                  Data.Element: Hashable,
                                                                  Data.Element.ID: Hashable {

    let items: Data
    let selection: Binding<Set<Data.Element.ID>>
    let columns: [GridItem]
    let spacing: CGFloat?
    let itemContent: (Data.Element) -> Content
    let contextMenu: (Set<Data.Element.ID>) -> [MenuItem]
    let primaryAction: (Set<Data.Element.ID>) -> ()
//    let keyDown: (UIEvent) -> Bool
//    let keyUp: (UIEvent) -> Bool

    public init(_ items: Data,
                selection: Binding<Set<Data.Element.ID>>,
                columns: [GridItem],
                spacing: CGFloat? = nil,
                @ViewBuilder itemContent: @escaping (Data.Element) -> Content,
                @MenuItemBuilder contextMenu: @escaping (Set<Data.Element.ID>) -> [MenuItem],
                primaryAction: @escaping (Set<Data.Element.ID>) -> Void/*,
                keyDown: @escaping (NSEvent) -> Bool = { _ in return false },
                keyUp: @escaping (NSEvent) -> Bool = { _ in return false } */) {
        self.items = items
        self.selection = selection
        self.columns = columns
        self.spacing = spacing
        self.itemContent = itemContent
        self.contextMenu = contextMenu
        self.primaryAction = primaryAction
//        self.keyDown = keyDown
//        self.keyUp = keyUp
    }

    public var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: spacing) {
                ForEach(items) { item in
                    itemContent(item)
                        .contextMenu {
                            contextMenu([item.id])
                        }
                        .onTapGesture {
                            primaryAction([item.id])
                        }
                }
            }
            .padding()
        }
    }

}

#endif
