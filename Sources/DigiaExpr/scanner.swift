import Foundation

public struct Scanner {
    public let source: String

    private let chars: [Character]
    private var currentIndex = 0
    private var line = 1
    private var tokens: [Token] = []

    public init(source: String) {
        self.source = source
        self.chars = Array(source)
    }

    public mutating func scanTokens() throws -> [Token] {
        while !isAtEnd {
            guard let char = current() else { break }

            switch char {
            case "(":
                addToken(.leftParen, String(char))
                advance()
            case ")":
                addToken(.rightParen, String(char))
                advance()
            case ",":
                addToken(.comma, String(char))
                advance()
            case ".":
                addToken(.dot, String(char))
                advance()
            case ";":
                addToken(.semicolon, String(char))
                advance()
            case "\n":
                line += 1
                addToken(.newLine, String(char))
                advance()
            case "\"", "'":
                try scanString()
            default:
                if char.isWhitespace {
                    advance()
                } else if char.isNumber {
                    try scanNumber()
                } else if char.isLetter {
                    scanIdentifier()
                } else {
                    throw ExpressionError.invalidExpression("Unknown token \(char)")
                }
            }
        }

        addToken(.eof, "")
        return tokens
    }

    private var isAtEnd: Bool {
        currentIndex >= chars.count
    }

    private func current() -> Character? {
        isAtEnd ? nil : chars[currentIndex]
    }

    private func peek() -> Character? {
        let index = currentIndex + 1
        return index >= chars.count ? nil : chars[index]
    }

    private func peekNext() -> Character? {
        let index = currentIndex + 2
        return index >= chars.count ? nil : chars[index]
    }

    private mutating func advance(by count: Int = 1) {
        currentIndex += count
    }

    private mutating func addToken(_ type: TokenType, _ value: String) {
        tokens.append(Token(type: type, lexeme: value, line: line))
    }

    private mutating func scanString() throws {
        let leftQuote = chars[currentIndex]
        let start = currentIndex
        var previous = chars[currentIndex]
        advance()

        while let char = current() {
            if char == leftQuote, previous != "\\" {
                let value = String(chars[(start + 1)..<currentIndex])
                advance()
                addToken(.string, value)
                return
            }

            previous = char
            if char == "\n" {
                line += 1
            }
            advance()
        }

        throw ExpressionError.invalidExpression("Unterminated String")
    }

    private mutating func scanNumber() throws {
        let start = currentIndex
        var type: TokenType = .integer

        while let char = current(), char.isNumber {
            if peek() == "." {
                guard let next = peekNext(), next.isNumber else {
                    throw ExpressionError.invalidExpression("Invalid Number format")
                }
                type = .float
                advance(by: 2)
            } else {
                advance()
            }
        }

        let value = String(chars[start..<currentIndex])
        addToken(type, value)
    }

    private mutating func scanIdentifier() {
        let start = currentIndex
        while let char = current(), char.isLetter || char.isNumber || char == "_" {
            advance()
        }

        let value = String(chars[start..<currentIndex])
        switch value {
        case "true", "True":
            addToken(.yes, "true")
        case "false", "False":
            addToken(.no, "false")
        default:
            addToken(.variable, value)
        }
    }
}
