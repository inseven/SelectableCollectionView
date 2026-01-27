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

import Combine
import SwiftUI
import SelectableCollectionView

// TODO: Test removal.
// TODO: Make this a model so we can reuse it in other SwiftUI; good performance test too.
class Creator: CollectionViewStreamingCollection {

    var supportsIncrementalUpdates: Bool { true }

    private var collectionView: (any CollectionViewProxy<Item>)? = nil
    private var items: [Item] = []

    func run() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.10) { [weak self] in
            guard let self else {
                return
            }
            let item = Item()
            let index = Int.random(in: 0..<self.items.count + 1)
            self.items.insert(Item(), at: index)
            self.collectionView?.insertItem(item, atIndex: index, items: Array(items))
            self.run()
        }
    }

    init() {
        run()
    }

    func collectionViewDidConnect(_ collectionView: (any CollectionViewProxy<Item>)?) {
        self.collectionView = collectionView
    }

}
