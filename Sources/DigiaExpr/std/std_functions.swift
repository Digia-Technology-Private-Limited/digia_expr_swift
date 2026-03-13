public enum StdLibFunctions {
    public static var functions: [String: any ExprCallable] {
        LogicalOperations.functions
            .merging(MathOperations.functions) { _, rhs in rhs }
            .merging(StringOperations.functions) { _, rhs in rhs }
            .merging(JsonOperations.functions) { _, rhs in rhs }
            .merging(DateTimeOperations.functions) { _, rhs in rhs }
            .merging(IterableOperations.functions) { _, rhs in rhs }
            .merging([
                "toInt": ToIntOp(),
                "isEmpty": IsEmptyOp(),
                "length": LengthOp(),
                "strLength": LengthOp(),
                "numberFormat": NumberFormatOp(),
                "qsEncode": QsEncodeOp(),
            ]) { _, rhs in rhs }
    }
}

public struct IsEmptyOp: ExprCallable {
    public let name = "isEmpty"
    public init() {}
    public func arity() -> Int { 1 }

    public func call(_ evaluator: ASTEvaluator, _ arguments: [ASTNode]) throws -> ExprValue? {
        guard arguments.count == arity() else {
            throw ExpressionError.invalidExpression("Incorrect argument size")
        }

        switch try evaluator.eval(arguments[0]) {
        case .int(let v): return .bool(v == 0)
        case .double(let v): return .bool(v == 0)
        case .bool(let v): return .bool(v)
        case .string(let v): return .bool(v.isEmpty)
        case .list(let v): return .bool(v.isEmpty)
        case .map(let v): return .bool(v.isEmpty)
        case .null, nil: return .bool(true)
        default: return .bool(false)
        }
    }
}

public struct LengthOp: ExprCallable {
    public let name = "length"
    public init() {}
    public func arity() -> Int { 1 }

    public func call(_ evaluator: ASTEvaluator, _ arguments: [ASTNode]) throws -> ExprValue? {
        guard arguments.count == arity() else {
            throw ExpressionError.invalidExpression("Incorrect argument size")
        }

        switch try evaluator.eval(arguments[0]) {
        case .string(let v): return .int(v.count)
        case .list(let v): return .int(v.count)
        case .map(let v): return .int(v.count)
        default: return .null
        }
    }
}

public struct ToIntOp: ExprCallable {
    public let name = "toInt"
    public init() {}
    public func arity() -> Int { 1 }

    public func call(_ evaluator: ASTEvaluator, _ arguments: [ASTNode]) throws -> ExprValue? {
        guard arguments.count == arity() else {
            throw ExpressionError.invalidExpression("Incorrect argument size")
        }

        switch try evaluator.eval(arguments[0]) {
        case .int(let v): return .int(v)
        case .double(let v): return .int(Int(v))
        case .string(let v):
            if v.hasPrefix("0x"), let result = Int(v.dropFirst(2), radix: 16) {
                return .int(result)
            }
            if let double = Double(v) { return .int(Int(double)) }
            return .null
        default: return .null
        }
    }
}

public struct NumberFormatOp: ExprCallable {
    public let name = "numberFormat"
    public init() {}
    public func arity() -> Int { 2 }

    public func call(_ evaluator: ASTEvaluator, _ arguments: [ASTNode]) throws -> ExprValue? {
        guard !arguments.isEmpty, arguments.count <= arity() else {
            throw ExpressionError.invalidExpression("Incorrect argument size")
        }

        let rawValue = try evaluator.eval(arguments[0])
        let pattern = try arguments.count > 1 ? evaluator.eval(arguments[1])?.stringValue : "##,##,###"
        guard let pattern else { return .null }

        let intValue: Int?
        switch rawValue {
        case .int(let v): intValue = v
        case .double(let v): intValue = Int(v)
        default: return .null
        }

        guard let intValue else { return .null }
        return .string(formatInteger(intValue, pattern: pattern))
    }

    private func formatInteger(_ value: Int, pattern: String) -> String {
        let sign = value < 0 ? "-" : ""
        let digits = String(abs(value))
        let groups = pattern.split(separator: ",").map(\.count)
        let terminal = groups.last ?? 3
        let repeating = groups.dropLast().last ?? terminal

        guard digits.count > terminal else { return sign + digits }

        var parts: [String] = []
        var end = digits.endIndex
        var start = digits.index(end, offsetBy: -terminal)
        parts.insert(String(digits[start..<end]), at: 0)
        end = start

        while end > digits.startIndex {
            let distance = digits.distance(from: digits.startIndex, to: end)
            let size = min(repeating, distance)
            start = digits.index(end, offsetBy: -size)
            parts.insert(String(digits[start..<end]), at: 0)
            end = start
        }

        return sign + parts.joined(separator: ",")
    }
}

public struct QsEncodeOp: ExprCallable {
    public let name = "qsEncode"
    public init() {}
    public func arity() -> Int { 1 }

    public func call(_ evaluator: ASTEvaluator, _ arguments: [ASTNode]) throws -> ExprValue? {
        guard arguments.count == arity() else {
            throw ExpressionError.invalidExpression("Incorrect argument size")
        }

        let value = try evaluator.eval(arguments[0])
        var components: [String] = []
        appendQueryItems(prefix: nil, value: value, into: &components)
        return .string(components.joined(separator: "&"))
    }

    private func appendQueryItems(prefix: String?, value: ExprValue?, into components: inout [String]) {
        switch value {
        case .map(let dict):
            for key in dict.keys.sorted() {
                let nextPrefix = prefix.map { "\($0)[\(key)]" } ?? key
                appendQueryItems(prefix: nextPrefix, value: dict[key], into: &components)
            }
        case .list(let array):
            for item in array {
                appendQueryItems(prefix: prefix, value: item, into: &components)
            }
        case .string(let s):
            if let prefix { components.append("\(prefix)=\(s)") }
        case .bool(let b):
            if let prefix { components.append("\(prefix)=\(b ? "true" : "false")") }
        case .int(let i):
            if let prefix { components.append("\(prefix)=\(i)") }
        case .double(let d):
            if let prefix { components.append("\(prefix)=\(d)") }
        case .null, nil:
            break
        default:
            if let prefix { components.append("\(prefix)=\(String(describing: value!))") }
        }
    }
}
