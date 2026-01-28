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

struct ContentView: View {

    @State var isStreaming = true
    @StateObject var model = Model()
    let creator = Creator()

    @MenuItemBuilder func contextMenu(_ selection: Set<Item.ID>) -> [MenuItem] {
        if !selection.isEmpty {
            MenuItem("Delete", systemImage: "trash") {
                model.remove(ids: selection)
            }
            .disabled(isStreaming)
        }
    }

    func primaryAction(_ selection: Set<Item.ID>) {
        model.open(ids: selection)
    }

    var body: some View {
        HStack {
            if let layout = model.layoutMode.layout {
                if isStreaming {
                    SelectableCollectionView(creator, selection: $model.selection, layout: layout) { item in
                        Cell(item: item, isPainted: model.isPainted)
                    } contextMenu: { selection in
                        contextMenu(selection)
                    } primaryAction: { selection in
                        primaryAction(selection)
                    }
                } else {
                    SelectableCollectionView(model.filteredItems, selection: $model.selection, layout: layout) { item in
                        Cell(item: item, isPainted: model.isPainted)
                    } contextMenu: { selection in
                        contextMenu(selection)
                    } primaryAction: { selection in
                        primaryAction(selection)
                    }
                }
            } else {
                Table(isStreaming ? creator.items : model.filteredItems, selection: $model.selection) {
                    TableColumn("") { item in
                        Image(systemName: "circle.fill")
                            .foregroundColor(item.color)
                    }
                    TableColumn("Color", value: \.color.description)
                }
                .contextMenu(forSelectionType: Item.ID.self) { selection in
                    contextMenu(selection)
                } primaryAction: { selection in
                    primaryAction(selection)
                }
            }
        }
        .searchable(text: $model.filter)
        .toolbar {
            LayoutToolbar(mode: $model.layoutMode)
            ModeToolbar(isStreaming: $isStreaming)
            StateToolbar()
            SelectionToolbar()
        }
        .navigationSubtitle(isStreaming ? "\(creator.items.count) items" : model.subtitle)
        .onAppear {
            model.run()
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
