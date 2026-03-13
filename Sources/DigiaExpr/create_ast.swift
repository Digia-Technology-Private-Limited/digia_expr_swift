public func createAST(_ source: String) throws -> ASTNode {
    var scanner = Scanner(source: source)
    let tokens = try scanner.scanTokens()
    var parser = Parser(tokens: tokens)
    return try parser.parse()
}
