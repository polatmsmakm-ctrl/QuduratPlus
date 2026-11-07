import Foundation

extension FormulaData {

    // MARK: - الجبر والمعادلات

    static func algebra() -> [Formula] {
        return [
            Formula(
                id: "diff_squares", topic: .algebra, title: "الفرق بين مربعين",
                expression: "أ² − ب² = (أ − ب)(أ + ب)",
                symbolic: true,
                explanation: "يختصر لك العمليات الحسابية الكبيرة: بدل تربيع عددين كبيرين، اطرح وجمع فقط ثم اضرب. ويُستعمل عكسياً: إذا عرفت (أ − ب) و(أ² − ب²) تجد (أ + ب) بالقسمة.",
                trap: "الخلط مع (أ − ب)² التي تساوي أ² − 2أب + ب². الفرق بين مربعين ليس فيه حد أوسط.",
                gen: { d in
                    if d == .hard {
                        let g = rnd(3...8)
                        let s = rnd(10...30)
                        let n = g * s
                        return .int(
                            "إذا كان " + m("أ − ب = \(g)") + " و" + m("أ² − ب² = \(n)") + "، فما قيمة " + m("أ + ب") + "؟",
                            steps: ["نحلّل: " + m("أ² − ب² = (أ − ب)(أ + ب)"),
                                    "نعوّض: " + m("\(n) = \(g) × (أ + ب)"),
                                    "نقسم: " + m("أ + ب = \(n) ÷ \(g) = \(s)")],
                            value: s, traps: [n - g, n + g, g * g])
                    }
                    let b = d == .easy ? rnd(10...30) : rnd(20...60)
                    let a = b + (d == .easy ? pick([2, 4, 10]) : pick([2, 4, 6, 10, 12]))
                    let dd = a - b
                    let s = a + b
                    return .int(
                        "احسب قيمة " + m("\(a)² − \(b)²") + " بأسرع طريقة.",
                        steps: ["نطبّق القانون: " + m("(\(a) − \(b))(\(a) + \(b))"),
                                "نضرب: " + m("\(dd) × \(s) = \(dd * s)")],
                        value: dd * s, traps: [dd * dd, s, dd * s * 2])
                }),
            Formula(
                id: "square_sum", topic: .algebra, title: "مربع المجموع والفرق",
                expression: "(أ + ب)² = أ² + 2أب + ب²   ،   (أ − ب)² = أ² − 2أب + ب²",
                symbolic: true,
                explanation: "لتربيع عدد مثل 31 اكتبه (30 + 1)، ولتربيع 49 اكتبه (50 − 1) ثم طبّق القانون. الحد الأوسط هو ضعف حاصل ضرب العددين.",
                trap: "نسيان الحد الأوسط (2أب) والقول إن (أ + ب)² = أ² + ب².",
                gen: { d in
                    let a = lv(d, pick([20, 30, 40]), pick([20, 30, 40, 50, 60, 70, 80, 90]), pick([30, 50, 60, 70, 80, 100]))
                    let b = lv(d, pick([1, 2]), rnd(1...4), rnd(1...3))
                    if d == .hard {
                        let n = a - b
                        let r = n * n
                        return .int(
                            "احسب " + m("\(n)²") + " باستخدام قانون مربع الفرق.",
                            steps: ["نكتب العدد: " + m("\(n) = \(a) − \(b)"),
                                    m("\(a)² = \(a * a)") + "  ،  " + m("2 × \(a) × \(b) = \(2 * a * b)") + "  ،  " + m("\(b)² = \(b * b)"),
                                    "نطبّق: " + m("\(a * a) − \(2 * a * b) + \(b * b) = \(r)")],
                            value: r, traps: [a * a - b * b, a * a + 2 * a * b + b * b, a * a - 2 * a * b - b * b])
                    }
                    let n = a + b
                    let r = n * n
                    return .int(
                        "احسب " + m("\(n)²") + " باستخدام قانون مربع المجموع.",
                        steps: ["نكتب العدد: " + m("\(n) = \(a) + \(b)"),
                                m("\(a)² = \(a * a)") + "  ،  " + m("2 × \(a) × \(b) = \(2 * a * b)") + "  ،  " + m("\(b)² = \(b * b)"),
                                "نجمع: " + m("\(a * a) + \(2 * a * b) + \(b * b) = \(r)")],
                        value: r, traps: [a * a + b * b, a * a + a * b + b * b, r + 10])
                }),
            Formula(
                id: "linear_eq", topic: .algebra, title: "حل المعادلة الخطية",
                expression: "أس + ب = ج  ⇒  س = (ج − ب) ÷ أ",
                symbolic: true,
                explanation: "اعزل س: انقل الثابت للطرف الآخر بعكس إشارته، ثم اقسم على معامل س. وإذا كانت س في الطرفين فاجمع حدود س في طرف والأعداد في الطرف الآخر.",
                trap: "نسيان تغيير الإشارة عند نقل الحد للطرف الآخر.",
                gen: { d in
                    if d == .hard {
                        let x = rnd(2...12)
                        let a = rnd(4...9)
                        let c = rnd(1...(a - 1))
                        let b = rnd(1...20)
                        let e = (a - c) * x + b
                        let eqText = term(a) + " + \(b) = " + term(c) + " + \(e)"
                        return .int(
                            "حلّ المعادلة: " + m(eqText),
                            steps: ["ننقل " + m(term(c)) + " لليسار و" + m("\(b)") + " لليمين: " + m("\(term(a)) − \(term(c)) = \(e) − \(b)"),
                                    "نبسّط: " + m("\(term(a - c)) = \(e - b)"),
                                    "نقسم على \(a - c): " + m("س = \(e - b) ÷ \(a - c) = \(x)")],
                            value: x, prefix: "س = ")
                        .withTraps([Double(e - b) / Double(a + c), Double(e + b) / Double(a - c), Double(x + 1)])
                    }
                    let x = d == .easy ? rnd(2...10) : rnd(3...15)
                    let a = d == .easy ? rnd(2...5) : rnd(3...9)
                    let plus = d == .easy ? true : Bool.random()
                    let b = plus ? rnd(1...20) : rnd(1...(a * x - 1))
                    let c = plus ? a * x + b : a * x - b
                    let eqText = plus ? "\(term(a)) + \(b) = \(c)" : "\(term(a)) − \(b) = \(c)"
                    let rhs = a * x
                    let step1 = plus
                        ? "نطرح \(b) من الطرفين: " + m("\(term(a)) = \(c) − \(b) = \(rhs)")
                        : "نضيف \(b) للطرفين: " + m("\(term(a)) = \(c) + \(b) = \(rhs)")
                    return .int(
                        "حلّ المعادلة: " + m(eqText),
                        steps: [step1, "نقسم على \(a): " + m("س = \(rhs) ÷ \(a) = \(x)")],
                        value: x, prefix: "س = ")
                    .withTraps([Double(plus ? c + b : c - b) / Double(a), Double(plus ? c - b : c + b), Double(c) / Double(a)])
                }),
            Formula(
                id: "exponents", topic: .algebra, title: "قوانين الأسس",
                expression: "أ^م × أ^ن = أ^(م+ن)   ،   أ^م ÷ أ^ن = أ^(م−ن)   ،   (أ^م)^ن = أ^(م×ن)",
                symbolic: true,
                explanation: "عند ضرب قوتين لهما نفس الأساس تُجمع الأسس، وعند القسمة تُطرح، وعند رفع القوة لقوة تُضرب. وأي عدد (غير الصفر) أُسّه صفر يساوي 1. ولتوحيد الأساسات اكتب 4 = 2² و8 = 2³ و9 = 3².",
                trap: "ضرب الأساسات بدل جمع الأسس، مثل القول إن 2³ × 2² = 4⁵. الأساس يبقى كما هو.",
                gen: { d in
                    if d == .hard {
                        let pair = pick([(4, 2, 2), (8, 2, 3), (9, 3, 2)])
                        let big = pair.0, small = pair.1, k = pair.2
                        let limit = small == 2 ? 10 : 6
                        var mm = 0, nn = 0
                        repeat {
                            mm = rnd(1...3)
                            nn = rnd(1...4)
                        } while k * mm + nn > limit
                        let e = k * mm + nn
                        let value = ipow(small, e)
                        return .int(
                            "احسب قيمة: " + m("\(big)^\(mm) × \(small)^\(nn)"),
                            steps: ["نوحّد الأساس: " + m("\(big) = \(small)^\(k)"),
                                    "إذن " + m("\(big)^\(mm) = \(small)^\(k * mm)"),
                                    "نجمع الأسس: " + m("\(small)^(\(k * mm)+\(nn)) = \(small)^\(e) = \(value)")],
                            value: value, traps: [ipow(small, mm + nn), ipow(big, mm + nn), ipow(small, e - 1)])
                    }
                    if d == .medium {
                        let base = pick([2, 3])
                        var a = 0, b = 0, c = 0
                        repeat {
                            a = rnd(2...5)
                            b = rnd(2...5)
                            c = rnd(1...(a + b))
                        } while a + b - c > (base == 2 ? 6 : 4)
                        let e = a + b - c
                        let value = ipow(base, e)
                        var steps = ["نجمع أسس البسط: " + m("\(base)^(\(a)+\(b)) = \(base)^\(a + b)"),
                                     "نطرح أس المقام: " + m("\(base)^(\(a + b)−\(c)) = \(base)^\(e)")]
                        steps.append(e == 0 ? "أي عدد أسّه صفر يساوي 1" : "نحسب: " + m("\(base)^\(e) = \(value)"))
                        return .int(
                            "احسب قيمة: " + m("(\(base)^\(a) × \(base)^\(b)) ÷ \(base)^\(c)"),
                            steps: steps,
                            value: value, traps: [ipow(base, e + 1), e == 0 ? 0 : base * e, ipow(base, a * b - c > 8 ? 2 : max(0, a * b - c))])
                    }
                    let kind = rnd(0...2)
                    let mm = rnd(1...3)
                    let nn = rnd(1...3)
                    let base = kind == 2 ? pick([2, 3]) : pick([2, 3, 5])
                    var expr = ""
                    var law = ""
                    var e = 0
                    var traps: [Int] = []
                    if kind == 0 {
                        e = mm + nn
                        expr = "\(base)^\(mm) × \(base)^\(nn)"
                        law = "نجمع الأسس: " + m("\(base)^(\(mm)+\(nn)) = \(base)^\(e)")
                        traps = [ipow(base, mm * nn), base * e, ipow(base, e + 1)]
                    } else if kind == 1 {
                        let big = mm + nn
                        e = mm
                        expr = "\(base)^\(big) ÷ \(base)^\(nn)"
                        law = "نطرح الأسس: " + m("\(base)^(\(big)−\(nn)) = \(base)^\(e)")
                        traps = [ipow(base, big + nn), base * e, ipow(base, e + 1)]
                    } else {
                        e = mm * nn
                        expr = "(\(base)^\(mm))^\(nn)"
                        law = "نضرب الأسس: " + m("\(base)^(\(mm)×\(nn)) = \(base)^\(e)")
                        traps = [ipow(base, mm + nn), base * e, ipow(base, e + 1)]
                    }
                    let value = ipow(base, e)
                    return .int(
                        "احسب قيمة: " + m(expr),
                        steps: [law, "نحسب القيمة: " + m("\(base)^\(e) = \(value)")],
                        value: value, traps: traps)
                }),
            Formula(
                id: "factoring", topic: .algebra, title: "التحليل إلى عوامل",
                expression: "س² + (أ+ب)س + أب = (س + أ)(س + ب)",
                symbolic: true,
                explanation: "ابحث عن عددين حاصل ضربهما الحد الثابت ومجموعهما معامل س. هذان العددان يظهران في العاملين. إذا كان الحد الثابت سالباً فالعددان مختلفان في الإشارة.",
                trap: "اختيار عددين حاصل ضربهما صحيح لكن مجموعهما أو إشارتهما خطأ. تحقق دائماً بالضرب مرة أخرى.",
                gen: { d in
                    var a = 0, b = 0
                    repeat {
                        a = rnd(2...9)
                        b = rnd(2...9)
                    } while a == b
                    switch d {
                    case .easy:
                        let expr = quad(1, a + b, a * b)
                        let result = factor(1, a) + factor(1, b)
                        return .text(
                            "حلّل المقدار: " + m(expr),
                            steps: ["نبحث عن عددين حاصل ضربهما \(a * b) ومجموعهما \(a + b): وهما \(a) و\(b)",
                                    "الناتج: " + m(result)],
                            answer: m(result),
                            traps: [m(factor(1, -a) + factor(1, -b)), m(factor(1, a) + factor(1, -b)), m(factor(1, 1) + factor(1, a * b))])
                    case .medium:
                        let expr = quad(1, a - b, -a * b)
                        let result = factor(1, a) + factor(1, -b)
                        return .text(
                            "حلّل المقدار: " + m(expr),
                            steps: ["نبحث عن عددين حاصل ضربهما " + m("−\(a * b)") + " ومجموعهما " + m(String(a - b).replacingOccurrences(of: "-", with: "−")) + ": وهما " + m("\(a)") + " و" + m("−\(b)"),
                                    "الناتج: " + m(result)],
                            answer: m(result),
                            traps: [m(factor(1, -a) + factor(1, b)), m(factor(1, a) + factor(1, b)), m(factor(1, -a) + factor(1, -b))])
                    case .hard:
                        let c = pick([2, 3])
                        let aa = rnd(1...7)
                        var bb = 0
                        repeat { bb = rnd(1...7) } while bb == aa
                        let expr = quad(c, c * bb + aa, aa * bb)
                        let result = factor(c, aa) + factor(1, bb)
                        return .text(
                            "حلّل المقدار: " + m(expr),
                            steps: ["نجرّب عاملين بالشكل " + m("(\(c)س + ؟)(س + ؟)") + " حاصل ضرب العددين فيهما \(aa * bb)",
                                    "الحد الأوسط: " + m("\(c) × \(bb) + \(aa) = \(c * bb + aa)") + " ✓",
                                    "الناتج: " + m(result)],
                            answer: m(result),
                            traps: [m(factor(c, bb) + factor(1, aa)), m(factor(c, -aa) + factor(1, -bb)), m(factor(c, aa) + factor(1, -bb))])
                    }
                }),
            Formula(
                id: "inequality", topic: .algebra, title: "المتباينات (القسمة على سالب)",
                expression: "عند الضرب أو القسمة على عدد سالب تنقلب إشارة المتباينة",
                explanation: "تُحلّ المتباينة مثل المعادلة تماماً، بشرط واحد: إذا ضربت أو قسمت الطرفين على عدد سالب فاقلب اتجاه الإشارة (> تصبح < والعكس، و≤ تصبح ≥).",
                trap: "نسيان قلب الإشارة عند القسمة على معامل س السالب. هذا أكثر خطأ شائع في المتباينات.",
                gen: { d in
                    let a = rnd(2...5)
                    let k = rnd(2...6)
                    if d == .hard {
                        let e = rnd(10...30)
                        let f = e - a * k
                        let fText = f < 0 ? "−\(-f)" : "\(f)"
                        let ineq = "\(e) − \(a)س ≤ \(fText)"
                        return .text(
                            "حلّ المتباينة: " + m(ineq),
                            steps: ["نطرح \(e) من الطرفين: " + m("−\(a)س ≤ \(fText) − \(e) = −\(a * k)"),
                                    "نقسم على " + m("−\(a)") + " وهو سالب، فتنقلب الإشارة",
                                    "الناتج: " + m("س ≥ \(k)")],
                            answer: m("س ≥ \(k)"),
                            traps: [m("س ≤ \(k)"), m("س ≥ −\(k)"), m("س ≤ −\(k)")])
                    }
                    let gt = Bool.random()
                    let sym = gt ? ">" : "<"
                    let flipped = gt ? "<" : ">"
                    let b = a * k
                    var steps: [String] = []
                    var ineq = "−\(a)س \(sym) \(b)"
                    if d == .medium {
                        let e = rnd(1...12)
                        ineq = "−\(a)س + \(e) \(sym) \(b + e)"
                        steps.append("نطرح \(e) من الطرفين: " + m("−\(a)س \(sym) \(b)"))
                    }
                    steps.append("نقسم الطرفين على " + m("−\(a)") + " وهو عدد سالب، فتنقلب إشارة المتباينة")
                    steps.append("الناتج: " + m("س \(flipped) −\(k)"))
                    return .text(
                        "حلّ المتباينة: " + m(ineq),
                        steps: steps,
                        answer: m("س \(flipped) −\(k)"),
                        traps: [m("س \(sym) −\(k)"), m("س \(flipped) \(k)"), m("س \(sym) \(k)")])
                })
        ]
    }
}
