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

import SwiftUI

@available(iOS 15, *, macOS 12, *)
public struct MenuItem: Identifiable {

    public enum ItemType {
        case item(String, String?, ButtonRole?, () -> Void)
        case separator
        case menu(String, String?, [MenuItem])
    }

    public let id = UUID()

    public let itemType: ItemType
    public var isDisabled: Bool = false
    public var underlyingKeyboardShortcut: KeyboardShortcut?

    public init(_ title: LocalizedStringKey, systemImage: String? = nil, role: ButtonRole? = nil, action: @escaping () -> Void) {
        self.itemType = .item(title.localized ?? "", systemImage, role, action)
    }

    public init(_ title: String, systemImage: String? = nil, role: ButtonRole? = nil, action: @escaping () -> Void) {
        self.itemType = .item(title ?? "", systemImage, role, action)
    }

    public init(_ title: LocalizedStringKey, systemImage: String? = nil, @MenuItemBuilder items: () -> [MenuItem]) {
        self.itemType = .menu(title.localized ?? "", systemImage, items())
    }

    public init(_ title: String, systemImage: String? = nil, @MenuItemBuilder items: () -> [MenuItem]) {
        self.itemType = .menu(title ?? "", systemImage, items())
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

    public func keyboardShortcut(_ key: KeyEquivalent, modifiers: EventModifiers = .command) -> MenuItem {
        var menuItem = self
        menuItem.underlyingKeyboardShortcut = KeyboardShortcut(key, modifiers: modifiers)
        return menuItem
    }

}

@available(iOS 15, *, macOS 12, *)
extension MenuItem: MenuItemsConvertible {

    public func asMenuItems() -> [MenuItem] {
        return [self]
    }

}

@available(iOS 15, *, macOS 12, *)
public struct Separator: MenuItemsConvertible {

    public init() {}

    public func asMenuItems() -> [MenuItem] {
        return [MenuItem(.separator)]
    }

}

@available(iOS 15, *, macOS 12, *)
extension Divider: MenuItemsConvertible {

    public func asMenuItems() -> [MenuItem] {
        return [MenuItem(.separator)]
    }

}

@available(iOS 15, *, macOS 12, *)
extension Array where Element == MenuItem {

    @ViewBuilder public func asContextMenu() -> some View {
        MenuView(menuItems: self)
    }
    
}

extension View {

    @available(iOS 16, *, macOS 13, *)
    public func contextMenu<I>(forSelectionType itemType: I.Type = I.self,
                                  @MenuItemBuilder menu: @escaping (Set<I>) -> [MenuItem],
                                  primaryAction: ((Set<I>) -> Void)? = nil) -> some View where I : Hashable {
        contextMenu(forSelectionType: itemType, menu: { items in
            menu(items).asContextMenu()
        }, primaryAction: primaryAction)
    }

    @available(iOS 16, *, macOS 13, *)
    public func contextMenu(@MenuItemBuilder menu: @escaping () -> [MenuItem]) -> some View {
        contextMenu(ContextMenu {
            menu().asContextMenu()
        })
    }

}
