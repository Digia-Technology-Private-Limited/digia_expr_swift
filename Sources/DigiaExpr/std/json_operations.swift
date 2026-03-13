public enum JsonOperations {
    public static var functions: [String: any ExprCallable] {
        [
            "jsonGet": JsonGetOp(),
            "get": JsonGetOp(),
        ]
    }
}

public struct JsonGetOp: ExprCallable {
    public let name = "jsonGet"
    public init() {}
    public func arity() -> Int { 2 }

    public func call(_ evaluator: ASTEvaluator, _ arguments: [ASTNode]) throws -> ExprValue? {
        guard arguments.count >= 2 else {
            throw ExpressionError.invalidExpression("Incorrect argument size")
        }

        guard let json = try evaluator.eval(arguments[0]) else { return .null }
        guard let path = try evaluator.eval(arguments[1])?.stringValue else { return .null }

        var current: ExprValue = json
        for segment in path.split(separator: ".").map(String.init) {
            guard let dict = current.mapValue else { return .null }
            current = dict[segment] ?? .null
        }

        return current.isNull ? .null : current
    }
}
