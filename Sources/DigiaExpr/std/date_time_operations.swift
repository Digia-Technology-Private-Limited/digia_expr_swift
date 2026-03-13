import Foundation

public enum DateTimeOperations {
    public static var functions: [String: any ExprCallable] {
        [
            "isoFormat": IsoFormatOp(),
        ]
    }
}

public struct IsoFormatOp: ExprCallable {
    public let name = "isoFormat"
    public init() {}
    public func arity() -> Int { 2 }

    public func call(_ evaluator: ASTEvaluator, _ arguments: [ASTNode]) throws -> ExprValue? {
        guard arguments.count >= 2 else {
            throw ExpressionError.invalidExpression("Incorrect argument size")
        }

        let isoString = try evaluator.eval(arguments[0])?.stringValue
        let format = try evaluator.eval(arguments[1])?.stringValue

        guard let result = isoFormat(isoString: isoString, format: format) else { return .null }
        return .string(result)
    }

    private func isoFormat(isoString: String?, format: String?) -> String? {
        guard let isoString, let format else { return nil }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let date = formatter.date(from: isoString) ?? ISO8601DateFormatter().date(from: isoString)
        guard let date else { return nil }

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
        let day = calendar.component(.day, from: date)

        let monthFormatter = DateFormatter()
        monthFormatter.locale = Locale(identifier: "en_US_POSIX")
        monthFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        monthFormatter.dateFormat = "MMMM"
        let month = monthFormatter.string(from: date)

        if format == "Do MMMM" {
            return "\(ordinal(day)) \(month)"
        }

        return nil
    }

    private func ordinal(_ day: Int) -> String {
        let remainder100 = day % 100
        if remainder100 == 11 || remainder100 == 12 || remainder100 == 13 {
            return "\(day)th"
        }

        switch day % 10 {
        case 1: return "\(day)st"
        case 2: return "\(day)nd"
        case 3: return "\(day)rd"
        default: return "\(day)th"
        }
    }
}
