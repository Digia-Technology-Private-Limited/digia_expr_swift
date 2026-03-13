public enum ExprValue: @unchecked Sendable {
    case int(Int)
    case double(Double)
    case string(String)
    case bool(Bool)
    case list([ExprValue])
    case map([String: ExprValue])
    case callable(any ExprCallable)
    case instance(any ExprInstance)
    case null
}

// MARK: - Accessors

public extension ExprValue {
    var intValue: Int? {
        switch self {
        case .int(let v): return v
        case .double(let v): return Int(exactly: v) ?? Int(v)
        default: return nil
        }
    }

    var doubleValue: Double? {
        switch self {
        case .double(let v): return v
        case .int(let v): return Double(v)
        default: return nil
        }
    }

    var stringValue: String? {
        guard case .string(let v) = self else { return nil }
        return v
    }

    var boolValue: Bool? {
        guard case .bool(let v) = self else { return nil }
        return v
    }

    var listValue: [ExprValue]? {
        guard case .list(let v) = self else { return nil }
        return v
    }

    var mapValue: [String: ExprValue]? {
        guard case .map(let v) = self else { return nil }
        return v
    }

    var isNull: Bool {
        if case .null = self { return true }
        return false
    }

    var callableValue: (any ExprCallable)? {
        guard case .callable(let v) = self else { return nil }
        return v
    }

    var instanceValue: (any ExprInstance)? {
        guard case .instance(let v) = self else { return nil }
        return v
    }
}

// MARK: - Bridge to/from Any

public extension ExprValue {
    /// Converts the ExprValue back to an untyped Any? for public API compatibility.
    var asAny: Any? {
        switch self {
        case .int(let v): return v
        case .double(let v): return v
        case .string(let v): return v
        case .bool(let v): return v
        case .list(let v): return v.map { $0.asAny }
        case .map(let v): return v.mapValues { $0.asAny }
        case .callable(let v): return v
        case .instance(let v): return v
        case .null: return nil
        }
    }

    /// Converts an untyped Any? to ExprValue at context/API boundaries.
    static func from(_ value: Any?) -> ExprValue {
        switch value {
        case nil:
            return .null
        case let v as ExprValue:
            return v
        case let v as Bool:
            return .bool(v)
        case let v as Int:
            return .int(v)
        case let v as Double:
            return .double(v)
        case let v as Float:
            return .double(Double(v))
        case let v as String:
            return .string(v)
        case let v as [String: Any?]:
            return .map(v.mapValues { from($0 ?? nil) })
        case let v as [String: Any]:
            return .map(v.mapValues { from($0) })
        case let v as [Any]:
            return .list(v.map { from($0) })
        case let v as any ExprCallable:
            return .callable(v)
        case let v as any ExprInstance:
            return .instance(v)
        default:
            return .null
        }
    }
}

// MARK: - Equatable

extension ExprValue: Equatable {
    public static func == (lhs: ExprValue, rhs: ExprValue) -> Bool {
        switch (lhs, rhs) {
        case (.int(let a), .int(let b)): return a == b
        case (.double(let a), .double(let b)): return a == b
        case (.int(let a), .double(let b)): return Double(a) == b
        case (.double(let a), .int(let b)): return a == Double(b)
        case (.string(let a), .string(let b)): return a == b
        case (.bool(let a), .bool(let b)): return a == b
        case (.null, .null): return true
        case (.list(let a), .list(let b)): return a == b
        case (.map(let a), .map(let b)): return a == b
        default: return false
        }
    }
}

// MARK: - CustomStringConvertible

extension ExprValue: CustomStringConvertible {
    public var description: String {
        switch self {
        case .int(let v): return String(v)
        case .double(let v): return String(v)
        case .string(let v): return v
        case .bool(let v): return v ? "true" : "false"
        case .list(let v): return "[\(v.map(\.description).joined(separator: ", "))]"
        case .map(let v): return "{\(v.sorted(by: { $0.key < $1.key }).map { "\($0.key): \($0.value)" }.joined(separator: ", "))}"
        case .callable(let v): return "[Function: \(v.name)]"
        case .instance: return "[Instance]"
        case .null: return "null"
        }
    }
}
