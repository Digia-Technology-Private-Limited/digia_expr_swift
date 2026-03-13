public final class BasicExprContext: ExprContext {
    public let name: String
    public var enclosing: (any ExprContext)?

    private let variables: [String: ExprValue]

    public init(
        name: String = "",
        variables: [String: Any?],
        enclosing: (any ExprContext)? = nil
    ) {
        self.name = name
        self.variables = variables.mapValues { ExprValue.from($0 ?? nil) }
        self.enclosing = enclosing
    }

    public func getValue(_ key: String) -> ExprLookupResult {
        if let value = variables[key] {
            return ExprLookupResult(found: true, value: value)
        }

        return enclosing?.getValue(key) ?? ExprLookupResult(found: false, value: nil)
    }
}
