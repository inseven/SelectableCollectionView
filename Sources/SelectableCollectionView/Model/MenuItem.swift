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

    public let id = UUID()

    let title: String
    let action: () -> Void

    public init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

}

extension Array where Element == MenuItem {

    @ViewBuilder func asContextMenu() -> some View {
        ForEach(self) { menuItem in
            Button(menuItem.title, action: menuItem.action)
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
