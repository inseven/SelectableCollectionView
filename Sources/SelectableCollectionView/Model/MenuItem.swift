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

import Foundation
import SwiftUI

public struct MenuItem: Identifiable {

    enum ItemType {
        case item(String, () -> Void)
        case separator
    }

    public let id = UUID()

    let itemType: ItemType
    var isDisabled: Bool = false

    public init(_ title: String, action: @escaping () -> Void) {
        self.itemType = .item(title, action)
    }

    public init(_ title: String, action: @escaping () async -> Void) {
        self.init(title) {
            Task {
                await action()
            }
        }
    }

    init(_ itemType: ItemType) {
        self.itemType = itemType
    }

    public func disabled(_ isDisabled: Bool) -> Self {
        var menuItem = self
        menuItem.isDisabled = isDisabled
        return menuItem
    }

}

extension MenuItem: MenuItemsConvertible {

    public func asMenuItems() -> [MenuItem] {
        return [self]
    }

}

public struct Separator: MenuItemsConvertible {

    public init() {}

    public func asMenuItems() -> [MenuItem] {
        return [MenuItem(.separator)]
    }

}

extension Array where Element == MenuItem {

    @ViewBuilder func asContextMenu() -> some View {
        ForEach(self) { menuItem in
            switch menuItem.itemType {
            case .item(let title, let action):
                Button(title, action: action)
            case .separator:
                Divider()
            }
        }
    }
    
}

extension View {

    public func contextMenu<I>(forSelectionType itemType: I.Type = I.self,
                                  @MenuItemBuilder menu: @escaping (Set<I>) -> [MenuItem],
                                  primaryAction: ((Set<I>) -> Void)? = nil) -> some View where I : Hashable {
        contextMenu(forSelectionType: itemType, menu: { items in
            menu(items).asContextMenu()
        }, primaryAction: primaryAction)
    }

}
