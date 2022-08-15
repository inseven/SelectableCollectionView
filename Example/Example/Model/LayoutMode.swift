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

import SwiftUI

import SelectableCollectionView

enum LayoutMode: Equatable, Identifiable, CaseIterable {

    var id: Self { self }

    case fixedItemSize
    case column
    case table

    var systemImage: String {
        switch self {
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
        case .fixedItemSize:
            return FixedItemSizeLayout(spacing: 16,
                                       size: CGSize(width: 200.0, height: 200.0))
        case .column:
            return ColumnLayout(spacing: 16.0, columns: 5)
        case .table:
            return nil
        }
    }

}
