import SwiftUI

public struct IsSelected: EnvironmentKey {
    public static let defaultValue = false
}

extension EnvironmentValues {
    public var isSelected: Bool {
        get { self[IsSelected.self] }
        set { self[IsSelected.self] = newValue }
    }
}
