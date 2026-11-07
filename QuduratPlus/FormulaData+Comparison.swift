import Foundation

/// نتيجة سؤال المقارنة بترتيب خيارات اختبار القدرات.
enum CompareResult: Int {
    case aGreater = 0, bGreater, equal, unknown

    static let options = ["القيمة الأولى أكبر", "القيمة الثانية أكبر", "القيمتان متساويتان", "المعطيات غير كافية"]

    static func of(_ a: Double, _ b: Double) -> CompareResult {
        if abs(a - b) < 0.000001 { return .equal }
        return a > b ? .aGreater : .bGreater
    }

    var verdict: String { CompareResult.options[rawValue] }
}

extension Example {
    /// سؤال مقارنة: الخيارات الأربعة ثابتة كما في الاختبار.
    static func compare(_ intro: String, a: String, b: String, result: CompareResult, steps: [String]) -> Example {
        var problem = intro.isEmpty ? "" : intro + "\n"
        problem += "قارن بين:\nالقيمة الأولى: " + a + "\nالقيمة الثانية: " + b
        var e = Example.text(problem, steps: steps + ["الإجابة: " + result.verdict],
                             answer: result.verdict,
                             traps: CompareResult.options.filter { $0 != result.verdict })
        e.fixedOptions = CompareResult.options
        return e
    }
}

/// قالب مقارنة جاهز فيه شرط ومتغير.
private struct CompareTemplate {
    let condition: String
    let a: String
    let b: String
    let result: CompareResult
    let reason: String
}

extension FormulaData {

    // MARK: - المقارنات

