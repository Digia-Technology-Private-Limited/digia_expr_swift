import DigiaExpr
import Testing

// MARK: - Helpers

private func eval(_ source: String, _ vars: [String: Any?] = [:]) throws -> Any? {
    try Expression.eval(source, BasicExprContext(variables: vars))
}

// MARK: - Literals

@Suite("Literal evaluation")
struct LiteralTests {
    @Test("integer literal")
    func integerLiteral() throws {
        #expect(try eval("42") as? Int == 42)
    }

    @Test("float literal")
    func floatLiteral() throws {
        #expect(try eval("3.14") as? Double == 3.14)
    }

    @Test("boolean literals")
    func booleanLiterals() throws {
        #expect(try eval("true") as? Bool == true)
        #expect(try eval("false") as? Bool == false)
        #expect(try eval("True") as? Bool == true)
        #expect(try eval("False") as? Bool == false)
    }

    @Test("string literals: single and double quotes")
    func stringLiterals() throws {
        #expect(try eval("'hello'") as? String == "hello")
        #expect(try eval("\"world\"") as? String == "world")
    }
}

// MARK: - Variables & Context

@Suite("Variables and context")
struct VariableTests {
    @Test("wrapped variable expression")
    func wrappedVariable() throws {
        #expect(try eval("${screenName}", ["screenName": "home"]) as? String == "home")
        #expect(try eval("${count}", ["count": 7]) as? Int == 7)
    }

    @Test("bare variable lookup")
    func bareVariable() throws {
        #expect(try eval("title", ["title": "Checkout"]) as? String == "Checkout")
    }

    @Test("falls back through enclosing contexts")
    func enclosingContextFallback() throws {
        let appContext = BasicExprContext(variables: ["apiKey": "prod_123"])
        let pageContext = BasicExprContext(variables: ["title": "Checkout"])
        pageContext.addContextAtTail(appContext)

        #expect(try Expression.eval("title", pageContext) as? String == "Checkout")
        #expect(try Expression.eval("apiKey", pageContext) as? String == "prod_123")
    }

    @Test("throws for undefined variables")
    func throwsForUndefined() {
        #expect(throws: ExpressionError.undefinedVariable("missing")) {
            try eval("${missing}", ["known": 1])
        }
    }

    @Test("throws for trailing tokens")
    func throwsForTrailingTokens() {
        #expect(throws: ExpressionError.invalidExpression("Unexpected trailing token: trailing")) {
            try eval("sum(1, 2) trailing")
        }
    }
}

// MARK: - String Interpolation

@Suite("String interpolation")
struct InterpolationTests {
    @Test("single interpolation")
    func singleInterpolation() throws {
        #expect(try eval("Hello ${aVar}!", ["aVar": "World"]) as? String == "Hello World!")
    }

    @Test("multiple interpolations")
    func multipleInterpolations() throws {
        let vars: [String: Any?] = ["a": "Alpha", "b": "Beta"]
        #expect(try eval("Hello ${a} & ${b}!", vars) as? String == "Hello Alpha & Beta!")
        #expect(try eval("${a}", vars) as? String == "Alpha")
        #expect(try eval("${a}, ${b}", vars) as? String == "Alpha, Beta")
    }

    @Test("interpolation inside quoted text")
    func interpolationInsideQuotedText() throws {
        #expect(try eval("He said \"${name}\"", ["name": "hello"]) as? String == "He said \"hello\"")
    }
}

// MARK: - Math

@Suite("Math operations")
struct MathTests {
    @Test("sum and multiply")
    func sumAndMultiply() throws {
        #expect(try eval("sum(mul(x,4),y)", ["x": 10, "y": 2]) as? Int == 42)
    }

    @Test("diff and divide")
    func diffAndDivide() throws {
        #expect(try eval("diff(10, 3)") as? Int == 7)
        #expect(try eval("divide(10, 4)") as? Double == 2.5)
    }

