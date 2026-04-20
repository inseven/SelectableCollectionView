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

/**
 * Wraps `CollectionViewStreamingCollection` and presents a `CollectionViewManagedCollection` interface.
 *
 * This allows us to expose just the `CollectionViewStreamingCollection` protocol which ensures developers don't have
 * to / aren't able to implement methods that can mess up the internals.
 *
 * It feels like this might be one level of abstraction too far, but, it's internal and allows us to talk to collections
 * through the same API, hopefully localizing the specifics of the mappings.
 */
class CollectionViewManagedStreamingCollection<Element> : CollectionViewManagedCollection where Element: Identifiable {

    var supportsIncrementalUpdates: Bool = true

    private var _collectionViewDidConnect: ((any CollectionViewProxy<Element>)?) -> Void

    init(_ collection: any CollectionViewStreamingCollection<Element>) {
        _collectionViewDidConnect = { proxy in
            collection.collectionViewDidConnect(proxy)
        }
    }

    func collectionViewDidConnect(_ collectionView: (any CollectionViewProxy<Element>)?) {
        _collectionViewDidConnect(collectionView)
    }

    func update() {}

}
