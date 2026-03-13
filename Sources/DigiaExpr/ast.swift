public enum AstNodeType: Sendable {
    case program
    case callExpression
    case numberLiteral
    case stringExpression
    case stringLiteral
    case variable
    case getExpr
    case boolean
}

public protocol ASTNode {
    var type: AstNodeType { get }
}

public struct ASTBooleanLiteral: ASTNode, Sendable {
    public let token: Token
    public let value: Bool
    public var type: AstNodeType { .boolean }

    public init(token: Token) {
        self.token = token
        self.value = token.type == .yes
    }
}

public struct ASTProgram: ASTNode, @unchecked Sendable {
    public var body: [ASTNode]
    public var type: AstNodeType { .program }

    public init(body: [ASTNode]) {
        self.body = body
    }
}

public struct ASTCallExpression: ASTNode, @unchecked Sendable {
    public let fnName: ASTNode
    public let expressions: [ASTNode]
    public var type: AstNodeType { .callExpression }

    public init(fnName: ASTNode, expressions: [ASTNode]) {
        self.fnName = fnName
        self.expressions = expressions
    }
}

public struct ASTNumberLiteral: ASTNode, @unchecked Sendable {
    private let storedValue: (any Numeric)?
    private let getter: Getter<(any Numeric)?>?

    public var type: AstNodeType { .numberLiteral }

    public var value: (any Numeric)? {
        storedValue ?? getter?()
    }

    public init(value: (any Numeric)? = nil, getter: Getter<(any Numeric)?>? = nil) {
        self.storedValue = value
        self.getter = getter
    }
}

public struct ASTStringExpression: ASTNode, @unchecked Sendable {
    public let parts: [ASTNode]
    public var type: AstNodeType { .stringExpression }

    public init(parts: [ASTNode]) {
        self.parts = parts
    }
}

public struct ASTStringLiteral: ASTNode, @unchecked Sendable {
    private let storedValue: String?
    private let getter: Getter<String?>?

    public var type: AstNodeType { .stringLiteral }
    public var value: String? { storedValue ?? getter?() }

    public init(value: String? = nil, getter: Getter<String?>? = nil) {
        self.storedValue = value
        self.getter = getter
    }
}

public struct ASTVariable: ASTNode, Sendable {
    public let name: Token
    public var type: AstNodeType { .variable }

    public init(name: Token) {
        self.name = name
    }
}

public struct ASTGetExpr: ASTNode, @unchecked Sendable {
    public let name: Token
    public let expr: ASTNode
    public var type: AstNodeType { .getExpr }

    public init(name: Token, expr: ASTNode) {
        self.name = name
        self.expr = expr
    }
}