    @Test("modulo")
    func modulo() throws {
        #expect(try eval("modulo(10, 3)") as? Int == 1)
    }

    @Test("abs, floor, ceil")
    func absFloorCeil() throws {
        let vars: [String: Any?] = ["negFive": -5, "threeSeven": 3.7, "threeTwo": 3.2]
        #expect(try eval("abs(negFive)", vars) as? Int == 5)
        #expect(try eval("floor(threeSeven)", vars) as? Int == 3)
        #expect(try eval("ceil(threeTwo)", vars) as? Int == 4)
    }

    @Test("clamp")
    func clamp() throws {
        let vars: [String: Any?] = ["negFive": -5]
        #expect(try eval("clamp(15, 0, 10)") as? Int == 10)
        #expect(try eval("clamp(negFive, 0, 10)", vars) as? Int == 0)
        #expect(try eval("clamp(5, 0, 10)") as? Int == 5)
    }
}

// MARK: - Logical Operations

@Suite("Logical operations")
struct LogicalTests {
    @Test("if – truthy without else")
    func ifTruthyNoElse() throws {
        #expect(try eval("${if(true, false)}") as? Bool == false)
    }

    @Test("if – falsy without else returns nil")
    func ifFalsyNoElse() throws {
        #expect(try eval("${if(false, false)}") == nil)
    }

    @Test("if – with else branch")
    func ifWithElse() throws {
        #expect(try eval("${if(true, false, true)}") as? Bool == false)
        #expect(try eval("${if(false, false, true)}") as? Bool == true)
    }

    @Test("multi-if – first truthy")
    func multiIfFirstTruthy() throws {
        #expect(try eval("${if(true, 'a', true, 'b')}") as? String == "a")
    }

    @Test("multi-if – first false, second truthy")
    func multiIfSecondTruthy() throws {
        #expect(try eval("${if(false, 'a', true, 'b')}") as? String == "b")
    }

    @Test("multi-if – all false without else")
    func multiIfAllFalseNoElse() throws {
        #expect(try eval("${if(false, 'a', false, 'b')}") == nil)
    }

    @Test("multi-if – all false with else")
    func multiIfAllFalseWithElse() throws {
        #expect(try eval("${if(false, 'a', false, 'b', 'c')}") as? String == "c")
    }

    @Test("equality operators")
    func equalityOperators() throws {
        #expect(try eval("eq(10, 10)") as? Bool == true)
        #expect(try eval("neq(10, 15)") as? Bool == true)
        #expect(try eval("isEqual(10, 10)") as? Bool == true)
        #expect(try eval("isNotEqual(10, 15)") as? Bool == true)
    }

    @Test("comparison operators")
    func comparisonOperators() throws {
        #expect(try eval("gt(11, 10)") as? Bool == true)
        #expect(try eval("gte(10, 10)") as? Bool == true)
        #expect(try eval("lt(9, 10)") as? Bool == true)
        #expect(try eval("lte(10, 10)") as? Bool == true)
        #expect(try eval("${gt(1, 2)}") as? Bool == false)
        #expect(try eval("${gt(2.1, 1.2)}") as? Bool == true)
        #expect(try eval("${gte(1.2, 2.1)}") as? Bool == false)
        #expect(try eval("${gte(2.1, 2.1)}") as? Bool == true)
        #expect(try eval("${lt(1, 2)}") as? Bool == true)
        #expect(try eval("${lt(2.1, 1.2)}") as? Bool == false)
        #expect(try eval("${lte(1.2, 2.1)}") as? Bool == true)
        #expect(try eval("${lte(2.1, 2.1)}") as? Bool == true)
    }

