public struct ExprLookupResult: Sendable {
    public let found: Bool
    public let value: ExprValue?

    public init(found: Bool, value: ExprValue?) {
        self.found = found
        self.value = value
    }
}

public protocol ExprContext: AnyObject {
    var name: String { get }
    var enclosing: (any ExprContext)? { get set }
    func getValue(_ key: String) -> ExprLookupResult
}

public extension ExprContext {
    func addContextAtTail(_ context: any ExprContext) {
        if let enclosing {
            enclosing.addContextAtTail(context)
        } else {
            enclosing = context
        }
    }
}
