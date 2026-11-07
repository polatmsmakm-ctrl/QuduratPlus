import Foundation

// الفصل الأول من المذكرة: الأعداد الحقيقية (الكسور، الأسس، الجذور، الأعداد العشرية، القسمة).

/// (الأساس، البسط، المقام، القيمة): الأساس^(البسط/المقام) = القيمة.
private let ratPow: [(base: Int, p: Int, q: Int, value: Int)] = [
    (8, 2, 3, 4), (27, 2, 3, 9), (8, 1, 3, 2), (27, 1, 3, 3), (16, 1, 4, 2), (16, 3, 4, 8),
    (81, 1, 4, 3), (4, 3, 2, 8), (9, 3, 2, 27), (25, 1, 2, 5), (4, 1, 2, 2), (9, 1, 2, 3),
    (32, 2, 5, 4), (64, 1, 3, 4), (64, 2, 3, 16), (125, 1, 3, 5), (36, 1, 2, 6)
]

private func rad(_ c: Int, _ n: Int) -> String { c == 1 ? "√\(n)" : "\(c)√\(n)" }

extension FormulaData {

    static func memoChapter1() -> [Formula] {
        return [

            // MARK: عمليات الكسور
            Formula(
                id: "frac_ops", topic: .numbers, title: "عمليات الكسور",
                expression: "أ/ب ± ج/د = (أ×د ± ج×ب)/(ب×د)   ،   أ/ب × ج/د = (أ×ج)/(ب×د)   ،   أ/ب ÷ ج/د = (أ×د)/(ب×ج)",
                symbolic: true,
                explanation: "عند الجمع والطرح نوحّد المقامات أولاً (المقام المشترك) ثم نجمع البسطين فقط. وعند الضرب نضرب البسط في البسط والمقام في المقام. وعند القسمة نقلب الكسر الثاني ونضرب. بعد ذلك نبسّط الناتج.",
                trap: "جمع البسطين والمقامين معاً (1/2 + 1/3 ≠ 2/5)، أو نسيان قلب الكسر الثاني عند القسمة.",
                gen: { d in
                    switch d {
                    case .easy:
                        let n = rnd(4...12)
                        let plus = Bool.random()
                        var a = rnd(1...(n - 1))
                        var b = rnd(1...(n - 1))
                        if !plus {
                            a = rnd(2...(n - 1))
                            b = rnd(1...(a - 1))
                        }
                        let num = plus ? a + b : a - b
                        let op = plus ? "+" : "−"
                        let answer = frac(num, n)
                        let cands: [String] = [frac(num, 2 * n), frac(num, n + 1), frac(num + 1, n),
                                               frac(a * b, n), frac(num, n - 1)]
                        return .text(
                            "أوجد ناتج: " + m("\(a)/\(n) \(op) \(b)/\(n)"),
                            steps: ["المقامان متساويان، فنجمع أو نطرح البسطين ونبقي المقام: " + m("(\(a) \(op) \(b))/\(n)"),
                                    "الناتج: " + m("\(num)/\(n)") + (answer == "\(num)/\(n)" ? "" : "  وبعد التبسيط  " + m(answer))],
                            answer: m(answer),
                            traps: cands.map { m($0) },
                            numeric: Double(num) / Double(n))
                    case .medium:
                        var b = rnd(2...9)
                        var dd = rnd(2...9)
                        while b == dd { dd = rnd(2...9) }
                        var a = rnd(1...(b - 1))
                        var c = rnd(1...(dd - 1))
                        let plus = Bool.random()
                        if !plus {
                            var guardCount = 0
                            while a * dd <= c * b && guardCount < 50 {
                                a = rnd(1...(b - 1))
                                c = rnd(1...(dd - 1))
                                guardCount += 1
                            }
                            if a * dd <= c * b {
                                b = 9; dd = 4; a = 7; c = 1
                            }
                        }
                        let num = plus ? a * dd + c * b : a * dd - c * b
                        let den = b * dd
                        let op = plus ? "+" : "−"
                        let answer = frac(num, den)
                        let cands: [String] = [plus ? frac(a + c, b + dd) : frac(a - c, b + dd),
                                               frac(num, b + dd), frac(num + 1, den), frac(num, den + b),
                                               frac(a * c, den)]
                        return .text(
                            "أوجد ناتج: " + m("\(a)/\(b) \(op) \(c)/\(dd)"),
                            steps: ["نوحّد المقامين: المقام المشترك " + m("\(b) × \(dd) = \(den)"),
                                    m("(\(a)×\(dd) \(op) \(c)×\(b))/\(den) = \(num)/\(den)"),
                                    "بعد التبسيط: " + m(answer)],
                            answer: m(answer),
                            traps: cands.map { m($0) },
                            numeric: Double(num) / Double(den))
                    case .hard:
                        var b = rnd(2...9)
                        var dd = rnd(2...9)
                        while b == dd { dd = rnd(2...9) }
                        let a = rnd(1...(b - 1))
                        let c = rnd(1...(dd - 1))
                        let times = Bool.random()
                        let num = times ? a * c : a * dd
                        let den = times ? b * dd : b * c
                        let other = times ? frac(a * dd, b * c) : frac(a * c, b * dd)
                        let answer = frac(num, den)
                        let cands: [String] = [other, frac(a + c, b + dd), frac(b * c, a * dd),
                                               frac(num, den + 1), frac(num + 1, den)]
                        let op = times ? "×" : "÷"
                        let hint = times ? "نضرب البسط في البسط والمقام في المقام" : "نقلب الكسر الثاني ونحوّل القسمة إلى ضرب"
                        return .text(
                            "أوجد ناتج: " + m("\(a)/\(b) \(op) \(c)/\(dd)"),
                            steps: [hint,
                                    m(times ? "(\(a)×\(c))/(\(b)×\(dd))" : "(\(a)×\(dd))/(\(b)×\(c))"),
                                    "الناتج بعد التبسيط: " + m(answer)],
                            answer: m(answer),
                            traps: cands.map { m($0) },
                            numeric: Double(num) / Double(den))
                    }
                }),

            // MARK: مقارنة الكسور
            Formula(
                id: "compare_fracs", topic: .numbers, title: "مقارنة الكسور",
                expression: "أ/ب > ج/د  ⇔  أ × د > ج × ب   (المقامان موجبان)",
                symbolic: true,
                explanation: "لمقارنة كسرين نضرب بالتبادل (الضرب التبادلي) أو نحوّل الكسور إلى مقام مشترك أو إلى أعداد عشرية. الكسر الأكبر هو الذي تكون قيمته العشرية أكبر.",
                trap: "الحكم من المقام وحده (القاعدة «المقام الأكبر يعني كسراً أكبر» خاطئة؛ 1/3 أكبر من 1/5).",
                gen: { d in
                    let maxDen = lv(d, 8, 12, 16)
                    var fr: [(Int, Int)] = []
                    var tries = 0
                    while fr.count < 4 && tries < 200 {
                        tries += 1
                        let den = rnd(2...maxDen)
                        let num = rnd(1...(den - 1))
                        let v = Double(num) / Double(den)
                        if fr.contains(where: { abs(Double($0.0) / Double($0.1) - v) < 0.0001 }) { continue }
                        fr.append((num, den))
                    }
                    if fr.count < 4 { fr = [(1, 2), (2, 3), (3, 4), (7, 12)] }
                    let biggest = Bool.random()
                    let target = fr.max { Double($0.0) / Double($0.1) < Double($1.0) / Double($1.1) }!
                    let smallest = fr.min { Double($0.0) / Double($0.1) < Double($1.0) / Double($1.1) }!
                    let pickFr = biggest ? target : smallest
                    let texts: [String] = fr.map { m(frac($0.0, $0.1)) }
                    let setText = m("{ " + fr.map { frac($0.0, $0.1) }.joined(separator: " , ") + " }")
                    let decimals: [String] = fr.map { (f: (Int, Int)) -> String in
                        let v = (Double(f.0) / Double(f.1) * 100).rounded() / 100
                        return frac(f.0, f.1) + " ≈ " + fmt(v)
                    }
                    var e = Example.text(
                        (biggest ? "الكسر الأكبر في المجموعة " : "الكسر الأصغر في المجموعة ") + setText + " هو:",
                        steps: ["نحوّل كل كسر إلى عدد عشري: " + m(decimals.joined(separator: " ، ")),
                                (biggest ? "أكبرها هو " : "أصغرها هو ") + m(frac(pickFr.0, pickFr.1))],
                        answer: m(frac(pickFr.0, pickFr.1)),
                        traps: [])
                    e.fixedOptions = texts
                    return e
                }),

            // MARK: كسر مركب
            Formula(
                id: "complex_frac", topic: .numbers, title: "الكسر المركب",
                expression: "(أ/ب + ج/د) ÷ (أ/ب − ج/د) = (أ×د + ج×ب)/(أ×د − ج×ب)",
                symbolic: true,
                explanation: "نبسّط البسط وحده والمقام وحده، كل منهما بتوحيد المقامات، ثم نقسم الناتجين (كسر على كسر = ضرب الأول في مقلوب الثاني). المقام المشترك يُختصر في النهاية.",
                trap: "تبسيط جزء من الكسر فقط، أو قلب الكسر الخطأ (مقلوب البسط بدل مقلوب المقام).",
                gen: { d in
                    var b = rnd(2...lv(d, 5, 7, 9))
                    var dd = rnd(2...lv(d, 5, 7, 9))
                    while b == dd { dd = rnd(2...lv(d, 5, 7, 9)) }
                    var a = rnd(1...(b - 1))
                    var c = rnd(1...(dd - 1))
                    var tries = 0
                    while a * dd <= c * b && tries < 100 {
                        a = rnd(1...(b - 1)); c = rnd(1...(dd - 1)); tries += 1
                    }
                    if a * dd <= c * b { a = 1; b = 2; c = 1; dd = 3 }
                    let top = a * dd + c * b
                    let bottom = a * dd - c * b
                    let answer = frac(top, bottom)
                    let cands: [String] = [frac(bottom, top), frac(a + c, a - c == 0 ? 1 : abs(a - c)),
                                           frac(top, bottom + 1), frac(top + 1, bottom), frac(top, b * dd)]
                    return .text(
                        "أوجد ناتج: " + m("(\(a)/\(b) + \(c)/\(dd)) ÷ (\(a)/\(b) − \(c)/\(dd))"),
                        steps: ["البسط: " + m("\(a)/\(b) + \(c)/\(dd) = \(top)/\(b * dd)"),
                                "المقام: " + m("\(a)/\(b) − \(c)/\(dd) = \(bottom)/\(b * dd)"),
                                "نقسم: " + m("(\(top)/\(b * dd)) ÷ (\(bottom)/\(b * dd)) = \(top)/\(bottom)"),
                                "بعد التبسيط: " + m(answer)],
                        answer: m(answer),
                        traps: cands.map { m($0) },
                        numeric: Double(top) / Double(bottom))
                }),

            // MARK: قوانين الأسس
            Formula(
                id: "exp_laws", topic: .numbers, title: "تبسيط الأسس (نفس الأساس)",
                expression: "أ^م × أ^ن = أ^(م+ن)   ،   أ^م ÷ أ^ن = أ^(م−ن)   ،   (أ^م)^ن = أ^(م×ن)",
                symbolic: true,
                explanation: "عند ضرب قوى لها نفس الأساس نجمع الأسس، وعند القسمة نطرحها، وعند رفع قوة لقوة نضرب الأسس. الأساس يبقى كما هو ولا يُضرب أبداً. وإذا تكرر الحد نفسه عدة مرات نحوّل الجمع إلى ضرب: 2^ت + 2^ت = 2 × 2^ت = 2^(ت+1).",
                trap: "ضرب الأساسين (2^3 × 2^4 ≠ 4^7) أو ضرب الأسس بدل جمعها عند الضرب.",
                gen: { d in
                    switch d {
                    case .easy:
                        let b = pick([2, 3, 5, 7])
                        var e1 = rnd(3...9)
                        var e2 = rnd(2...8)
                        while e1 == e2 { e2 = rnd(2...8) }
                        if Bool.random() {
                            let ans = "\(b)^\(e1 + e2)"
                            let cands: [String] = ["\(b)^\(e1 * e2)", "\(b * b)^\(e1 + e2)", "\(b)^\(e1 + e2 + 1)", "\(b)^\(abs(e1 - e2))"]
                            return .text(
                                "بسّط: " + m("\(b)^\(e1) × \(b)^\(e2)"),
                                steps: ["الأساس واحد، فنجمع الأسس: " + m("\(e1) + \(e2) = \(e1 + e2)"),
                                        "الناتج: " + m(ans)],
                                answer: m(ans),
                                traps: cands.map { m($0) })
                        } else {
                            let hi = max(e1, e2)
                            let lo = min(e1, e2)
                            let ans = "\(b)^\(hi - lo)"
                            let cands: [String] = ["\(b)^\(hi + lo)", "\(b)^\(hi * lo)", "\(b)^\(hi - lo + 1)", "\(b)^\(hi - lo - 1)"]
                            return .text(
                                "بسّط: " + m("\(b)^\(hi) ÷ \(b)^\(lo)"),
                                steps: ["الأساس واحد، فنطرح الأسس: " + m("\(hi) − \(lo) = \(hi - lo)"),
                                        "الناتج: " + m(ans)],
                                answer: m(ans),
                                traps: cands.map { m($0) })
                        }
                    case .medium:
                        let b = pick([2, 3, 5])
                        let e1 = rnd(2...4)
                        let e2 = rnd(3...4)
                        let k = rnd(1...(e1 * e2 - 1))
                        let res = e1 * e2 - k
                        let ans = "\(b)^\(res)"
                        let cands: [String] = ["\(b)^\(e1 + e2 - k)", "\(b)^\(e1 * e2 + k)", "\(b)^\(e1 * e2)", "\(b)^\(res + 1)"]
                        return .text(
                            "بسّط: " + m("(\(b)^\(e1))^\(e2) ÷ \(b)^\(k)"),
                            steps: ["رفع القوة لقوة: نضرب الأسس " + m("\(e1) × \(e2) = \(e1 * e2)"),
                                    "القسمة: نطرح الأسس " + m("\(e1 * e2) − \(k) = \(res)"),
                                    "الناتج: " + m(ans)],
                            answer: m(ans),
                            traps: cands.map { m($0) })
                    case .hard:
                        let combos: [(Int, Int)] = [(2, 1), (2, 2), (3, 1), (5, 1)]
                        let (b, j) = pick(combos)
                        let copies = ipow(b, j)
                        let terms = Array(repeating: "\(b)^ت", count: copies).joined(separator: " + ")
                        let ans = "\(b)^(ت + \(j))"
                        let cands: [String] = ["\(copies)^ت", "\(b)^(\(copies)ت)", "\(b)^(ت + \(copies))", "\(b * copies)^ت", "\(b)^ت"]
                        return .text(
                            "بسّط: " + m(terms),
                            steps: ["الحد " + m("\(b)^ت") + " مكرر \(copies) مرات، أي " + m("\(copies) × \(b)^ت"),
                                    m("\(copies) = \(b)^\(j)"),
                                    "نجمع الأسس: " + m("\(b)^\(j) × \(b)^ت = \(ans)")],
                            answer: m(ans),
                            traps: cands.map { m($0) })
                    }
                }),

            // MARK: معادلات أسية
            Formula(
                id: "exp_equation", topic: .numbers, title: "المعادلات الأسية",
                expression: "أ^س = أ^ص  ⇒  س = ص   (الأساس نفسه)   ،   (1/أ)^س = أ^(−س)",
                symbolic: true,
                explanation: "نوحّد الأساس في الطرفين ثم نساوي الأسين. إذا كان في الطرف ضرب بمعامل نقسمه أولاً لنعزل القوة، وإذا كان الأساس كسراً (1/أ) نحوّله إلى أ بأس سالب.",
                trap: "مساواة الأسين قبل توحيد الأساس، أو نسيان تغيير إشارة الأس عند قلب الكسر.",
                gen: { d in
                    switch d {
                    case .easy:
                        let b = pick([2, 3, 5, 7])
                        var x = rnd(-3...7)
                        while x == 0 { x = rnd(-3...7) }
                        let p = rnd(1...6)
                        let q = x + p
                        let lhs = "\(b)^(س + \(p))"
                        let rhs = mcNg("\(b)^(\(q))")
                        return .int(
                            "إذا كان " + m(lhs + " = " + rhs) + " فإن " + m("س") + " تساوي:",
                            steps: ["الأساسان متساويان، فنساوي الأسين: " + m("س + \(p) = \(mcI(q))"),
                                    m("س = \(mcI(q)) − \(p) = \(mcI(x))")],
                            value: x,
                            traps: [q + p, q, -x, x + 2])
                    case .medium:
                        let b = pick([2, 3])
                        let x = rnd(1...5)
                        let k = pick([3, 5, 7])
                        let n = k * ipow(b, x)
                        return .int(
                            "إذا كان " + m("\(k)(\(b)^س) = \(n)") + " فإن " + m("س") + " تساوي:",
                            steps: ["نقسم الطرفين على " + m("\(k)") + ": " + m("\(b)^س = \(n / k)"),
                                    m("\(n / k) = \(b)^\(x)") + "  ⇒  " + m("س = \(x)")],
                            value: x,
                            traps: [ipow(b, x), n / b, x + 1, x - 1])
                    case .hard:
                        let b = pick([2, 3, 5])
                        let p = rnd(1...5)
                        var s = rnd(1...5)
                        while p == s { s = rnd(1...5) }
                        var x = rnd(-3...4)
                        while x == 0 { x = rnd(-3...4) }
                        let r = rnd(0...6)
                        let q = r + (p - s) * x
                        let xx = x
                        let e1 = mcLin(p, "س", -q)
                        let e2 = r == 0 ? "−" + term(s, "س") : "\(r) − " + term(s, "س")
                        return .int(
                            "إذا كان " + m("\(b)^(\(e1)) = (1/\(b))^(\(e2))") + " فإن " + m("س") + " تساوي:",
                            steps: [m("(1/\(b))^ن = \(b)^(−ن)") + "، فالطرف الأيمن " + m("\(b)^(−(\(e2)))"),
                                    "نساوي الأسين: " + m("\(e1) = −(\(e2))"),
                                    "نحل المعادلة الخطية: " + m("س = \(xx)")],
                            value: xx,
                            traps: [-xx, xx + 1, xx - 1, q])
                    }
                }),

            // MARK: الأس الصفري والسالب
            Formula(
                id: "neg_exp", topic: .numbers, title: "الأس الصفري والسالب",
                expression: "أ⁰ = 1   ،   أ^(−ن) = 1/أ^ن   ،   (أ/ب)^(−ن) = (ب/أ)^ن   ،   1/أ^(−ن) = أ^ن",
                symbolic: true,
                explanation: "أي عدد (غير الصفر) أسه صفر يساوي 1. الأس السالب يعني مقلوب العدد: نقلب الكسر ونحوّل الأس إلى موجب. والمقلوب لقوة أسها سالب يحوّلها إلى قوة موجبة.",
                trap: "اعتبار الأس السالب يجعل الناتج سالباً (2^(−3) = 1/8 وليس −8)، أو ضرب الأساس في الأس.",
                gen: { d in
                    switch d {
                    case .easy:
                        let p = rnd(2...6)
                        let n = rnd(2...3)
                        let pn = ipow(p, n)
                        let ans = frac(1, pn)
                        let cands: [String] = [frac(1, p * n), "−\(pn)", "\(pn)", "−" + frac(1, pn)]
                        return .text(
                            "قيمة " + m("\(p)^(−\(n))") + " تساوي:",
                            steps: ["الأس السالب يعني المقلوب: " + m("\(p)^(−\(n)) = 1/\(p)^\(n)"),
                                    "الناتج: " + m(ans)],
                            answer: m(ans),
                            traps: cands.map { m(mcNg($0)) },
                            numeric: 1.0 / Double(pn))
                    case .medium:
                        var a = rnd(2...5)
                        var b = rnd(2...5)
                        while a == b { b = rnd(2...5) }
                        if gcd(a, b) != 1 { a = 2; b = 3 }
                        let n = rnd(2...3)
                        let an = ipow(a, n)
                        let bn = ipow(b, n)
                        let ans = frac(bn, an)
                        let cands: [String] = [frac(an, bn), frac(b * n, a * n), "−" + frac(an, bn), frac(bn, an + 1)]
                        return .text(
                            "قيمة " + m("(\(a)/\(b))^(−\(n))") + " تساوي:",
                            steps: ["نقلب الكسر ونحوّل الأس إلى موجب: " + m("(\(b)/\(a))^\(n)"),
                                    m("\(bn)/\(an)")],
                            answer: m(ans),
                            traps: cands.map { m(mcNg($0)) },
                            numeric: Double(bn) / Double(an))
                    case .hard:
                        let a = rnd(2...4)
                        let mm = rnd(2...4)
                        var b = rnd(2...5)
                        while b == a { b = rnd(2...5) }
                        let n = rnd(2...3)
                        let val = ipow(a, mm) - ipow(b, n)
                        return .int(
                            "احسب: " + m("\(a)^\(mm) − 1/\(b)^(−\(n))"),
                            steps: [m("1/\(b)^(−\(n)) = \(b)^\(n) = \(ipow(b, n))"),
                                    m("\(a)^\(mm) = \(ipow(a, mm))"),
                                    "الناتج: " + m(mcI(val))],
                            value: val,
                            traps: [ipow(a, mm) + ipow(b, n), ipow(a, mm) - 1, -val, ipow(a, mm) - ipow(b, n) + 1])
                    }
                }),

            // MARK: الأسس الكسرية
            Formula(
                id: "rational_exp", topic: .numbers, title: "الأسس الكسرية",
                expression: "أ^(م/ن) = (ن√أ)^م   ،   أ^(−م/ن) = 1/أ^(م/ن)",
                symbolic: true,
                explanation: "الأس الكسري يعني جذراً وقوة معاً: المقام هو دليل الجذر والبسط هو القوة. فمثلاً 8^(2/3) = (∛8)² = 2² = 4. والأس السالب يقلب الناتج.",
                trap: "الخلط بين البسط والمقام (جعل المقام هو القوة)، أو نسيان أن الأس السالب يقلب القيمة.",
                gen: { d in
                    var i = rnd(0...(ratPow.count - 1))
                    var j = rnd(0...(ratPow.count - 1))
                    var tries = 0
                    while (ratPow[i].base == ratPow[j].base || (d == .easy && ratPow[i].value % ratPow[j].value != 0)) && tries < 200 {
                        i = rnd(0...(ratPow.count - 1))
                        j = rnd(0...(ratPow.count - 1))
                        tries += 1
                    }
                    if ratPow[i].base == ratPow[j].base { i = 0; j = 4 }
                    let A = ratPow[i]
                    let B = ratPow[j]
                    let ans = frac(A.value, B.value)
                    let cands: [String] = [frac(B.value, A.value), String(A.value * B.value),
                                           String(A.value + B.value), frac(A.value, B.value + 1)]
                    return .text(
                        "قيمة " + m("\(A.base)^(\(A.p)/\(A.q)) × \(B.base)^(−\(B.p)/\(B.q))") + " تساوي:",
                        steps: [m("\(A.base)^(\(A.p)/\(A.q)) = \(A.value)"),
                                m("\(B.base)^(−\(B.p)/\(B.q)) = 1/\(B.value)"),
                                "الناتج: " + m("\(A.value) × 1/\(B.value) = \(ans)")],
                        answer: m(ans),
                        traps: cands.map { m($0) },
                        numeric: Double(A.value) / Double(B.value))
                }),

            // MARK: تبسيط الجذور
            Formula(
                id: "radical_ops", topic: .numbers, title: "الجذور: تبسيط وجمع وطرح",
                expression: "√(ك² × ن) = ك√ن   ،   ك√ن ± ل√ن = (ك ± ل)√ن   ،   √أ + √ب ≠ √(أ+ب)",
                symbolic: true,
                explanation: "نبسّط كل جذر بإخراج مربع كامل من تحته (12 = 4 × 3 فيكون √12 = 2√3). بعد التبسيط نجمع أو نطرح الجذور المتشابهة فقط (التي تحتها العدد نفسه) كما نجمع الحدود المتشابهة.",
                trap: "جمع ما تحت الجذرين (√12 + √75 ≠ √87) أو جمع جذور غير متشابهة.",
                gen: { d in
                    switch d {
                    case .easy:
                        let k = rnd(2...7)
                        let n = pick([2, 3, 5, 6, 7])
                        let inside = k * k * n
                        let ans = rad(k, n)
                        let cands: [String] = ["\(n)√\(k)", "\(k * n)", "√\(k * n)", "\(k)√\(inside)"]
                        return .text(
                            "بسّط: " + m("√\(inside)"),
                            steps: [m("\(inside) = \(k * k) × \(n)"),
                                    m("√\(inside) = √\(k * k) × √\(n) = \(ans)")],
                            answer: m(ans),
                            traps: cands.map { m($0) })
                    case .medium:
                        let n = pick([2, 3, 5, 7])
                        var k1 = rnd(1...6)
                        var k2 = rnd(1...6)
                        while k1 == k2 { k2 = rnd(1...6) }
                        let plus = Bool.random()
                        if !plus && k1 < k2 { swap(&k1, &k2) }
                        let c = plus ? k1 + k2 : k1 - k2
                        let in1 = k1 * k1 * n
                        let in2 = k2 * k2 * n
                        let op = plus ? "+" : "−"
                        let ans = rad(c, n)
                        let cands: [String] = ["√\(plus ? in1 + in2 : in1 - in2)", rad(plus ? k1 - k2 : k1 + k2, n),
                                               "\(c)√\(n * n)", rad(c + 1, n), rad(c, n + 1)]
                        return .text(
                            "بسّط: " + m("√\(in1) \(op) √\(in2)"),
                            steps: [m("√\(in1) = \(rad(k1, n))") + "  ،  " + m("√\(in2) = \(rad(k2, n))"),
                                    "الجذران متشابهان، نجمع أو نطرح المعاملين: " + m("(\(k1) \(op) \(k2))√\(n)"),
                                    "الناتج: " + m(ans)],
                            answer: m(ans),
                            traps: cands.map { m(mcNg($0)) })
                    case .hard:
                        let pairs: [(Int, Int)] = [(2, 3), (2, 5), (3, 5), (2, 7), (3, 7), (5, 7)]
                        let (a, b) = pick(pairs)
                        let ab = a * b
                        let ans = "\(a + b) − 2√\(ab)"
                        let cands: [String] = ["\(a + b) + 2√\(ab)", "\(a - b) − 2√\(ab)", "\(a + b) − √\(ab)", "\(a + b)", "\(a - b)"]
                        return .text(
                            "بسّط: " + m("(√\(a) − √\(b))²"),
                            steps: ["نستخدم مربع الفرق: " + m("(س − ص)² = س² − 2سص + ص²"),
                                    m("(√\(a))² = \(a)") + "  ،  " + m("(√\(b))² = \(b)") + "  ،  " + m("2√\(a)√\(b) = 2√\(ab)"),
                                    "الناتج: " + m(mcNg(ans))],
                            answer: m(mcNg(ans)),
                            traps: cands.map { m(mcNg($0)) })
                    }
                }),

            // MARK: إنطاق المقام
            Formula(
                id: "rationalize", topic: .numbers, title: "إنطاق المقام (التخلص من الجذر في المقام)",
                expression: "أ/√ب = أ√ب/ب   ،   1/(√أ − √ب) = (√أ + √ب)/(أ − ب)",
                symbolic: true,
                explanation: "لوضع الكسر بأبسط صورة نضرب البسط والمقام في «المرافق». إذا كان المقام √ب نضرب في √ب. وإذا كان المقام (√أ − √ب) نضرب في (√أ + √ب) لأن حاصل ضربهما أ − ب بدون جذور (فرق مربعين).",
                trap: "الضرب في العدد نفسه فقط بدون المرافق، أو الخطأ في إشارة المرافق (يجب أن تعاكس الإشارة في المقام).",
                gen: { d in
                    switch d {
                    case .easy:
                        let n = pick([2, 3, 5, 7])
                        let k = rnd(2...6)
                        let c = n * k
                        let ans = rad(k, n)
                        let cands: [String] = ["\(c)√\(n)", "\(k)√\(c)", "\(n)√\(k)", "\(c)/\(n)√\(n)"]
                        return .text(
                            "ضع في أبسط صورة: " + m("\(c)/√\(n)"),
                            steps: ["نضرب البسط والمقام في " + m("√\(n)") + ": " + m("(\(c)√\(n))/(√\(n) × √\(n)) = (\(c)√\(n))/\(n)"),
                                    "نقسم على " + m("\(n)") + ": " + m(ans)],
                            answer: m(ans),
                            traps: cands.map { m($0) })
                    case .medium:
                        let pairs: [(Int, Int)] = [(3, 2), (6, 5), (7, 6), (11, 10)]
                        let (a, b) = pick(pairs)
                        let p = rnd(2...6)
                        let ans = "\(p)√\(a) + \(p)√\(b)"
                        let cands: [String] = ["\(p)√\(a) − \(p)√\(b)", "\(p)√\(a + b)", "√\(a) + √\(b)", "\(p)√\(a) + √\(b)"]
                        return .text(
                            "ضع في أبسط صورة: " + m("\(p)/(√\(a) − √\(b))"),
                            steps: ["نضرب في المرافق " + m("(√\(a) + √\(b))") + " للبسط والمقام",
                                    "المقام: " + m("(√\(a) − √\(b))(√\(a) + √\(b)) = \(a) − \(b) = 1"),
                                    "الناتج: " + m(ans)],
                            answer: m(ans),
                            traps: cands.map { m($0) })
                    case .hard:
                        let triples: [(Int, Int, Int)] = [(5, 3, 2), (7, 5, 2), (7, 3, 4), (11, 7, 4)]
                        let (a, b, diff) = pick(triples)
                        let k = rnd(1...3)
                        let p = diff * k
                        let ans = k == 1 ? "√\(a) − √\(b)" : "\(k)√\(a) − \(k)√\(b)"
                        let cands: [String] = [k == 1 ? "√\(a) + √\(b)" : "\(k)√\(a) + \(k)√\(b)",
                                               "\(p)√\(a) − \(p)√\(b)", "√\(a - b)", "\(k)√\(a) − √\(b)"]
                        return .text(
                            "ضع في أبسط صورة: " + m("\(p)/(√\(a) + √\(b))"),
                            steps: ["نضرب في المرافق " + m("(√\(a) − √\(b))"),
                                    "المقام: " + m("\(a) − \(b) = \(diff)"),
                                    "الناتج: " + m("\(p)(√\(a) − √\(b))/\(diff) = " + ans)],
                            answer: m(ans),
                            traps: cands.map { m($0) })
                    }
                }),

            // MARK: تحويل العشري إلى كسر
            Formula(
                id: "decimal_to_fraction", topic: .numbers, title: "تحويل العدد العشري إلى كسر",
                expression: "0.ص = ص/10   ،   0.صع = صع/100   ،   0.صعغ = صعغ/1000  (ثم نبسّط)",
                symbolic: true,
                explanation: "نكتب العدد العشري بدون الفاصلة كبسط، والمقام هو 10 أو 100 أو 1000 حسب عدد الخانات بعد الفاصلة (خانة واحدة = 10، خانتان = 100، ثلاث = 1000). ثم نبسّط الكسر بالقسمة على القاسم المشترك الأكبر.",
                trap: "اختيار مقام لا يطابق عدد الخانات العشرية، أو ترك الكسر بدون تبسيط.",
                gen: { d in
                    switch d {
                    case .easy:
                        var n = rnd(11...99)
                        while n % 10 == 0 { n = rnd(11...99) }
                        let dec = fmt(Double(n) / 10)
                        let ans = frac(n, 10)
                        let cands: [String] = [frac(n, 100), "\(n)/10", frac(10, n), frac(n, 1000), frac(n + 1, 10)]
                        return .text(
                            "الكسر المكافئ للعدد " + m(dec) + " هو:",
                            steps: ["خانة عشرية واحدة، فالمقام " + m("10") + ": " + m("\(n)/10"),
                                    "بعد التبسيط: " + m(ans)],
                            answer: m(ans),
                            traps: cands.map { m($0) },
                            numeric: Double(n) / 10)
                    case .medium:
                        var n = rnd(101...399)
                        while n % 10 == 0 { n = rnd(101...399) }
                        let dec = fmt(Double(n) / 100)
                        let ans = frac(n, 100)
                        let cands: [String] = [frac(n, 10), "\(n)/100", frac(100, n), frac(n, 1000), frac(n + 1, 100)]
                        return .text(
                            "الكسر المكافئ للعدد " + m(dec) + " هو:",
                            steps: ["خانتان عشريتان، فالمقام " + m("100") + ": " + m("\(n)/100"),
                                    "بعد التبسيط: " + m(ans)],
                            answer: m(ans),
                            traps: cands.map { m($0) },
                            numeric: Double(n) / 100)
                    case .hard:
                        let whole = rnd(1...9)
                        let frs = pick([125, 375, 625, 875])
                        let n = whole * 1000 + frs
                        let dec = "\(whole).\(frs)"
                        let ans = frac(n, 1000)
                        let cands: [String] = [frac(n, 100), frac(n, 10), frac(n, 500), frac(n + 125, 1000)]
                        return .text(
                            "إذا كان " + m("س = \(dec)") + " فإن " + m("س") + " تساوي:",
                            steps: ["ثلاث خانات عشرية، فالمقام " + m("1000") + ": " + m("\(n)/1000"),
                                    "نقسم البسط والمقام على " + m("125") + ": " + m(ans)],
                            answer: m(ans),
                            traps: cands.map { m($0) },
                            numeric: Double(n) / 1000)
                    }
                }),

            // MARK: تحويل الكسر إلى عشري
            Formula(
                id: "fraction_to_decimal", topic: .numbers, title: "تحويل الكسر إلى عدد عشري",
                expression: "1/2 = 0.5   ،   1/4 = 0.25   ،   1/5 = 0.2   ،   1/10 = 0.1   ،   1/20 = 0.05   ،   1/25 = 0.04",
                symbolic: true,
                explanation: "نقسم البسط على المقام. احفظ الكسور الشائعة: نصف 0.5، ربع 0.25، خمس 0.2، عُشر 0.1، جزء من عشرين 0.05، جزء من خمس وعشرين 0.04. ثم نضرب بالبسط.",
                trap: "قسمة المقام على البسط بدل البسط على المقام، أو إزاحة الفاصلة العشرية خانة خاطئة.",
                gen: { d in
                    let q = pick(lv(d, [2, 4, 5], [2, 4, 5, 10, 20], [4, 5, 20, 25, 50]))
                    let p = rnd(1...(q * 3))
                    let v = Double(p) / Double(q)
                    return .num(
                        "اكتب الكسر " + m("\(p)/\(q)") + " على صورة عدد عشري:",
                        steps: [m("\(p) ÷ \(q) = \(fmt(v))")],
                        value: v,
                        traps: [v * 10, v / 10, Double(q) / Double(p), Double(p) / Double(q) + 0.5])
                }),

            // MARK: العمليات على الأعداد العشرية
            Formula(
                id: "decimal_ops", topic: .numbers, title: "الضرب والقسمة في الأعداد العشرية",
                expression: "نضرب كأعداد صحيحة ثم نعدّ الخانات العشرية   ،   عند القسمة نضرب البسط والمقام في 10 أو 100 لإزالة الفاصلة من المقام",
                symbolic: false,
                explanation: "في الضرب: نتجاهل الفاصلة ونضرب كالأعداد الصحيحة، ثم نضع الفاصلة بحيث يكون عدد خاناتها العشرية مساوياً لمجموع الخانات العشرية في العددين. في القسمة على عدد عشري: نضرب المقسوم والمقسوم عليه في 10 (أو 100) حتى يصبح المقسوم عليه عدداً صحيحاً.",
                trap: "وضع الفاصلة العشرية في مكان خاطئ في الناتج (خطأ بعشر أو بمئة).",
                gen: { d in
                    switch d {
                    case .easy:
                        let a10 = rnd(11...99)
                        let b = rnd(2...9)
                        let prod = a10 * b
                        let v = Double(prod) / 10
                        return .num(
                            "احسب: " + m("\(fmt(Double(a10) / 10)) × \(b)"),
                            steps: [m("\(a10) × \(b) = \(prod)"),
                                    "خانة عشرية واحدة في الناتج: " + m(fmt(v))],
                            value: v,
                            traps: [v * 10, v / 10, v + 1, v - 1])
                    case .medium:
                        let a10 = rnd(11...59)
                        let b10 = rnd(12...49)
                        let prod = a10 * b10
                        let v = Double(prod) / 100
                        return .num(
                            "احسب: " + m("\(fmt(Double(a10) / 10)) × \(fmt(Double(b10) / 10))"),
                            steps: [m("\(a10) × \(b10) = \(prod)"),
                                    "خانتان عشريتان في الناتج: " + m(fmt(v))],
                            value: v,
                            traps: [v * 10, v / 10, v * 100, Double(prod) / 1000])
                    case .hard:
                        let divs: [(Int, String)] = [(2, "0.2"), (3, "0.3"), (4, "0.4"), (5, "0.5"), (12, "1.2"), (15, "1.5"), (25, "2.5")]
                        let (d10, ds) = pick(divs)
                        let q = rnd(3...40)
                        let numer = d10 * q
                        let numerText = fmt(Double(numer) / 10)
                        return .int(
                            "احسب: " + m("\(numerText) ÷ \(ds)"),
                            steps: ["نضرب المقسوم والمقسوم عليه في 10: " + m("\(numer) ÷ \(d10)"),
                                    "الناتج: " + m("\(q)")],
                            value: q,
                            traps: [q * 10, q + 1, q - 1, q * 100])
                    }
                }),

            // MARK: قواعد القسمة
            Formula(
                id: "divisibility", topic: .numbers, title: "قواعد قابلية القسمة",
                expression: "على 2: آحاده زوجي   ،   على 3: مجموع أرقامه يقبل القسمة على 3   ،   على 4: آخر رقمين   ،   على 5: آحاده 0 أو 5   ،   على 9: مجموع أرقامه يقبل 9",
                symbolic: false,
                explanation: "العدد يقبل القسمة على 3 إذا كان مجموع أرقامه يقبل القسمة على 3، وعلى 9 إذا كان مجموع أرقامه يقبل القسمة على 9. ويقبل القسمة على 4 إذا كان العدد المكوّن من آخر رقمين يقبل القسمة على 4، وعلى 6 إذا قبل القسمة على 2 و3 معاً.",
                trap: "الاكتفاء بقاعدة 3 للحكم على 9 (كل مضاعف للتسعة هو مضاعف للثلاثة وليس العكس).",
                gen: { d in
                    let divisor = pick(lv(d, [3, 4, 5], [3, 4, 6, 9], [6, 9, 12]))
                    var correct = divisor * rnd((100 / divisor + 1)...(999 / divisor))
                    while correct > 999 { correct -= divisor }
                    var wrongs: [Int] = []
                    var tries = 0
                    while wrongs.count < 3 && tries < 500 {
                        tries += 1
                        let n = rnd(100...999)
                        if n % divisor == 0 || wrongs.contains(n) || n == correct { continue }
                        if divisor == 9 || divisor == 12 {
                            if n % 3 != 0 { continue }
                        } else if divisor == 6 {
                            if n % 2 != 0 && n % 3 != 0 { continue }
                        }
                        wrongs.append(n)
                    }
                    if wrongs.count < 3 {
                        wrongs = [correct + 1, correct + 2, correct + 3].filter { $0 % divisor != 0 }
                        while wrongs.count < 3 { wrongs.append(correct + 7 + wrongs.count) }
                    }
                    var options = ([correct] + wrongs).shuffled().map { m(String($0)) }
                    options = Array(options.prefix(4))
                    let digitSum = String(correct).compactMap { $0.wholeNumberValue }.reduce(0, +)
                    let rule: String
                    switch divisor {
                    case 3: rule = "مجموع أرقام \(correct) = \(digitSum) ويقبل القسمة على 3"
                    case 9: rule = "مجموع أرقام \(correct) = \(digitSum) ويقبل القسمة على 9"
                    case 4: rule = "آخر رقمين \(correct % 100) يقبلان القسمة على 4"
                    case 5: rule = "آحاد العدد 0 أو 5"
                    case 6: rule = "العدد زوجي ومجموع أرقامه \(digitSum) يقبل القسمة على 3"
                    default: rule = "يقبل القسمة على 3 وعلى 4 معاً (مجموع أرقامه \(digitSum)، وآخر رقمين \(correct % 100))"
                    }
                    var e = Example.text(
                        "أي الأعداد التالية يقبل القسمة على " + m("\(divisor)") + "؟",
                        steps: [rule, "الإجابة: " + m(String(correct)) + "  (والبقية فيها خلل في القاعدة)"],
                        answer: m(String(correct)),
                        traps: [])
                    e.fixedOptions = options
                    return e
                }),

            // MARK: التحليل إلى عوامل أولية
            Formula(
                id: "prime_factorization", topic: .numbers, title: "التحليل إلى عوامل أولية",
                expression: "ن = 2^أ × 3^ب × 5^ج × ...   (نقسم على الأعداد الأولية 2، 3، 5، 7 بالترتيب)",
                symbolic: true,
                explanation: "نقسم العدد على أصغر عدد أولي يقسمه ونكرر حتى نصل إلى 1. الأعداد الأولية: 2، 3، 5، 7، 11... ثم نكتب العوامل المتكررة بالأس. مثال: 180 = 2 × 2 × 3 × 3 × 5 = 2² × 3² × 5.",
                trap: "استعمال عدد غير أولي كعامل (مثل 4 أو 6)، أو الخطأ في عدّ مرات تكرار العامل.",
                gen: { d in
                    let pool = lv(d, [12, 18, 20, 24, 30, 36, 45, 60], [60, 72, 90, 120, 150, 180, 200, 210], [252, 300, 360, 420, 450, 504, 540, 600])
                    let n = pick(pool)
                    var rest = n
                    var primes: [Int] = []
                    var exps: [Int] = []
                    var f = 2
                    while rest > 1 && f <= n {
                        var e = 0
                        while rest % f == 0 { rest /= f; e += 1 }
                        if e > 0 { primes.append(f); exps.append(e) }
                        f += 1
                    }
                    func build(_ es: [Int]) -> String {
                        var parts: [String] = []
                        for (i, p) in primes.enumerated() where es[i] > 0 {
                            parts.append(es[i] == 1 ? "\(p)" : "\(p)^\(es[i])")
                        }
                        return parts.joined(separator: " × ")
                    }
                    let ans = build(exps)
                    var cands: [String] = []
                    for i in primes.indices {
                        var up = exps
                        up[i] += 1
                        cands.append(build(up))
                        if exps[i] > 1 {
                            var down = exps
                            down[i] -= 1
                            cands.append(build(down))
                        } else if primes.count > 2 {
                            var drop = exps
                            drop[i] = 0
                            cands.append(build(drop))
                        }
                    }
                    return .text(
                        "حلّل العدد " + m("\(n)") + " إلى عوامله الأولية:",
                        steps: ["نقسم على الأعداد الأولية بالترتيب حتى نصل إلى 1",
                                "الناتج: " + m(ans)],
                        answer: m(ans),
                        traps: cands.map { m($0) })
                })
        ]
    }
}