    @Test("boolean operators: not, and, or")
    func booleanOperators() throws {
        #expect(try eval("not(false)") as? Bool == true)
        #expect(try eval("${not(true)}") as? Bool == false)
        #expect(try eval("${not(false)}") as? Bool == true)
        #expect(try eval("and(true, true)") as? Bool == true)
        #expect(try eval("${and(false, true)}") as? Bool == false)
        #expect(try eval("${and(true, true)}") as? Bool == true)
        #expect(try eval("or(false, true)") as? Bool == true)
        #expect(try eval("${or(false, true)}") as? Bool == true)
        #expect(try eval("${or(false, false)}") as? Bool == false)
    }

    @Test("isNull / isNotNull")
    func nullChecks() throws {
        let vars: [String: Any?] = ["payload": ["items": [1, 2, 3]]]
        #expect(try eval("isNotNull(payload.items)", vars) as? Bool == true)
    }

    @Test("or as fallback (nil coalescing)")
    func orAsFallback() throws {
        #expect(try eval("${or(if(false, false), 'a')}") as? String == "a")
        #expect(try eval("${or('b', 'a')}") as? String == "b")
    }
}

// MARK: - String Operations

@Suite("String operations")
struct StringTests {
    @Test("concat")
    func concat() throws {
        #expect(try eval("concat('abc', 'xyz')") as? String == "abcxyz")
        #expect(try eval("concat('Hello ', name)", ["name": "Digia"]) as? String == "Hello Digia")
        #expect(try eval("${concat('tier: ', 'gold')}") as? String == "tier: gold")
    }

    @Test("substring")
    func substring() throws {
        #expect(try eval("substring('hello world', 6)") as? String == "world")
        #expect(try eval("substring('hello world', 0, 5)") as? String == "hello")
        #expect(try eval("substring(title, start)", ["title": "hello world", "start": -2]) as? String == "hello world")
        #expect(try eval("substring(title, 4, end)", ["title": "hello world", "end": -1]) as? String == "")
    }

    @Test("length / strLength")
    func length() throws {
        let vars: [String: Any?] = ["x": "hello-world", "length": 11]
        #expect(try eval("length(title)", ["title": "hello-world"]) as? Int == 11)
        #expect(try eval("strLength(title)", ["title": "hello-world"]) as? Int == 11)
        #expect(try eval("${isEqual(strLength(x), length)}", vars) as? Bool == true)
    }

    @Test("isEmpty")
    func isEmpty() throws {
        #expect(try eval("isEmpty('')") as? Bool == true)
        #expect(try eval("isEmpty('hello')") as? Bool == false)
        #expect(try eval("isEmpty(0)") as? Bool == true)
        #expect(try eval("isEmpty(1)") as? Bool == false)
    }
}

// MARK: - JSON / Dot Notation

@Suite("JSON and dot-notation access")
struct JsonTests {
    @Test("dot notation on nested maps")
    func dotNotationNestedMaps() throws {
        let vars: [String: Any?] = [
            "jsonObject": ["a": ["b": 10, "c": 2]],
        ]
        #expect(try eval("${sum(jsonObject.a.b, jsonObject.a.c)}", vars) as? Int == 12)
    }

    @Test("dotted map lookup and interpolation")
    func dottedLookupInterpolation() throws {
        let vars: [String: Any?] = [
            "person": ["name": "Asha", "profile": ["tier": "gold"]],
        ]
        #expect(try eval("${person.name}", vars) as? String == "Asha")
        #expect(try eval("person.profile.tier", vars) as? String == "gold")
        #expect(try eval("Hello ${person.name}!", vars) as? String == "Hello Asha!")
    }

    @Test("jsonGet / get functions")
    func jsonGetFunctions() throws {
        let vars: [String: Any?] = [
            "dataSource": ["data": ["liveLearning": ["img": "https://img.example/test.png"]]],
        ]
        #expect(
            try eval("jsonGet(dataSource, 'data.liveLearning.img')", vars) as? String
                == "https://img.example/test.png"
        )
        #expect(
            try eval("get(dataSource, 'data.liveLearning.img')", vars) as? String
                == "https://img.example/test.png"
        )
    }
}

// MARK: - Objects / ExprClass

