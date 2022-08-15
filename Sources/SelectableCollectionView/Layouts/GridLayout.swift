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

import AppKit

extension Hasher {

    mutating func combine(_ size: CGSize) {
        combine(size.width)
        combine(size.height)
    }

}

public struct GridLayout: Layoutable {

    let minimumItemSize: CGSize
    let maximumItemSize: CGSize
    let minimumLineSpacing: CGFloat
    let minimumInterItemSpacing: CGFloat

    public init(minimumItemSize: CGSize = .zero,
                maximumItemSize: CGSize = .zero,
                minimumLineSpacing: CGFloat = 0.0,
                minimumInterItemSpacing: CGFloat = 0.0) {
        self.minimumItemSize = minimumItemSize
        self.maximumItemSize = maximumItemSize
        self.minimumLineSpacing = minimumLineSpacing
        self.minimumInterItemSpacing = minimumInterItemSpacing
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(minimumItemSize)
        hasher.combine(maximumItemSize)
        hasher.combine(minimumLineSpacing)
        hasher.combine(minimumInterItemSpacing)
    }

    public func makeLayout() -> NSCollectionViewLayout {
        let layout = NSCollectionViewGridLayout()
        layout.minimumItemSize = minimumItemSize
        layout.maximumItemSize = maximumItemSize
        layout.minimumLineSpacing = minimumLineSpacing
        layout.minimumInteritemSpacing = minimumInterItemSpacing
        return layout
    }

}
