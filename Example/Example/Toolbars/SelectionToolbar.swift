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

struct SelectionToolbar: CustomizableToolbarContent {

    @EnvironmentObject var model: Model

    let id: String

    var body: some CustomizableToolbarContent {

        ToolbarItem(id: "clear") {
            Button {
                model.clearSelection()
            } label: {
                Image(systemName: "xmark")
            }
            .help("Clear selection")
            .disabled(model.selection.isEmpty)
        }

        ToolbarItem(id: "random") {
            Button {
                model.selectRandomItem()
            } label: {
                Image(systemName: "arrow.2.squarepath")
            }
            .help("Select random item")
        }

        ToolbarItem(id: "delete") {
            Button {
                model.delete(ids: model.selection)
            } label: {
                Image(systemName: "trash")
            }
            .help("Delete selected items")
            .keyboardShortcut(.delete)
            .disabled(model.selection.isEmpty)
        }

    }

}
