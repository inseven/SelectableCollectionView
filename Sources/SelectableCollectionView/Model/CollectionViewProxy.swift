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

import SwiftUI

// TODO: Does Element need to be identifiable??

/**
 * Proxy protocol for managing a collection view.
 *
 * This allows streaming collections to directly apply changes to the collection view.
 *
 * Implementations conforming to this protocol make no attempt at thread safety and methods must be called on the main
 * thread.
 */
public protocol CollectionViewProxy<Element> {

    associatedtype Element: Identifiable & Hashable

    func setItems(_ items: [Element])
    func insertItem(_ item: Element, atIndex index: Int, items: [Element])
    func updateItem(_ item: Element, atIndex index: Int, items: [Element])
    func removeItem(_ item: Element, atIndex index: Int, items: [Element])

}