@Suite("Object and class instance access")
struct ObjectTests {
    @Test("field access on ExprClassInstance")
    func fieldAccess() throws {
        let ctx = BasicExprContext(variables: [
            "person": ExprClassInstance(
                klass: ExprClass(name: "Person", fields: ["name": "Tushar"], methods: [:])
            ),
        ])
        #expect(try Expression.eval("Hello ${person.name}!", ctx) as? String == "Hello Tushar!")
    }

    @Test("method call on ExprClassInstance")
    func methodCall() throws {
        let data = ["count": 10]
        let ctx = BasicExprContext(variables: [
            "storage": ExprClassInstance(
                klass: ExprClass(
                    name: "LocalStorage",
                    fields: [:],
                    methods: [
                        "get": ExprCallableImpl(name: "TestMethod") { evaluator, arguments in
                            let key = try evaluator.eval(arguments[0])?.stringValue
                            return key.flatMap { data[$0] }.map { .int($0) }
                        },
                    ]
                )
            ),
        ])
        #expect(try Expression.eval("${storage.get('count')}", ctx) as? Int == 10)
    }

    @Test("field access on nested object graph")
    func nestedObjectGraph() throws {
        let testValue = 10
        let ctx = BasicExprContext(variables: [
            "a": ExprClassInstance(
                klass: ExprClass(
                    name: "Test",
                    fields: [
                        "b": ExprClassInstance(
                            klass: ExprClass(
                                name: "Test",
                                fields: [
                                    "c": ExprClassInstance(
                                        klass: ExprClass(
                                            name: "Test",
                                            fields: [:],
                                            methods: [
                                                "d": ExprCallableImpl(name: "d") { _, _ in .int(testValue) },
                                            ]
                                        )
                                    ),
                                ],
                                methods: [:]
                            )
                        ),
                        "e": testValue,
                    ],
                    methods: [:]
                )
            ),
        ])
        #expect(try Expression.eval("${sum(a.b.c.d(), a.e)}", ctx) as? Int == 20)
    }

    @Test("field and method on same instance")
    func fieldAndMethodOnSameInstance() throws {
        let storage = ExprClassInstance(
            klass: ExprClass(
                name: "LocalStorage",
                fields: ["name": "Tushar"],
                methods: [
                    "get": ExprCallableImpl(name: "get", arity: 1) { evaluator, arguments in
                        let key = try evaluator.eval(arguments[0])?.stringValue
                        if key == "count" { return .int(10) }
                        return .null
                    },
                ]
            )
        )
        let ctx = BasicExprContext(variables: ["storage": storage])
        #expect(try Expression.eval("Hello ${storage.name}!", ctx) as? String == "Hello Tushar!")
        #expect(try Expression.eval("${storage.get('count')}", ctx) as? Int == 10)
    }
}

// MARK: - DateTime

@Suite("DateTime operations")
struct DateTimeTests {
    @Test("isoFormat: ordinal day and month name")
    func isoFormatOrdinal() throws {
        #expect(try eval("${isoFormat(isoDate, 'Do MMMM')}", ["isoDate": "2024-06-03T23:42:36Z"]) as? String == "3rd June")
    }

    @Test("isoFormat: leap year day")
    func isoFormatLeapYear() throws {
        #expect(try eval("${isoFormat(isoDate, 'Do MMMM')}", ["isoDate": "2024-02-29T00:00:00Z"]) as? String == "29th February")
    }
}

// MARK: - Number Format

@Suite("numberFormat")
struct NumberFormatTests {
    @Test("default Indian format")
    func defaultIndianFormat() throws {
        #expect(try eval("${numberFormat(456786)}") as? String == "4,56,786")
    }

    @Test("custom three-group format")
    func customThreeGroupFormat() throws {
        #expect(try eval("${numberFormat(123456789, '#,###,000')}") as? String == "123,456,789")
    }

    @Test("custom two-then-three format")
    func customTwoThenThree() throws {
        #expect(try eval("${numberFormat(30000, '##,##,###')}") as? String == "30,000")
    }

