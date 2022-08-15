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

#warning("TODO: What thread is the filter running on?")
class Model: ObservableObject {

    @Published var items = [Item()]
    @Published var selection = Set<Item.ID>()
    @Published var filter = ""
    @Published var filteredItems: [Item] = []
    @Published var isPainted = false
    @Published var layoutMode: LayoutMode = .column

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
