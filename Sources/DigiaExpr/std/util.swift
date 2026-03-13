func stringify(_ value: ExprValue?) -> String {
    guard let value else { return "" }
    switch value {
    case .null: return ""
    case .string(let v): return v
    case .int(let v): return String(v)
    case .double(let v): return String(v)
    case .bool(let v): return v ? "true" : "false"
    case .list(let v): return v.map { stringify($0) }.joined()
    case .map, .callable, .instance: return String(describing: value)
    }
}

func numericValue(_ value: ExprValue?, defaultValue: Double = 0) -> Double {
    switch value {
    case .int(let v): return Double(v)
    case .double(let v): return v
    default: return defaultValue
    }
}

func looselyEqual(_ lhs: ExprValue?, _ rhs: ExprValue?) -> Bool {
    switch (lhs, rhs) {
    case (.int(let a), .int(let b)): return a == b
    case (.double(let a), .double(let b)): return a == b
    case (.int(let a), .double(let b)): return Double(a) == b
    case (.double(let a), .int(let b)): return a == Double(b)
    case (.bool(let a), .bool(let b)): return a == b
    case (.string(let a), .string(let b)): return a == b
    case (.null, .null), (nil, nil): return true
    case (.null, nil), (nil, .null): return true
    default: return false
    }
}

extension Double {
    var normalizedNumber: ExprValue {
        rounded(.towardZero) == self ? .int(Int(self)) : .double(self)
    }
}
