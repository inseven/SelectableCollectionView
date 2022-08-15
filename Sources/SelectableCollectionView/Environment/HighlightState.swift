import SwiftUI

public struct HighlightState: EnvironmentKey {
    public static let defaultValue: NSCollectionViewItem.HighlightState = .none
}

extension EnvironmentValues {

    public var highlightState: NSCollectionViewItem.HighlightState {
        get { self[HighlightState.self] }
        set { self[HighlightState.self] = newValue }
    }

}
