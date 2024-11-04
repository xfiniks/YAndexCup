import SwiftUI

public struct GeometryBasedModifier<Value, Key>: ViewModifier where Value: Equatable, Key: PreferenceKey, Key.Value == Value {

    // MARK: - Private Properties

    @Binding private var value: Value

    private let preferenceKey: Key.Type
    private let proxyReader: (GeometryProxy) -> Value

    // MARK: - Init
    
    /// Creates an instance of the view modifier.
    /// - Parameters:
    ///   - value: a binding to write values into.
    ///   - preferenceKey: an associated PreferenceKey.
    ///   - proxyReader: a function that maps a GeometryProxy to a value for the binding.
    public init(
        value: Binding<Value>,
        preferenceKey: Key.Type,
        proxyReader: @escaping (GeometryProxy) -> Value
    ) {
        self._value = value
        self.preferenceKey = preferenceKey
        self.proxyReader = proxyReader
    }

    // MARK: - Protocol View

    public func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .preference(
                            key: preferenceKey,
                            value: proxyReader(proxy)
                        )
                        .onPreferenceChange(preferenceKey) {
                            value = $0
                        }
                }
            )
    }

}
