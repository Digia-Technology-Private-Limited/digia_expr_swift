public enum LogicalOperations {
    public static var functions: [String: any ExprCallable] {
        [
            "isEqual": IsEqualOp(),
            "isNotEqual": IsNotEqualOp(),
            "isNull": IsNullOp(),
            "isNotNull": IsNotNullOp(),
            "condition": IfOp(),
            "if": IfOp(),
            "eq": IsEqualOp(),
            "neq": IsNotEqualOp(),
            "gt": GreaterThanOp(),
            "gte": GreaterThanOrEqualOp(),
            "lt": LessThanOp(),
            "lte": LessThanOrEqualOp(),
            "not": NotOp(),
            "or": OrOp(),
            "and": AndOp(),
        ]
    }
}

public struct IfOp: ExprCallable {
    public let name = "if"
    public init() {}
    public func arity() -> Int { 255 }

    public func call(_ evaluator: ASTEvaluator, _ arguments: [ASTNode]) throws -> ExprValue? {
        guard arguments.count >= 2 else {
            throw ExpressionError.invalidExpression("Can not resolve for less than 2 arguments")
        }

        let defaultCase: ASTNode? = arguments.count.isMultiple(of: 2) ? nil : arguments.last
        let lengthToIterate = arguments.count - (arguments.count % 2)

        var index = 0
        while index < lengthToIterate {
            let condition = try evaluator.eval(arguments[index])?.boolValue
            if condition == true {
                return try evaluator.eval(arguments[index + 1])
            }
            index += 2
        }

        guard let defaultCase else { return .null }
        return try evaluator.eval(defaultCase)
    }
}

public struct IsEqualOp: ExprCallable {
    public let name = "isEqual"
    public init() {}
    public func arity() -> Int { 2 }

    public func call(_ evaluator: ASTEvaluator, _ arguments: [ASTNode]) throws -> ExprValue? {
        guard arguments.count >= 2 else {
            throw ExpressionError.invalidExpression("Incorrect argument size")
        }
        return .bool(looselyEqual(try evaluator.eval(arguments[0]), try evaluator.eval(arguments[1])))
    }
}

public struct IsNotEqualOp: ExprCallable {
    public let name = "isNotEqual"
    public init() {}
    public func arity() -> Int { 2 }

    public func call(_ evaluator: ASTEvaluator, _ arguments: [ASTNode]) throws -> ExprValue? {
        guard arguments.count >= 2 else {
            throw ExpressionError.invalidExpression("Incorrect argument size")
        }
        return .bool(!looselyEqual(try evaluator.eval(arguments[0]), try evaluator.eval(arguments[1])))
    }
}

public struct IsNullOp: ExprCallable {
    public let name = "isNull"
    public init() {}
    public func arity() -> Int { 1 }

    public func call(_ evaluator: ASTEvaluator, _ arguments: [ASTNode]) throws -> ExprValue? {
        guard arguments.count <= 1 else {
            throw ExpressionError.invalidExpression("Incorrect argument size")
        }
        guard let first = arguments.first else { return .bool(true) }
        let value = try evaluator.eval(first)
        return .bool(value == nil || value == .null)
    }
}

public struct IsNotNullOp: ExprCallable {
    public let name = "isNotNull"
    public init() {}
    public func arity() -> Int { 1 }

    public func call(_ evaluator: ASTEvaluator, _ arguments: [ASTNode]) throws -> ExprValue? {
        guard arguments.count <= 1 else {
            throw ExpressionError.invalidExpression("Incorrect argument size")
        }
        guard let first = arguments.first else { return .bool(false) }
        let value = try evaluator.eval(first)
        return .bool(value != nil && value != .null)
    }
}

public struct GreaterThanOp: ExprCallable {
    public let name = "gt"
    public init() {}
    public func arity() -> Int { 2 }

    public func call(_ evaluator: ASTEvaluator, _ arguments: [ASTNode]) throws -> ExprValue? {
        guard arguments.count == 2 else {
            throw ExpressionError.invalidExpression("Invalid argument count")
        }
        return .bool(numericValue(try evaluator.eval(arguments[0])) > numericValue(try evaluator.eval(arguments[1])))
    }
}

public struct GreaterThanOrEqualOp: ExprCallable {
    public let name = "gte"
    public init() {}
    public func arity() -> Int { 2 }

    public func call(_ evaluator: ASTEvaluator, _ arguments: [ASTNode]) throws -> ExprValue? {
        guard arguments.count == 2 else {
            throw ExpressionError.invalidExpression("Invalid argument count")
        }
        return .bool(numericValue(try evaluator.eval(arguments[0])) >= numericValue(try evaluator.eval(arguments[1])))
    }
}

public struct LessThanOp: ExprCallable {
    public let name = "lt"
    public init() {}
    public func arity() -> Int { 2 }

    public func call(_ evaluator: ASTEvaluator, _ arguments: [ASTNode]) throws -> ExprValue? {
        guard arguments.count == 2 else {
            throw ExpressionError.invalidExpression("Invalid argument count")
        }
        return .bool(numericValue(try evaluator.eval(arguments[0])) < numericValue(try evaluator.eval(arguments[1])))
    }
}

public struct LessThanOrEqualOp: ExprCallable {
    public let name = "lte"
    public init() {}
    public func arity() -> Int { 2 }

    public func call(_ evaluator: ASTEvaluator, _ arguments: [ASTNode]) throws -> ExprValue? {
        guard arguments.count == 2 else {
            throw ExpressionError.invalidExpression("Invalid argument count")
        }
        return .bool(numericValue(try evaluator.eval(arguments[0])) <= numericValue(try evaluator.eval(arguments[1])))
    }
}

public struct NotOp: ExprCallable {
    public let name = "not"
    public init() {}
    public func arity() -> Int { 1 }

    public func call(_ evaluator: ASTEvaluator, _ arguments: [ASTNode]) throws -> ExprValue? {
        guard arguments.count == 1 else {
            throw ExpressionError.invalidExpression("Invalid argument count")
        }
        guard let value = try evaluator.eval(arguments[0])?.boolValue else { return .null }
        return .bool(!value)
    }
}

public struct OrOp: ExprCallable {
    public let name = "or"
    public init() {}
    public func arity() -> Int { 2 }

    public func call(_ evaluator: ASTEvaluator, _ arguments: [ASTNode]) throws -> ExprValue? {
        guard arguments.count == 2 else {
            throw ExpressionError.invalidExpression("Invalid argument count")
        }

        let lhs = try evaluator.eval(arguments[0])
        let rhs = try evaluator.eval(arguments[1])

        if let lhsBool = lhs?.boolValue, let rhsBool = rhs?.boolValue {
            return .bool(lhsBool || rhsBool)
        }

        if let lhs, !lhs.isNull { return lhs }
        return rhs
    }
}

public struct AndOp: ExprCallable {
    public let name = "and"
    public init() {}
    public func arity() -> Int { 2 }

    public func call(_ evaluator: ASTEvaluator, _ arguments: [ASTNode]) throws -> ExprValue? {
        guard arguments.count == 2 else {
            throw ExpressionError.invalidExpression("Invalid argument count")
        }

        guard let lhs = try evaluator.eval(arguments[0])?.boolValue,
              let rhs = try evaluator.eval(arguments[1])?.boolValue else {
            return .bool(false)
        }

        return .bool(lhs && rhs)
    }
}
