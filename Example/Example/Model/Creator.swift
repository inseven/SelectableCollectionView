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

import Combine
import SwiftUI
import SelectableCollectionView

@Observable
class Creator: CollectionViewStreamingCollection {

    enum Operation: CaseIterable {
        case add
        case remove
        case move
        case update

        static func random() -> Self {
            return allCases.randomElement()!
        }
    }

    private var collectionView: (any CollectionViewProxy<Item>)? = nil
    public var items: [Item] = []
    private var isActive: Bool = true

    func run() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self else {
                return
            }
            defer { self.run() }

            switch Operation.random() {
            case .add:
                let item = Item()
                let index = Int.random(in: 0..<items.count + 1)
                items.insert(item, at: index)
                collectionView?.insertItem(item, atIndex: index, items: Array(items))
            case .remove:
                guard !items.isEmpty else {
                    return
                }
                let index = Int.random(in: 0..<items.count)
                let item = items.remove(at: index)
                collectionView?.removeItemWithId(item.id, atIndex: index, items: Array(items))
            case .move:
                guard !items.isEmpty else {
                    return
                }
                let from = Int.random(in: 0..<items.count)
                let to = Int.random(in: 0...items.count)  // Apple's move implementation _always_ treats it as inserting before this index.
                let item = items[from]
                items.move(fromOffsets: [from], toOffset: to)
                collectionView?.moveItem(item, toIndex: to, items: Array(items))
            case .update:
                guard !items.isEmpty else {
                    return
                }
                let index = Int.random(in: 0..<items.count)
                var item = items[index]
                item.count += 1
                items[index] = item  // We currently need to replace this because it's a struct.
                collectionView?.updateItem(item, atIndex: index, items: items)
            }

        }
    }

    init() {
        run()
    }

    func collectionViewDidConnect(_ collectionView: (any CollectionViewProxy<Item>)?) {
        self.collectionView = collectionView
        self.collectionView?.setItems(Array(items))
    }

}
