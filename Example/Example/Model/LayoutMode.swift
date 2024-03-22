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

import SelectableCollectionView

enum LayoutMode: Equatable, Identifiable, CaseIterable {

    private struct LayoutMetrics {
        static var interItemSpacing = 6.0
        static var padding = 9.0

        static var edgeInsets: NSEdgeInsets {
            return NSEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        }

        static var directionalEdgeInsets: NSDirectionalEdgeInsets {
            return NSDirectionalEdgeInsets(top: padding, leading: padding, bottom: padding, trailing: padding)
        }
    }

    var id: Self { self }

    case griditems
    case fixedItemSize
    case column
    case table

    var systemImage: String {
        switch self {
        case .griditems:
            return "rectangle.3.group"
        case .fixedItemSize:
            return "square"
        case .column:
            return "squareshape.dashed.squareshape"
        case .table:
            return "tablecells"
        }
    }

    var help: String {
        switch self {
        case .griditems:
            return "SwiftUI Column Layout"
        case .fixedItemSize:
            return "Fixed Item Size"
        case .column:
            return "Column"
        case .table:
            return "Table"
        }
    }

    var layout: (any Layoutable)? {
        switch self {
        case .griditems:
            let columns = [GridItem(.fixed(200)),
                           GridItem(.flexible(minimum: 150, maximum: 250)),
                           GridItem(.adaptive(minimum: 300))]
            return GridItemLayout(columns: columns, spacing: nil)
        case .fixedItemSize:
            return FixedItemSizeLayout(spacing: LayoutMetrics.interItemSpacing,
                                       size: CGSize(width: 200.0, height: 200.0),
                                       contentInsets: LayoutMetrics.directionalEdgeInsets)
        case .column:
            return ColumnLayout(spacing: LayoutMetrics.interItemSpacing,
                                columns: 5,
                                edgeInsets: LayoutMetrics.edgeInsets)
        case .table:
            return nil
        }
    }

}
