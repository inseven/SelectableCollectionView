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

struct SelectionToolbar: ToolbarContent {

    @EnvironmentObject var model: Model

    var body: some ToolbarContent {

        ToolbarItem {
            Menu("Title", systemImage: "ellipsis.circle") {
                Button {
                    model.clearSelection()
                } label: {
                    Label("Clear Selection", systemImage: "xmark")
                }
                .help("Clear selection")
                .disabled(model.selection.isEmpty)

                Button {
                    model.selectRandomItem()
                } label: {
                    Label("Select Random Item", systemImage: "shuffle")
                }

                Divider()

                Button {
                    model.open(ids: model.selection)
                } label: {
                    Label("Open", systemImage: "globe")
                }

                Divider()

                Button {
                    model.delete(ids: model.selection)
                } label: {
                    Label("Delete \(model.selection.count) Items", systemImage: "trash")
                }
                .disabled(model.selection.isEmpty)

                Divider()

                Button {
                    model.items.append(Item())
                } label: {
                    Label("Add 1 Item", systemImage: "plus.square")
                }

                Button {
                    model.addManyItems()
                } label: {
                    Label("Add 1000 Items", systemImage: "plus.square.on.square")
                }

            }
        }

    }

}
