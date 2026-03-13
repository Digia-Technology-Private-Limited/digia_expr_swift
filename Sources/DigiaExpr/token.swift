public enum TokenType: Sendable {
    case leftParen
    case rightParen
    case comma
    case dot
    case semicolon
    case newLine
    case variable
    case string
    case integer
    case float
    case no
    case yes
    case eof
}

public struct Token: Equatable, Sendable, CustomStringConvertible {
    public let type: TokenType
    public let lexeme: String
    public let line: Int

    public init(type: TokenType, lexeme: String, line: Int) {
        self.type = type
        self.lexeme = lexeme
        self.line = line
    }

    public var description: String {
        "{ type: \(type), lexeme: \(lexeme), line: \(line) }"
    }
}
