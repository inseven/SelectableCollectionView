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

#if os(macOS)

import AppKit
import SwiftUI

import Cassowary

class GridItemCollectionViewLayout: NSCollectionViewCompositionalLayout {

    init(columns: [GridItem], spacing: CGFloat?) {
        super.init(sectionProvider: { (sectionIndex: Int,
                                       layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection in

            // SwiftUI's `GridItem` layout model is a bit of a hybrid, some of which we need a constraints solver for,
            // and some of which we can easily code up manually. The documentation defines the three cases as follows:
            //
            // - .adaptive(minimum:maximum:)
            //
            //   Multiple items in the space of a single flexible item.
            //
            //   This size case places one or more items into the space assigned to a single flexible item, using the
            //   provided bounds and spacing to decide exactly how many items fit. This approach prefers to insert as
            //   many items of the minimum size as possible but lets them increase to the maximum size.
            //
            // - .fixed(_:)
            //
            //   A single item with the specified fixed size.
            //
            // - .flexible(minimum:maximum:)
            //
            //   A single flexible item.
            //
            //   The size of this item is the size of the grid with spacing and inflexible items removed, divided by the
            //   number of flexible items, clamped to the provided bounds.
            //
            // This, I think, means that treat `.adaptive` as a container, and only once we've worked out the dimensions
            // of that container, do we then calculate the number of columns required in that container.

            struct ColumnDetails {
                let width: Variable
                let definition: GridItem.Size

                func layoutItmes(spacing: CGFloat) -> [NSCollectionLayoutItem] {
                    switch definition {
                    case .fixed, .flexible:
                        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(width.value),
                                                              heightDimension: .estimated(10))
                        return [NSCollectionLayoutItem(layoutSize: itemSize)]
                    case .adaptive(let minimum, let maximum):
                        let width = width.value + spacing
                        let columns = max(1.0, floor(width / (minimum + spacing)))
                        let itemWidth = width / columns
                        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(itemWidth - spacing),
                                                              heightDimension: .estimated(10))
                        var items: [NSCollectionLayoutItem] = []
                        for i in 0..<Int(columns) {
                            items.append(NSCollectionLayoutItem(layoutSize: itemSize))
                        }
                        return items
                    }
                }
            }
            let edgeInsets = NSDirectionalEdgeInsets(16.0)
            let interItemSpacing = spacing ?? 8.0

            let contentSize = layoutEnvironment.container.effectiveContentSize
                .inset(by: edgeInsets)
            var remainingWidth = Expression(constant: contentSize.width)

            let solver = Solver()
            var dimensions: [ColumnDetails] = []
            for (i, column) in columns.enumerated() {

                let dimension = Variable("column\(i)")
                let details = ColumnDetails(width: dimension, definition: column.size)
                dimensions.append(details)

                remainingWidth = remainingWidth - interItemSpacing - dimension

                switch column.size {
                case .fixed(let width):
                    try? solver.addConstraint(dimension == width)
                case .flexible(minimum: let minimum, maximum: let maximum):
                    try? solver.addConstraint(dimension >= minimum)
                    try? solver.addConstraint(dimension <= maximum)
                case .adaptive(minimum: let minimum, maximum: let maximum):
                    try? solver.addConstraint(dimension >= minimum)
                    try? solver.addConstraint(dimension <= maximum)
                @unknown default:
                    fatalError("Unsupported column size \(column).")
                }
            }

            try? solver.addConstraint(remainingWidth == 0)
            solver.updateVariables()

            let items = dimensions
                .map { dimension in
                    return dimension.layoutItmes(spacing: interItemSpacing)
                }
                .reduce([], +)

            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .estimated(10))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: items)
            group.interItemSpacing = .fixed(interItemSpacing)

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = interItemSpacing
            section.contentInsets = edgeInsets

            return section
        })
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

#endif