    @Test("numberFormat in interpolated condition")
    func numberFormatInCondition() throws {
        let code = "${condition(isEqual(a, b), 'Note: NPCI may flag repeat transactions of the same amount as duplicates and might reject them. As a precaution, we will deduct ₹${numberFormat(b)} from your account.', 'Note: You will receive confirmation emails on each steps')}"
        let ctx: [String: Any?] = ["a": 1001, "b": 1001]
        #expect(
            try eval(code, ctx) as? String
                == "Note: NPCI may flag repeat transactions of the same amount as duplicates and might reject them. As a precaution, we will deduct ₹1,001 from your account."
        )
    }
}

// MARK: - toInt

@Suite("toInt conversions")
struct ToIntTests {
    @Test(arguments: [
        ("${toInt(100)}", 100),
        ("${toInt(100.1)}", 100),
        ("${toInt('100.1')}", 100),
        ("${toInt('0x64')}", 100),
    ])
    func toInt(expression: String, expected: Int) throws {
        #expect(try eval(expression) as? Int == expected)
    }
}

// MARK: - QS Encode

@Suite("qsEncode")
struct QsEncodeTests {
    @Test("encodes nested payload to query string")
    func nestedPayload() throws {
        let payload: [String: Any] = [
            "key1": 11,
            "key2": "str",
            "key3": false,
            "key4": 0,
            "key5": ["cKey1": true],
            "key6": [0, 1],
            "key7": [
                ["cKey1": 233],
                ["cKey2": false],
            ],
        ]
        let actual = try eval("${qsEncode(payload)}", ["payload": payload]) as? String
        #expect(
            actual == "key1=11&key2=str&key3=false&key4=0&key5[cKey1]=true&key6=0&key6=1&key7[cKey1]=233&key7[cKey2]=false"
        )
    }
}

// MARK: - Iterable Operations

@Suite("Iterable operations")
struct IterableTests {
    @Test("contains")
    func contains() throws {
        #expect(try eval("contains(items, 2)", ["items": [1, 2, 3]]) as? Bool == true)
        #expect(try eval("contains(items, 5)", ["items": [1, 2, 3]]) as? Bool == false)
    }

    @Test("elementAt")
    func elementAt() throws {
        #expect(try eval("elementAt(items, 1)", ["items": [10, 20, 30]]) as? Int == 20)
        #expect(try eval("elementAt(items, 5)", ["items": [10, 20, 30]]) == nil)
    }

    @Test("firstElement and lastElement")
    func firstAndLast() throws {
        #expect(try eval("firstElement(items)", ["items": [10, 20, 30]]) as? Int == 10)
        #expect(try eval("lastElement(items)", ["items": [10, 20, 30]]) as? Int == 30)
    }

    @Test("skip")
    func skip() throws {
        let result = try eval("skip(items, 2)", ["items": [1, 2, 3, 4]]) as? [Any]
        #expect(result?.compactMap { $0 as? Int } == [3, 4])

        let negativeResult = try eval("skip(items, count)", ["items": [1, 2, 3, 4], "count": -1]) as? [Any]
        #expect(negativeResult?.compactMap { $0 as? Int } == [1, 2, 3, 4])
    }

    @Test("take")
    func take() throws {
        let result = try eval("take(items, 2)", ["items": [1, 2, 3, 4]]) as? [Any]
        #expect(result?.compactMap { $0 as? Int } == [1, 2])

        let negativeResult = try eval("take(items, count)", ["items": [1, 2, 3, 4], "count": -1]) as? [Any]
        #expect(negativeResult?.compactMap { $0 as? Int } == [])
    }

    @Test("reversed")
    func reversed() throws {
        let result = try eval("reversed(items)", ["items": [1, 2, 3]]) as? [Any]
        #expect(result?.compactMap { $0 as? Int } == [3, 2, 1])
    }
}