    static func comparisons() -> [Formula] {
        return [
            Formula(
                id: "cmp_percent", topic: .comparison, title: "مقارنة النسب والكسور",
                expression: "احسب القيمتين أو حوّلهما لصيغة واحدة ثم قارن",
                explanation: "أسئلة المقارنة لها أربعة خيارات ثابتة: الأولى أكبر، الثانية أكبر، متساويتان، المعطيات غير كافية. مع الأعداد المعلومة لا يكون الجواب «غير كافية» أبداً. لمقارنة كسرين اضرب تبادلياً، وتذكّر أن (أ% من ب) = (ب% من أ).",
                trap: "الحساب الكامل المتعب بدل التبسيط، والخلط بين زيادة ثم نقصان بالنسبة نفسها (الناتج أقل من الأصل).",
                gen: { d in
                    switch d {
                    case .easy:
                        if Bool.random() {
                            let p = pick([20, 25, 30, 40, 50, 60, 75])
                            let q = pick([40, 60, 80, 120, 200])
                            return .compare("", a: m("\(p)% من \(q)"), b: m("\(q)% من \(p)"), result: .equal,
                                            steps: ["الأولى: " + m("\(p) × \(q) ÷ 100 = \(fmt(Double(p * q) / 100))"),
                                                    "الثانية: " + m("\(q) × \(p) ÷ 100 = \(fmt(Double(p * q) / 100))"),
                                                    "قاعدة: أ% من ب = ب% من أ دائماً"])
                        }
                        let p = pick([10, 20, 25, 50]), x = pick([40, 80, 120, 200])
                        let q = pick([10, 20, 30, 40]), y = pick([50, 60, 100, 150])
                        let va = Double(p * x) / 100, vb = Double(q * y) / 100
                        return .compare("", a: m("\(p)% من \(x)"), b: m("\(q)% من \(y)"), result: CompareResult.of(va, vb),
                                        steps: ["الأولى: " + m("\(fmt(va))"), "الثانية: " + m("\(fmt(vb))")])
                    case .medium:
                        var a = 0, b = 0, c = 0, dd = 0
                        repeat {
                            a = rnd(2...9); b = rnd(a + 1...15)
                            c = rnd(2...9); dd = rnd(c + 1...15)
                        } while a * dd == b * c && Bool.random()
                        let left = a * dd, right = b * c
                        return .compare("", a: m("\(a)/\(b)"), b: m("\(c)/\(dd)"), result: CompareResult.of(Double(left), Double(right)),
                                        steps: ["نضرب تبادلياً: " + m("\(a) × \(dd) = \(left)") + " و" + m("\(b) × \(c) = \(right)"),
                                                "الكسر الذي بسطه في الضرب التبادلي أكبر هو الأكبر"])
                    case .hard:
                        let price = pick([100, 200, 400, 500])
                        let p = pick([10, 20, 25, 50])
                        if Bool.random() {
                            let after = Double(price) * Double(100 + p) / 100 * Double(100 - p) / 100
                            return .compare("سعر سلعة \(price) دينار، زاد \(p)% ثم نقص \(p)%.",
                                            a: "السعر النهائي", b: m("\(price)"), result: .bGreater,
                                            steps: ["بعد الزيادة: " + m("\(price) × \(fmt(Double(100 + p) / 100)) = \(fmt(Double(price * (100 + p)) / 100))"),
                                                    "بعد النقص: " + m("\(fmt(Double(price * (100 + p)) / 100)) × \(fmt(Double(100 - p) / 100)) = \(fmt(after))"),
                                                    "النقص حُسب من مبلغ أكبر، فالنتيجة أقل من الأصل"])
                        }
                        let q = pick([10, 20])
                        let two = Double(price) * Double(100 + p) / 100 * Double(100 + q) / 100
                        let one = Double(price) * Double(100 + p + q) / 100
                        return .compare("سعر سلعة \(price) دينار.",
                                        a: "زيادتان متتاليتان " + m("\(p)%") + " ثم " + m("\(q)%"),
                                        b: "زيادة واحدة " + m("\(p + q)%"), result: CompareResult.of(two, one),
                                        steps: ["الأولى: " + m("\(price) × \(fmt(Double(100 + p) / 100)) × \(fmt(Double(100 + q) / 100)) = \(fmt(two))"),
                                                "الثانية: " + m("\(price) × \(fmt(Double(100 + p + q) / 100)) = \(fmt(one))"),
                                                "الزيادة الثانية تُحسب على مبلغ أكبر، فالمتتاليتان أكبر"])
                    }
                }),
            Formula(
                id: "cmp_powers", topic: .comparison, title: "مقارنة القوى والجذور",
                expression: "وحّد الأساس أو الأس ثم قارن   ،   √أ + √ب > √(أ + ب)",
                explanation: "لمقارنة قوتين كبيرتين اكتبهما بأس مشترك أو أساس مشترك: مثلاً 2³⁰ = 8¹⁰ و3²⁰ = 9¹⁰، فالثانية أكبر. ومجموع جذرين أكبر دائماً من جذر المجموع (للأعداد الموجبة).",
                trap: "مقارنة الأسس فقط أو الأساسات فقط بدون توحيد.",
                gen: { d in
                    switch d {
                    case .easy:
                        let item = pick([(2, 5, 5, 2), (2, 4, 4, 2), (2, 3, 3, 2), (3, 4, 4, 3), (2, 6, 6, 2), (3, 3, 2, 4), (5, 2, 2, 5)])
                        let va = ipow(item.0, item.1), vb = ipow(item.2, item.3)
                        return .compare("", a: m("\(item.0)^\(item.1)"), b: m("\(item.2)^\(item.3)"), result: CompareResult.of(Double(va), Double(vb)),
                                        steps: ["الأولى: " + m("\(item.0)^\(item.1) = \(va)"), "الثانية: " + m("\(item.2)^\(item.3) = \(vb)")])
                    case .medium:
                        let pr = pick([(9, 16), (36, 64), (9, 40), (16, 9), (25, 144), (64, 36)])
                        let ra = Int(Double(pr.0).squareRoot()), rb = Int(Double(pr.1).squareRoot())
                        let sumRoot = Double(pr.0 + pr.1).squareRoot()
                        let isPerfect = abs(sumRoot - sumRoot.rounded()) < 0.000001
                        let rbText = abs(Double(rb * rb) - Double(pr.1)) < 0.5 ? "\(rb)" : "√\(pr.1)"
                        return .compare("", a: m("√\(pr.0) + √\(pr.1)"), b: m("√\(pr.0 + pr.1)"), result: .aGreater,
                                        steps: ["الأولى: " + m("\(ra) + \(rbText)"),
                                                "الثانية: " + m("√\(pr.0 + pr.1)" + (isPerfect ? " = \(Int(sumRoot))" : "")),
                                                "قاعدة: √أ + √ب أكبر دائماً من √(أ + ب) للأعداد الموجبة (ربّع الطرفين: الأولى تزيد بـ 2√(أب))"])
                    case .hard:
                        let items: [(String, String, CompareResult, String)] = [
                            ("2^30", "3^20", .bGreater, m("2^30 = (2^3)^10 = 8^10") + " و" + m("3^20 = (3^2)^10 = 9^10") + "، و" + m("9 > 8")),
                            ("2^40", "4^20", .equal, m("4^20 = (2^2)^20 = 2^40")),
                            ("5^20", "2^50", .bGreater, m("5^20 = 25^10") + " و" + m("2^50 = 32^10") + "، و" + m("32 > 25")),
                            ("3^40", "4^30", .aGreater, m("3^40 = 81^10") + " و" + m("4^30 = 64^10") + "، و" + m("81 > 64")),
                            ("2^100", "10^30", .aGreater, m("2^100 = 1024^10") + " و" + m("10^30 = 1000^10")),
                            ("9^15", "27^10", .equal, m("9^15 = 3^30") + " و" + m("27^10 = 3^30")),
                            ("8^12", "16^9", .equal, m("8^12 = 2^36") + " و" + m("16^9 = 2^36")),
                            ("2^50", "3^30", .aGreater, m("2^50 = (2^5)^10 = 32^10") + " و" + m("3^30 = (3^3)^10 = 27^10") + "، و" + m("32 > 27"))
                        ]
                        let item = pick(items)
                        return .compare("", a: m(item.0), b: m(item.1), result: item.2,
                                        steps: ["نوحّد الأس أو الأساس: " + item.3])
                    }
                }),
            Formula(
                id: "cmp_algebra", topic: .comparison, title: "مقارنة فيها متغيّر",
                expression: "جرّب قيماً مختلفة (موجب، سالب، صفر، كسر، 1) قبل الحكم",
                explanation: "إذا كانت المقارنة فيها متغير فجرّب أكثر من قيمة مسموحة: إذا تغيّر الحكم بتغيّر القيمة فالجواب «المعطيات غير كافية». انتبه للأعداد بين 0 و1 والسالبة والصفر.",
                trap: "تجربة قيمة واحدة فقط (غالباً عدد صحيح موجب) والحكم بناءً عليها.",
                gen: { d in
                    let easy: [CompareTemplate] = [
                        CompareTemplate(condition: m("س > 1"), a: "س²", b: "س", result: .aGreater,
                                        reason: "عند " + m("س > 1") + " التربيع يكبّر العدد، مثل " + m("2² = 4 > 2")),
                        CompareTemplate(condition: "س عدد سالب", a: "س²", b: "س", result: .aGreater,
                                        reason: m("س²") + " موجب دائماً و" + m("س") + " سالب"),
                        CompareTemplate(condition: m("س + ص = 10") + " و" + m("س − ص = 2"), a: "س", b: "6", result: .equal,
                                        reason: "بالجمع: " + m("2س = 12") + " إذن " + m("س = 6")),
                        CompareTemplate(condition: m("س = 3"), a: "س³", b: "3س²", result: .equal,
                                        reason: m("3³ = 27") + " و" + m("3 × 3² = 27")),
                        CompareTemplate(condition: m("2س + 3 = 11"), a: "س", b: "5", result: .bGreater,
                                        reason: m("2س = 8") + " إذن " + m("س = 4 < 5"))
                    ]
                    let medium: [CompareTemplate] = [
                        CompareTemplate(condition: m("0 < س < 1"), a: "س²", b: "س", result: .bGreater,
                                        reason: "تربيع الكسر يصغّره، مثل " + m("(½)² = ¼ < ½")),
                        CompareTemplate(condition: m("س > 0"), a: "(س + 1)²", b: "س² + 1", result: .aGreater,
                                        reason: m("(س + 1)² = س² + 2س + 1") + " وتزيد بـ " + m("2س") + " الموجب"),
                        CompareTemplate(condition: m("أ > ب > 0"), a: "1/أ", b: "1/ب", result: .bGreater,
                                        reason: "مقلوب العدد الأكبر أصغر، مثل " + m("1/4 < 1/2")),
                        CompareTemplate(condition: "س عدد فردي موجب", a: "(−1)^س", b: "0", result: .bGreater,
                                        reason: m("(−1)") + " مرفوعاً لأس فردي يساوي " + m("−1 < 0")),
                        CompareTemplate(condition: "س عدد زوجي موجب", a: "(−2)^س", b: "0", result: .aGreater,
                                        reason: "العدد السالب المرفوع لأس زوجي يعطي عدداً موجباً")
                    ]
                    let hard: [CompareTemplate] = [
                        CompareTemplate(condition: "س عدد صحيح موجب", a: "س²", b: "س", result: .unknown,
                                        reason: "عند " + m("س = 1") + " متساويتان، وعند " + m("س = 2") + " الأولى أكبر"),
                        CompareTemplate(condition: m("س² = 9"), a: "س", b: "3", result: .unknown,
                                        reason: "س قد تكون " + m("3") + " (متساويتان) أو " + m("−3") + " (الثانية أكبر)"),
                        CompareTemplate(condition: "س عدد حقيقي", a: "(س + 1)²", b: "س² + 1", result: .unknown,
                                        reason: "الفرق " + m("2س") + ": موجب إذا " + m("س > 0") + " وسالب إذا " + m("س < 0")),
                        CompareTemplate(condition: m("س < 0"), a: "س", b: "1/س", result: .unknown,
                                        reason: "عند " + m("س = −2") + ": " + m("−2 < −½") + "، وعند " + m("س = −½") + ": " + m("−½ > −2")),
                        CompareTemplate(condition: m("س > ص"), a: "س²", b: "ص²", result: .unknown,
                                        reason: m("3 > 2") + " تعطي " + m("9 > 4") + "، لكن " + m("−1 > −3") + " تعطي " + m("1 < 9")),
                        CompareTemplate(condition: "س عدد صحيح و" + m("3 < س < 5"), a: "س", b: "4", result: .equal,
                                        reason: "العدد الصحيح الوحيد بين 3 و5 هو 4")
                    ]
                    let t = pick(lv(d, easy, medium, hard))
                    return .compare("إذا كان " + t.condition + ":", a: m(t.a), b: m(t.b), result: t.result,
                                    steps: ["نجرّب قيماً مسموحة: " + t.reason])
                }),
            Formula(
                id: "cmp_geometry", topic: .comparison, title: "مقارنات هندسية",
                expression: "احسب كل كمية بقانونها، أو استعمل خصائص الأشكال بدون حساب",
                explanation: "في المقارنات الهندسية: احسب المساحات والمحيطات إن أمكن، واستعمل الخصائص: الضلع الأكبر يقابل الزاوية الأكبر، المربع أكبر مساحة بين المستطيلات المتساوية المحيط، ومكملة الزاوية المنفرجة حادة.",
                trap: "الاعتماد على الرسم بالعين، أو الحكم بقيمة واحدة والشكل يسمح بأكثر من حالة.",
                gen: { d in
                    switch d {
                    case .easy:
                        let l = rnd(4...12), w = rnd(2...(l - 1))
                        let s = rnd(3...10)
                        return .compare("", a: "مساحة مستطيل بعداه " + m("\(l)") + " و" + m("\(w)"), b: "مساحة مربع طول ضلعه " + m("\(s)"),
                                        result: CompareResult.of(Double(l * w), Double(s * s)),
                                        steps: ["الأولى: " + m("\(l) × \(w) = \(l * w)"), "الثانية: " + m("\(s)² = \(s * s)")])
                    case .medium:
                        let r = rnd(2...7)
                        let side = pick([r + r / 2, 2 * r - 1, r * 2, r + 1])
                        let circle = 22.0 / 7.0 * Double(r * r)
                        return .compare("خذ " + m("π ≈ 22/7") + ".", a: "مساحة دائرة نصف قطرها " + m("\(r)"), b: "مساحة مربع طول ضلعه " + m("\(side)"),
                                        result: CompareResult.of(circle, Double(side * side)),
                                        steps: ["الدائرة: " + m("22/7 × \(r)² ≈ \(fmt((circle * 100).rounded() / 100))"),
                                                "المربع: " + m("\(side)² = \(side * side)")])
                    case .hard:
                        let items: [CompareTemplate] = [
                            CompareTemplate(condition: "مستطيل محيطه 20", a: "مساحته", b: "25", result: .unknown, reason: "أكبر مساحة 25 عندما يكون مربعاً 5 × 5، وأي مستطيل آخر مساحته أقل (مثل 4 × 6 = 24)، فقد تتساويان أو تكون الثانية أكبر"),
                            CompareTemplate(condition: "في مثلث زاويتان 50° و60°", a: "الضلع المقابل للزاوية 50°", b: "الضلع المقابل للزاوية 60°", result: .bGreater, reason: "الضلع الأكبر يقابل الزاوية الأكبر"),
                            CompareTemplate(condition: "زاويتان متكاملتان إحداهما منفرجة", a: "الزاوية الأخرى", b: "90°", result: .bGreater, reason: "مكملة الزاوية المنفرجة أقل من 90°"),
                            CompareTemplate(condition: "مثلث قائم ضلعاه القائمان 6 و8", a: "الوتر", b: "10", result: .equal, reason: "√(36 + 64) = √100 = 10"),
                            CompareTemplate(condition: "مربع طول ضلعه 4", a: "محيطه", b: "مساحته", result: .equal, reason: "المحيط 16 والمساحة 16"),
                            CompareTemplate(condition: "مثلث ضلعاه 3 و7", a: "الضلع الثالث", b: "10", result: .bGreater, reason: "الضلع الثالث أقل من مجموع الضلعين (3 + 7 = 10)"),
                            CompareTemplate(condition: "مثلث ضلعاه 3 و7", a: "الضلع الثالث", b: "5", result: .unknown, reason: "الضلع الثالث بين 4 و10، فقد يكون أقل من 5 أو أكبر")
                        ]
                        let t = pick(items)
                        return .compare(t.condition + ":", a: t.a, b: t.b, result: t.result, steps: [t.reason])
                    }
                })
        ]
    }
}
