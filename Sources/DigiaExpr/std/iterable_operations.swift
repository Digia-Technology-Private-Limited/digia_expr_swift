public enum IterableOperations {
    public static var functions: [String: any ExprCallable] {
        [
            "contains": ContainsOp(),
            "elementAt": ElementAtOp(),
            "firstElement": FirstElementOp(),
            "lastElement": LastElementOp(),
            "skip": SkipOp(),
            "take": TakeOp(),
            "reversed": ReversedOp(),
        ]
    }
}

public struct ContainsOp: ExprCallable {
    public let name = "contains"
    public init() {}
    public func arity() -> Int { 2 }

    public func call(_ evaluator: ASTEvaluator, _ arguments: [ASTNode]) throws -> ExprValue? {
        guard arguments.count == arity() else {
            throw ExpressionError.invalidExpression("Incorrect argument size")
        }

        guard let list = try evaluator.eval(arguments[0])?.listValue else { return .bool(false) }
        let element = try evaluator.eval(arguments[1])

        return .bool(list.contains { looselyEqual($0, element) })
    }
}

public struct ElementAtOp: ExprCallable {
    public let name = "elementAt"
    public init() {}
    public func arity() -> Int { 2 }

    public func call(_ evaluator: ASTEvaluator, _ arguments: [ASTNode]) throws -> ExprValue? {
        guard arguments.count == arity() else {
            throw ExpressionError.invalidExpression("Incorrect argument size")
        }

        guard let list = try evaluator.eval(arguments[0])?.listValue else { return .null }
        guard let index = try evaluator.eval(arguments[1])?.intValue else { return .null }

        guard index >= 0, index < list.count else { return .null }
        return list[index]
    }
}

public struct FirstElementOp: ExprCallable {
    public let name = "firstElement"
    public init() {}
    public func arity() -> Int { 1 }

    public func call(_ evaluator: ASTEvaluator, _ arguments: [ASTNode]) throws -> ExprValue? {
        guard arguments.count == arity() else {
            throw ExpressionError.invalidExpression("Incorrect argument size")
        }

        guard let list = try evaluator.eval(arguments[0])?.listValue else { return .null }
        return list.first ?? .null
    }
}

public struct LastElementOp: ExprCallable {
    public let name = "lastElement"
    public init() {}
    public func arity() -> Int { 1 }

    public func call(_ evaluator: ASTEvaluator, _ arguments: [ASTNode]) throws -> ExprValue? {
        guard arguments.count == arity() else {
            throw ExpressionError.invalidExpression("Incorrect argument size")
        }

        guard let list = try evaluator.eval(arguments[0])?.listValue else { return .null }
        return list.last ?? .null
    }
}

public struct SkipOp: ExprCallable {
    public let name = "skip"
    public init() {}
    public func arity() -> Int { 2 }

    public func call(_ evaluator: ASTEvaluator, _ arguments: [ASTNode]) throws -> ExprValue? {
        guard arguments.count == arity() else {
            throw ExpressionError.invalidExpression("Incorrect argument size")
        }

        guard let list = try evaluator.eval(arguments[0])?.listValue else { return .null }
        let count = max(0, try evaluator.eval(arguments[1])?.intValue ?? 0)

        return .list(Array(list.dropFirst(count)))
    }
}

public struct TakeOp: ExprCallable {
    public let name = "take"
    public init() {}
    public func arity() -> Int { 2 }

    public func call(_ evaluator: ASTEvaluator, _ arguments: [ASTNode]) throws -> ExprValue? {
        guard arguments.count == arity() else {
            throw ExpressionError.invalidExpression("Incorrect argument size")
        }

        guard let list = try evaluator.eval(arguments[0])?.listValue else { return .null }
        let count = max(0, try evaluator.eval(arguments[1])?.intValue ?? 0)

        return .list(Array(list.prefix(count)))
    }
}

public struct ReversedOp: ExprCallable {
    public let name = "reversed"
    public init() {}
    public func arity() -> Int { 1 }

    public func call(_ evaluator: ASTEvaluator, _ arguments: [ASTNode]) throws -> ExprValue? {
        guard arguments.count == arity() else {
            throw ExpressionError.invalidExpression("Incorrect argument size")
        }

        guard let list = try evaluator.eval(arguments[0])?.listValue else { return .null }
        return .list(list.reversed())
    }
}
