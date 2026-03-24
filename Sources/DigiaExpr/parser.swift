import Foundation

public struct Parser {
    public let tokens: [Token]
    private var currentIndex = 0

    public init(tokens: [Token]) {
        self.tokens = tokens
    }

    public mutating func parse() throws -> ASTNode {
        let expression = try walk()
        skipSeparators()

        if current().type != .eof {
            throw ExpressionError.invalidExpression("Unexpected trailing token: \(current().lexeme)")
        }

        return ASTProgram(body: [expression])
    }

    private mutating func walk() throws -> ASTNode {
        let token = tokens[currentIndex]

        switch token.type {
        case .integer:
            advance()
            return ASTNumberLiteral(value: Int(token.lexeme))

        case .float:
            advance()
            return ASTNumberLiteral(value: Double(token.lexeme))

        case .yes, .no:
            advance()
            return ASTBooleanLiteral(token: token)

        case .string:
            if hasExpression(token.lexeme) {
                let parts = try createStringExpression(token.lexeme)
                advance()
                return ASTStringExpression(parts: parts)
            }

            advance()
            return ASTStringLiteral(value: token.lexeme)

        case .semicolon, .eof:
            advance()
            return ASTStringLiteral(value: token.lexeme)

        case .variable:
            if peek()?.type != .leftParen && peek()?.type != .dot {
                advance()
                return ASTVariable(name: token)
            }

            var expr: ASTNode = ASTVariable(name: token)
            while peek()?.type == .leftParen || peek()?.type == .dot {
                if peek()?.type == .leftParen {
                    advance()
                    advance()

                    var expressions: [ASTNode] = []
                    if current().type != .rightParen {
                        while current().type != .rightParen {
                            expressions.append(try walk())
                            if current().type != .rightParen {
                                try consume(.comma, "Expected , after a function argument")
                            }
                        }
                    }

                    expr = ASTCallExpression(fnName: expr, expressions: expressions)
                } else if peek()?.type == .dot {
                    advance()
                    advance()
                    expr = ASTGetExpr(name: current(), expr: expr)
                }
            }

            advance()
            return expr

        default:
            throw ExpressionError.invalidExpression("Unexpected token: \(token.type)")
        }
    }

    private func current() -> Token {
        tokens[currentIndex]
    }

    private func peek() -> Token? {
        let index = currentIndex + 1
        return index < tokens.count ? tokens[index] : nil
    }

    private mutating func advance() {
        currentIndex += 1
    }

    private mutating func consume(_ tokenType: TokenType, _ errorMessage: String) throws {
        if current().type == tokenType {
            advance()
            return
        }

        throw ExpressionError.invalidExpression(errorMessage)
    }

    private mutating func skipSeparators() {
        while current().type == .semicolon || current().type == .newLine {
            advance()
        }
    }

    private func hasExpression(_ string: String) -> Bool {
        string.range(of: expressionSyntaxRegex, options: .regularExpression) != nil
    }

    private func createStringExpression(_ input: String) throws -> [ASTNode] {
        let regex = try NSRegularExpression(pattern: expressionSyntaxRegex)
        let range = NSRange(input.startIndex..<input.endIndex, in: input)
        var parts: [ASTNode] = []
        var lastIndex = input.startIndex

        for match in regex.matches(in: input, range: range) {
            guard let matchRange = Range(match.range, in: input) else { continue }
            let prefix = String(input[lastIndex..<matchRange.lowerBound])
            if !prefix.isEmpty {
                parts.append(ASTStringLiteral(value: prefix))
            }

            let expression = String(input[matchRange])
            let start = expression.index(expression.startIndex, offsetBy: 2)
            let end = expression.index(before: expression.endIndex)
            parts.append(try createAST(String(expression[start..<end])))
            lastIndex = matchRange.upperBound
        }

        if lastIndex < input.endIndex {
            parts.append(ASTStringLiteral(value: String(input[lastIndex...])))
        }

        return parts
    }
}
