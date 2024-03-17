# SelectableCollectionView

Grid view for SwiftUI with support for multiple selection on macOS modeled after `LazyVGrid` and `List`.

## Documentation

https://inseven.github.io/SelectableCollectionView/documentation/selectablecollectionview/

## Usage

```swift
struct ContentView: View {

    @State private var items = [/* ... */]

    private var columns = [GridItem(.adaptive(minimum: 300))]

    /* ... */

    var body: some View {
        HStack {
            SelectableCollectionView(model.filteredItems,
                                     selection: $model.selection,
                                     columns: columns) { item in
                ItemView(item: item)
            } contextMenu: { selection in
                MenuItem("Delete") {
                    items.removeAll { selection.contains($0.id) }
                }
            } primaryAction: { selection in
                for item in items.removeAll(where: { selection.contains($0.id) }) {
                    /* ... */
                }
            }
        }
    }

}
```

## License

SelectableCollectionView is licensed under the MIT License (see [LICENSE](LICENSE)).
