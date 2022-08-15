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

struct Item: Hashable, Identifiable {
    let id = UUID()
    let text: String = String(Int.random(in: 0..<256))
    let color: Color = .random
}

struct ContentView: View {

    @StateObject var model = Model()
    @State var isPainted = false

    var body: some View {
#warning("TODO: Separate out into layout metrics")
        SelectableCollectionView(model.filteredItems, selection: $model.selection, spacing: 16, size: CGSize(width: 200, height: 100)) { item in
            Cell(item: item, isPainted: isPainted)
        } contextMenu: { selection in
            if !selection.isEmpty {
                MenuItem("Delete") {
                    model.items.removeAll { selection.contains($0) }
                }
            }
        }
        .searchable(text: $model.filter)
        .toolbar {

            ToolbarItem {
                Button {
                    model.clearSelection()
                } label: {
                    Image(systemName: "xmark")
                }
                .help("Clear selection")
                .disabled(model.selection.isEmpty)
            }

            ToolbarItem {
                Button {
                    model.selectRandomItem()
                } label: {
                    Image(systemName: "arrow.2.squarepath")
                }
                .help("Select random item")
            }

            ToolbarItem {
                Button {
                    model.delete(ids: model.selection)
                } label: {
                    Image(systemName: "trash")
                }
                .help("Delete selected items")
                .keyboardShortcut(.delete)
                .disabled(model.selection.isEmpty)
            }

            ToolbarItem {
                Toggle(isOn: $isPainted) {
                    Image(systemName: "paintbrush.pointed")
                }
            }

            ToolbarItem {
                Button {
                    model.items.append(Item())
                } label: {
                    Image(systemName: "plus")
                }
                .help("Add item")
            }

            ToolbarItem {
                Button {
                    model.addManyItems()
                } label: {
                    Image(systemName: "infinity")
                }
                .help("Add many items (1000)")
            }
        }
        .navigationSubtitle("\(model.items.count) items")
        .onAppear {
            model.run()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
