import Foundation

public protocol MenuItemsConvertible {
    func asMenuItems() -> [MenuItem]
}

@resultBuilder public struct MenuItemBuilder {

    public static func buildBlock() -> [MenuItem] {
        return []
    }

    public static func buildBlock(_ items: MenuItem...) -> [MenuItem] {
        return items
    }

    public static func buildBlock(_ values: MenuItemsConvertible...) -> [MenuItem] {
        return values
            .flatMap { $0.asMenuItems() }
    }

    public static func buildIf(_ value: MenuItemsConvertible?) -> MenuItemsConvertible {
        return value ?? []
    }

    public static func buildEither(first: MenuItemsConvertible) -> MenuItemsConvertible {
        first
    }

    public static func buildEither(second: MenuItemsConvertible) -> MenuItemsConvertible {
        second
    }

}

extension Array: MenuItemsConvertible where Element == MenuItem {

    public func asMenuItems() -> [MenuItem] {
        return self
    }

}
