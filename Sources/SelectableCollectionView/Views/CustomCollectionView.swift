import AppKit

protocol CustomCollectionViewMenuDelegate: NSObject {

    func customCollectionView(_ customCollectionView: CustomCollectionView, contextMenuForSelection selection: IndexSet) -> NSMenu?
    func customCollectionView(_ customCollectionView: CustomCollectionView, didUpdateSelection selection: Set<IndexPath>)

}

class CustomCollectionView: NSCollectionView {

    weak var menuDelegate: CustomCollectionViewMenuDelegate?

    override func menu(for event: NSEvent) -> NSMenu? {

        // Update the selection if necessary.
        let point = convert(event.locationInWindow, from: nil)
        if let indexPath = indexPathForItem(at: point) {
            if !selectionIndexPaths.contains(indexPath) {
                selectionIndexPaths = [indexPath]
            }
        } else {
            selectionIndexPaths = []
        }
        menuDelegate?.customCollectionView(self, didUpdateSelection: selectionIndexPaths)

        // Get the menu for the current selection.
        if let menu = menuDelegate?.customCollectionView(self, contextMenuForSelection: selectionIndexes) {
            return menu
        }

        return super.menu(for: event)
    }

}
