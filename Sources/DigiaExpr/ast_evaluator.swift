public final class ASTEvaluator {
    private let context: any ExprContext
    private let functionHandlers: [String: any ExprCallable]

    public init(
        _ context: (any ExprContext)?,
        functions: [String: any ExprCallable] = [:]
    ) {
        self.context = context ?? BasicExprContext(variables: [:])
        self.functionHandlers = StdLibFunctions.functions.merging(functions) { _, rhs in rhs }
    }

    public func eval(_ node: ASTNode) throws -> ExprValue? {
        switch node {
        case let program as ASTProgram:
            guard let first = program.body.first else {
                throw ExpressionError.invalidExpression("Empty program")
            }
            return try eval(first)

        case let number as ASTNumberLiteral:
            guard let raw = number.value else { return .null }
            if let i = raw as? Int { return .int(i) }
            if let d = raw as? Double { return .double(d) }
            return .null

        case let boolean as ASTBooleanLiteral:
            return .bool(boolean.value)

        case let string as ASTStringLiteral:
            guard let v = string.value else { return .null }
            return .string(v)

        case let expression as ASTStringExpression:
            return try ConcatOp().call(self, expression.parts)

        case let call as ASTCallExpression:
            let callee = try eval(call.fnName)
            guard let callable = callee?.callableValue else {
                throw ExpressionError.invalidFunction(String(describing: call.fnName))
            }
            return try callable.call(self, call.expressions)

        case let variable as ASTVariable:
            let record = context.getValue(variable.name.lexeme)
            if !record.found, let handler = functionHandlers[variable.name.lexeme] {
                return .callable(handler)
            }
            guard record.found else {
                throw ExpressionError.undefinedVariable(variable.name.lexeme)
            }

            guard let value = record.value, !value.isNull else {
                return .null
            }

            return value

        case let getExpr as ASTGetExpr:
            guard let object = try eval(getExpr.expr) else { return .null }
            if object.isNull { return .null }

            if let dict = object.mapValue {
                return dict[getExpr.name.lexeme] ?? .null
            }

            guard let instance = object.instanceValue else {
                throw ExpressionError.invalidExpression("Only class instances have properties")
            }

            return try instance.getField(getExpr.name.lexeme)

        default:
            throw ExpressionError.invalidExpression("\(node.type) is not implemented")
        }
    }
}
