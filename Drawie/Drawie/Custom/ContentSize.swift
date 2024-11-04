import SwiftUI

// MARK: - Preference Key

struct ContentSizeKey: PreferenceKey {

    static var defaultValue: CGSize { .zero }

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = CGSize(width: value.width + nextValue().width,
                       height: value.height + nextValue().height)
    }

}

// MARK: - Modifier

public struct ContentSize: ViewModifier {

    // MARK: - Private Properties

    @Binding private var size: CGSize

    // MARK: - Init

    public init(in size: Binding<CGSize>) {
        self._size = size
    }

    // MARK: - Protocol ViewModifier

    public func body(content: Content) -> some View {
        content.modifier(
            GeometryBasedModifier(
                value: $size,
                preferenceKey: ContentSizeKey.self,
                proxyReader: { $0.size }
            )
        )
    }

}

// MARK: - Convenience Modifier

extension View {

    /// Reads the content size of the modified view into the given binding.
    public func contentSize(in size: Binding<CGSize>) -> some View {
        modifier(ContentSize(in: size))
    }

}
