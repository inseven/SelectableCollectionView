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

import Combine
import SwiftUI

import SelectableCollectionView

struct ContentView: View {

    enum Mode: Equatable {
        case flexible
        case fixed
    }

    @StateObject var model = Model()
    @State var mode: Mode = .fixed

    @State var layout: any Layoutable = FixedItemSizeLayout(spacing: 16, size: CGSize(width: 200, height: 100))

    var body: some View {
        SelectableCollectionView(model.filteredItems, selection: $model.selection, layout: layout) { item in
            Cell(item: item, isPainted: model.isPainted)
        } contextMenu: { selection in
            if !selection.isEmpty {
                MenuItem("Delete") {
                    model.items.removeAll { selection.contains($0) }
                }
            }
        }
        .searchable(text: $model.filter)
        .toolbar {
            ToolbarItem(id: "mode") {
                Picker(selection: $mode) {
                    Image(systemName: "square.grid.2x2")
                        .tag(Mode.fixed)
                    Image(systemName: "rectangle.grid.2x2")
                        .tag(Mode.flexible)
                } label: {

                }
                .pickerStyle(.inline)
            }
            SelectionToolbar(id: "selection")
            StateToolbar(id: "state")
            ItemsToolbar(id: "items")
        }
        .navigationSubtitle("\(model.items.count) items")
        .onAppear {
            model.run()
        }
        .onChange(of: mode) { mode in
            switch mode {
            case .flexible:
                layout = FixedItemSizeLayout(spacing: 16,
                                             size: CGSize(width: 200.0, height: 100.0))
            case .fixed:
                layout = GridLayout(minimumItemSize: CGSize(width: 100.0, height: 100.0),
                                    maximumItemSize: CGSize(width: 200.0, height: 200.0),
                                    minimumLineSpacing: 16.0,
                                    minimumInterItemSpacing: 16.0)
            }
        }
        .environmentObject(model)
        .frame(minWidth: 400, minHeight: 400)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
