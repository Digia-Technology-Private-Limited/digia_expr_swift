public protocol ExprCallable: Sendable {
    var name: String { get }
    func arity() -> Int
    func call(_ evaluator: ASTEvaluator, _ arguments: [ASTNode]) throws -> ExprValue?
}

public struct ExprCallableImpl: ExprCallable {
    private let _name: String
    private let _arity: Int
    private let fn: @Sendable (ASTEvaluator, [ASTNode]) throws -> ExprValue?

    public init(
        name: String,
        arity: Int = 0,
        fn: @Sendable @escaping (ASTEvaluator, [ASTNode]) throws -> ExprValue?
    ) {
        self._name = name
        self._arity = arity
        self.fn = fn
    }

    public var name: String { _name }
    public func arity() -> Int { _arity }
    public func call(_ evaluator: ASTEvaluator, _ arguments: [ASTNode]) throws -> ExprValue? {
        try fn(evaluator, arguments)
    }
}

public typealias Getter<T> = () -> T

public protocol ExprInstance {
    func getField(_ name: String) throws -> ExprValue?
}

public final class ExprClass: ExprCallable, @unchecked Sendable {
    private let className: String
    public var fields: [String: ExprValue]
    public var methods: [String: any ExprCallable]

    public init(
        name: String,
        fields: [String: Any?],
        methods: [String: any ExprCallable]
    ) {
        self.className = name
        self.fields = fields.mapValues { ExprValue.from($0 ?? nil) }
        self.methods = methods
    }

    public var name: String { className }
    public func arity() -> Int { 0 }

    public func call(_ evaluator: ASTEvaluator, _ arguments: [ASTNode]) throws -> ExprValue? {
        .instance(ExprClassInstance(klass: self))
    }
}

public final class ExprClassInstance: ExprInstance, @unchecked Sendable {
    public let klass: ExprClass

    public init(klass: ExprClass) {
        self.klass = klass
    }

    public func set(_ name: Token, value: ExprValue) {
        klass.fields[name.lexeme] = value
    }

    public func getField(_ name: String) throws -> ExprValue? {
        if klass.fields.index(forKey: name) != nil {
            return klass.fields[name] ?? .null
        }

        if let method = klass.methods[name] {
            return .callable(method)
        }

        throw ExpressionError.undefinedProperty(name)
    }
}
