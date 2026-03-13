import Foundation

public enum MathOperations {
    public static var functions: [String: any ExprCallable] {
        [
            "sum": SumOp(),
            "mul": MulOp(),
            "multiply": MulOp(),
            "diff": DiffOp(),
            "difference": DiffOp(),
            "divide": DivideOp(),
            "modulo": ModuloOp(),
            "ceil": CeilOp(),
            "floor": FloorOp(),
            "abs": AbsOp(),
            "clamp": ClampOp(),
        ]
    }
}

public struct ClampOp: ExprCallable {
    public let name = "clamp"
    public init() {}
    public func arity() -> Int { 3 }

    public func call(_ evaluator: ASTEvaluator, _ arguments: [ASTNode]) throws -> ExprValue? {
        guard arguments.count == 3 else {
            throw ExpressionError.invalidExpression("Can only resolve 3 arguments")
        }

        let value = numericValue(try evaluator.eval(arguments[0]))
        let min = numericValue(try evaluator.eval(arguments[1]))
        let max = numericValue(try evaluator.eval(arguments[2]))

        return Swift.max(min, Swift.min(max, value)).normalizedNumber
    }
}

public struct ModuloOp: ExprCallable {
    public let name = "modulo"
    public init() {}
    public func arity() -> Int { 2 }

    public func call(_ evaluator: ASTEvaluator, _ arguments: [ASTNode]) throws -> ExprValue? {
        guard arguments.count == 2 else {
            throw ExpressionError.invalidExpression("Can only resolve 2 arguments")
        }

        let lhs = numericValue(try evaluator.eval(arguments[0]))
        let rhs = numericValue(try evaluator.eval(arguments[1]), defaultValue: 1)
        return lhs.truncatingRemainder(dividingBy: rhs).normalizedNumber
    }
}

public struct AbsOp: ExprCallable {
    public let name = "abs"
    public init() {}
    public func arity() -> Int { 1 }

    public func call(_ evaluator: ASTEvaluator, _ arguments: [ASTNode]) throws -> ExprValue? {
        guard arguments.count == 1 else {
            throw ExpressionError.invalidExpression("Can only resolve 1 argument")
        }
        return abs(numericValue(try evaluator.eval(arguments[0]))).normalizedNumber
    }
}

public struct FloorOp: ExprCallable {
    public let name = "floor"
    public init() {}
    public func arity() -> Int { 1 }

    public func call(_ evaluator: ASTEvaluator, _ arguments: [ASTNode]) throws -> ExprValue? {
        guard arguments.count == 1 else {
            throw ExpressionError.invalidExpression("Can only resolve 1 argument")
        }
        return Foundation.floor(numericValue(try evaluator.eval(arguments[0]))).normalizedNumber
    }
}

public struct CeilOp: ExprCallable {
    public let name = "ceil"
    public init() {}
    public func arity() -> Int { 1 }

    public func call(_ evaluator: ASTEvaluator, _ arguments: [ASTNode]) throws -> ExprValue? {
        guard arguments.count == 1 else {
            throw ExpressionError.invalidExpression("Can only resolve 1 argument")
        }
        return Foundation.ceil(numericValue(try evaluator.eval(arguments[0]))).normalizedNumber
    }
}

public struct SumOp: ExprCallable {
    public let name = "sum"
    public init() {}
    public func arity() -> Int { 255 }

    public func call(_ evaluator: ASTEvaluator, _ arguments: [ASTNode]) throws -> ExprValue? {
        try arguments.reduce(0 as Double) { partial, argument in
            partial + numericValue(try evaluator.eval(argument))
        }.normalizedNumber
    }
}

public struct MulOp: ExprCallable {
    public let name = "multiply"
    public init() {}
    public func arity() -> Int { 255 }

    public func call(_ evaluator: ASTEvaluator, _ arguments: [ASTNode]) throws -> ExprValue? {
        try arguments.reduce(1 as Double) { partial, argument in
            partial * numericValue(try evaluator.eval(argument), defaultValue: 1)
        }.normalizedNumber
    }
}

public struct DiffOp: ExprCallable {
    public let name = "diff"
    public init() {}
    public func arity() -> Int { 2 }

    public func call(_ evaluator: ASTEvaluator, _ arguments: [ASTNode]) throws -> ExprValue? {
        guard arguments.count >= 2 else {
            throw ExpressionError.invalidExpression("Incorrect argument size")
        }
        let lhs = numericValue(try evaluator.eval(arguments[0]))
        let rhs = numericValue(try evaluator.eval(arguments[1]))
        return (lhs - rhs).normalizedNumber
    }
}

public struct DivideOp: ExprCallable {
    public let name = "divide"
    public init() {}
    public func arity() -> Int { 2 }

    public func call(_ evaluator: ASTEvaluator, _ arguments: [ASTNode]) throws -> ExprValue? {
        guard arguments.count >= 2 else {
            throw ExpressionError.invalidExpression("Incorrect argument size")
        }
        let lhs = numericValue(try evaluator.eval(arguments[0]))
        let rhs = numericValue(try evaluator.eval(arguments[1]), defaultValue: 1)
        return (lhs / rhs).normalizedNumber
    }
}
