import Foundation

public enum ExpressionError: Error, Equatable, CustomStringConvertible {
    case undefinedVariable(String)
    case undefinedProperty(String)
    case invalidExpression(String)
    case invalidFunction(String)

    public var description: String {
        switch self {
        case let .undefinedVariable(name):
            return "\(name) is not defined"
        case let .undefinedProperty(name):
            return "Undefined property \(name)"
        case let .invalidExpression(source):
            return "Invalid expression: \(source)"
        case let .invalidFunction(name):
            return "Invalid Function: \(name)"
        }
    }
}

public enum Expression {
    public static func eval(_ source: String, _ context: (any ExprContext)? = nil) throws -> Any? {
        let trimmed = source.trimmingCharacters(in: .whitespacesAndNewlines)

        if isExpression(trimmed) {
            let expression = String(trimmed.dropFirst(2).dropLast())
            return try ASTEvaluator(context).eval(createAST(expression))?.asAny
        }

        if hasExpression(trimmed) {
            return try ASTEvaluator(context).eval(createAST(wrapWithQuotes(trimmed)))?.asAny
        }

        return try ASTEvaluator(context).eval(createAST(trimmed))?.asAny
    }

    public static func hasExpression(_ string: String) -> Bool {
        string.trimmingCharacters(in: .whitespacesAndNewlines)
            .range(of: expressionSyntaxRegex, options: .regularExpression) != nil
    }

    public static func isExpression(_ string: String) -> Bool {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.hasPrefix("${"), trimmed.hasSuffix("}") else {
            return false
        }

        return wrapsSingleBalancedExpression(trimmed)
    }

    private static func wrapWithQuotes(_ string: String) -> String {
        if string.first == "'", string.last == "'" {
            return string
        }
        return "\"\(string)\""
    }

    private static func wrapsSingleBalancedExpression(_ string: String) -> Bool {
        let chars = Array(string)
        guard chars.count >= 3, chars[0] == "$", chars[1] == "{", chars.last == "}" else {
            return false
        }

        var depth = 0
        var quote: Character?
        var previous: Character?

        for index in chars.indices {
            let char = chars[index]

            if let activeQuote = quote {
                if char == activeQuote, previous != "\\" {
                    quote = nil
                }
                previous = char
                continue
            }

            if char == "\"" || char == "'" {
                quote = char
                previous = char
                continue
            }

            if char == "{", index > 0, chars[index - 1] == "$" {
                depth += 1
            } else if char == "}" {
                depth -= 1
                if depth == 0, index != chars.index(before: chars.endIndex) {
                    return false
                }
            }

            previous = char
        }

        return depth == 0 && quote == nil
    }
}
