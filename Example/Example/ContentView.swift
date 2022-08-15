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

struct CollectionViewCell: View {

    @Environment(\.isSelected) var isSelected
    @Environment(\.highlightState) var highlightState

    var item: Item
    var isRed: Bool

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Text(item.text)
                Spacer()
            }
            Spacer()
        }
        .background(isRed ? Color.red : item.color.opacity(0.4))
        .padding(4)
        .border(isSelected || highlightState == .forSelection ? Color.accentColor : Color.clear, width: 3)
    }
}

#warning("TODO: What thread is the filter running on?")
class ContentViewModel: ObservableObject {

    @Published var items = [Item()]
    @Published var selection = Set<Item.ID>()
    @Published var filter = ""
    @Published var filteredItems: [Item] = []

    private var cancellables: Set<AnyCancellable> = []

    @MainActor func selectRandomItem() {
        guard let item = items.randomElement() else {
            return
        }
        selection = Set([item.id])
    }

    @MainActor func clearSelection() {
        selection = Set()
    }

    @MainActor func delete(ids: Set<Item.ID>) {
        items.removeAll { ids.contains($0.id) }
    }

    @MainActor func addManyItems() {
        for _ in 0..<1000 {
            items.append(Item())
        }
    }

    @MainActor func run() {

        // Update the filter.
        $filter
            .combineLatest($items)
            .compactMap { (filter, items) in
                return items.filter { filter.isEmpty || $0.text.localizedCaseInsensitiveContains(filter) }
            }
            .receive(on: DispatchQueue.main)
            .sink { filteredItems in
                self.filteredItems = filteredItems
            }
            .store(in: &cancellables)

        // Print the selection.
        $selection
            .receive(on: DispatchQueue.main)
            .sink { selection in
                print("selection = \(selection)")
            }
            .store(in: &cancellables)

    }

}

struct ContentView: View {

    @StateObject var model = ContentViewModel()
    @State var isRed = false

    var body: some View {
#warning("TODO: Separate out into layout metrics")
        SelectableCollectionView(model.filteredItems, selection: $model.selection, spacing: 16, size: CGSize(width: 200, height: 100)) { item in
            CollectionViewCell(item: item, isRed: isRed)
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
                Toggle(isOn: $isRed) {
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
