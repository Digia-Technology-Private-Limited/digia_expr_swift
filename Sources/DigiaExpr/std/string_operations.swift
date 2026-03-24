public enum StringOperations {
    public static var functions: [String: any ExprCallable] {
        [
            "concat": ConcatOp(),
            "concatenate": ConcatOp(),
            "substring": SubStringOp(),
        ]
    }
}

public struct SubStringOp: ExprCallable {
    public let name = "substring"
    public init() {}
    public func arity() -> Int { 2 }

    public func call(_ evaluator: ASTEvaluator, _ arguments: [ASTNode]) throws -> ExprValue? {
        guard arguments.count >= 2 else {
            throw ExpressionError.invalidExpression("Can not resolve for less than 2 arguments")
        }

        guard let string = try evaluator.eval(arguments[0])?.stringValue else { return .null }
        guard let start = try evaluator.eval(arguments[1])?.intValue else { return .string(string) }

        let end = try arguments.count > 2 ? evaluator.eval(arguments[2])?.intValue : nil

        let startOffset = max(0, min(start, string.count))
        let endOffset = end.map { max(0, min($0, string.count)) } ?? string.count
        let clampedEndOffset = max(startOffset, endOffset)

        let startIndex = string.index(string.startIndex, offsetBy: startOffset)
        let endIndex = string.index(string.startIndex, offsetBy: clampedEndOffset)
        return .string(String(string[startIndex..<endIndex]))
    }
}

public struct ConcatOp: ExprCallable {
    public let name = "concat"
    public init() {}
    public func arity() -> Int { 255 }

    public func call(_ evaluator: ASTEvaluator, _ arguments: [ASTNode]) throws -> ExprValue? {
        var buffer = ""
        for argument in arguments {
            buffer.append(stringify(try evaluator.eval(argument)))
        }
        return .string(buffer)
    }
}
