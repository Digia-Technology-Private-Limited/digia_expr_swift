# Digia Expr (Swift)

A powerful and flexible expression evaluator for Swift, designed to dynamically process expressions with support for variables, custom functions, and string interpolation.

> **Note**: This package is developed for internal use within Digia SDKs and is not intended for general public consumption.
> Supported platform: iOS 16.0+.

## Key Features

- Evaluate expressions: mathematical, logical, and property access expressions
- Rich standard library: math, logical, string, datetime, JSON, and iterable helpers
- Extensible context model: compose nested expression contexts

## Installation

### Swift Package Manager

Add this package in Xcode using the repository URL, or add it in `Package.swift`:

```swift
dependencies: [
    .package(
        url: "https://github.com/Digia-Technology-Private-Limited/digia_expr_swift.git",
        from: "0.1.0"
    ),
]
```

Then depend on `DigiaExpr`.

### CocoaPods

Add `DigiaExpr` to your `Podfile`:

```ruby
pod 'DigiaExpr', '0.1.0'
```

If you are distributing this internally through a private specs repo, add that specs source before running `pod install`.

## Usage

### Basic Expression Evaluation

```swift
import DigiaExpr

let context = BasicExprContext(variables: [
    "user": ["name": "John Doe", "age": 30]
])

let name = try Expression.eval("user.name", context) as? String
print(name ?? "") // John Doe
```

### Wrapped Expressions and Interpolation

```swift
import DigiaExpr

let vars: [String: Any?] = [
    "firstName": "John",
    "count": 7,
]

let message = try Expression.eval("Hello ${firstName}!", BasicExprContext(variables: vars)) as? String
let value = try Expression.eval("${count}", BasicExprContext(variables: vars)) as? Int
```

## Exported Components

When you import `DigiaExpr`, you get access to:

- `Expression`: main evaluation entrypoint
- `BasicExprContext`: basic variable-backed expression context
- `ExprContext`: context abstraction for custom implementations
- `createAST()`: parse expressions into AST nodes
- AST node models and evaluator internals used by the expression engine
- Standard functions registered via `StdLibFunctions`

## Running Tests

```bash
swift test
```

## Release

- Swift Package Manager distribution is driven by git tags. Tag and push `0.1.0`.
- CocoaPods distribution is driven by `DigiaExpr.podspec`.
- This package targets iOS only.
- For an internal/private CocoaPods setup, publish the podspec to your private specs repo.
- For public CocoaPods trunk, the source repository and tag referenced by the podspec must be publicly reachable.

## Changelog

See `CHANGELOG.md`.

## License

This project is licensed under Business Source License 1.1. See `LICENSE`.

---

Built with ❤️ by the Digia team
