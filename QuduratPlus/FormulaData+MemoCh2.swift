import Foundation

// الفصل الثاني من المذكرة: الحدوديات (القسمة، التحليل، فصل المتغيرات، المعادلات من الدرجة الثانية والثالثة).

extension FormulaData {

    static func memoChapter2() -> [Formula] {
        return [

            // MARK: قسمة الحدوديات
            Formula(
                id: "poly_division", topic: .algebra, title: "قسمة الحدوديات (القسمة التركيبية)",
                expression: "حدودية ÷ (س − أ): نحلّل البسط إلى (س − أ) × (حدودية أصغر)   أو نستعمل القسمة التركيبية",
                symbolic: true,
                explanation: "إذا كان المقسوم عليه (س − أ) فإن أ جذر للبسط عندما تكون القسمة تامة. نستعمل القسمة التركيبية: نكتب معاملات المقسوم، وننزل المعامل الأول، ثم نضرب في أ ونجمع مع المعامل التالي وهكذا. الأعداد الناتجة هي معاملات خارج القسمة (والأخير هو الباقي).",
                trap: "في القسمة التركيبية على (س + 3) نستعمل −3 وليس 3 (نعكس إشارة الثابت)، وعدم إكمال خارج القسمة بالدرجة الصحيحة.",
                gen: { d in
                    switch d {
                    case .easy:
                        var r = rnd(-5...5)
                        while r == 0 { r = rnd(-5...5) }
                        var k = rnd(-6...6)
                        while k == 0 { k = rnd(-6...6) }
                        let top = mcPoly([1, k - r, -r * k])
                        let bottom = mcLin(1, "س", -r)
                        let ans = mcLin(1, "س", k)
                        let cands: [String] = [mcLin(1, "س", -k), mcLin(1, "س", k + 1), mcLin(1, "س", k - 1), mcLin(1, "س", r)]
                        return .text(
                            "أوجد ناتج قسمة " + m(mcFrac(top, bottom)),
                            steps: ["نحلّل البسط: " + m("\(top) = " + mcNg(factor(1, -r)) + mcNg(factor(1, k))),
                                    "نختصر العامل المشترك " + m(mcNg(factor(1, -r))),
                                    "الناتج: " + m(ans)],
                            answer: m(ans),
                            traps: cands.map { m($0) })
                    case .medium:
                        var r = rnd(-4...4)
                        while r == 0 { r = rnd(-4...4) }
                        let p = rnd(-4...4)
                        let q = rnd(-6...6)
                        let top = mcPoly([1, p - r, q - p * r, -q * r])
                        let bottom = mcLin(1, "س", -r)
                        let ans = mcPoly([1, p, q])
                        let cands: [String] = [mcPoly([1, -p, q]), mcPoly([1, p, -q]), mcPoly([1, p + 1, q]), mcPoly([1, p, q + 1])]
                        return .text(
                            "أوجد ناتج قسمة " + m(mcFrac(top, bottom)) + "  حيث  " + m(mcNg("س ≠ \(r)")),
                            steps: ["القسمة التركيبية بالعدد " + m(mcI(r)) + " على المعاملات " + m(mcNg("1 , \(p - r) , \(q - p * r) , \(-q * r)")),
                                    "المعاملات الناتجة " + m(mcNg("1 , \(p) , \(q)")) + " والباقي صفر",
                                    "الناتج: " + m(ans)],
                            answer: m(ans),
                            traps: cands.map { m($0) })
                    case .hard:
                        var r = rnd(-3...3)
                        while r == 0 { r = rnd(-3...3) }
                        let p = rnd(-4...4)
                        let q = rnd(-5...5)
                        let top = mcPoly([2, p - 2 * r, q - p * r, -q * r])
                        let bottom = mcLin(1, "س", -r)
                        let ans = mcPoly([2, p, q])
                        let cands: [String] = [mcPoly([1, p, q]), mcPoly([2, -p, q]), mcPoly([2, p, -q]), mcPoly([2, p + 1, q])]
                        return .text(
                            "أوجد ناتج قسمة " + m(mcFrac(top, bottom)) + "  حيث  " + m(mcNg("س ≠ \(r)")),
                            steps: ["نجري القسمة التركيبية على " + m(mcI(r)),
                                    "المعاملات الناتجة " + m(mcNg("2 , \(p) , \(q)")) + " والباقي صفر",
                                    "الناتج: " + m(ans)],
                            answer: m(ans),
                            traps: cands.map { m($0) })
                    }
                }),

            // MARK: نظرية الباقي
            Formula(
                id: "remainder_thm", topic: .algebra, title: "باقي القسمة (نظرية الباقي)",
                expression: "باقي قسمة ح(س) على (س − أ) = ح(أ)",
                symbolic: true,
                explanation: "لا نحتاج إجراء القسمة كاملة: باقي قسمة الحدودية على (س − أ) يساوي قيمة الحدودية عند س = أ. وإذا كان المقسوم عليه (س + أ) نعوّض س = −أ. وإذا كان الباقي صفراً فالعامل يقسم الحدودية تماماً.",
                trap: "التعويض بأ بدل −أ عندما يكون المقسوم عليه (س + أ).",
                gen: { d in
                    var a = rnd(-3...3)
                    while a == 0 { a = rnd(-3...3) }
                    let coeffs: [Int] = lv(d,
                                           [1, rnd(-5...5), rnd(-6...6)],
                                           [rnd(1...2), rnd(-5...5), rnd(-6...6)],
                                           [rnd(1...2), rnd(-4...4), rnd(-5...5), rnd(-6...6)])
                    var value = 0
                    for c in coeffs { value = value * a + c }
                    var valueNeg = 0
                    for c in coeffs { valueNeg = valueNeg * (-a) + c }
                    let poly = mcPoly(coeffs)
                    let divisor = mcLin(1, "س", -a)
                    return .int(
                        "ما باقي قسمة " + m(poly) + " على " + m(divisor) + "؟",
                        steps: ["الباقي = قيمة الحدودية عند " + m(mcNg("س = \(a)")),
                                "نعوّض: " + m(mcNg("= \(value)"))],
                        value: value,
                        traps: [valueNeg, coeffs.last ?? 0, value + 1, -value])
                }),

            // MARK: جمع الكسور الجبرية
            Formula(
                id: "rational_add", topic: .algebra, title: "جمع وطرح الكسور الجبرية",
                expression: "أ/(س+ب) ± ج/(س+د) = [أ(س+د) ± ج(س+ب)] / [(س+ب)(س+د)]",
                symbolic: true,
                explanation: "مثل الكسور العادية تماماً: نوحّد المقامين بضرب كل كسر في مقام الآخر، ثم نجمع أو نطرح البسطين مع الانتباه لتوزيع الإشارة السالبة على كل حدود البسط الثاني. ونترك المقام على صورة حاصل ضرب عاملين.",
                trap: "عدم توزيع الإشارة السالبة على جميع حدود البسط الثاني عند الطرح (−ج(س+ب) تؤثر على الحدين).",
                gen: { d in
                    let maxCoef = lv(d, 2, 4, 5)
                    var a = rnd(1...maxCoef)
                    var b = rnd(1...maxCoef)
                    var p = rnd(-4...4)
                    var q = rnd(-4...4)
                    while q == p || p == 0 || q == 0 { p = rnd(-4...4); q = rnd(-4...4) }
                    let plus = d == .easy ? true : Bool.random()
                    if !plus && a == b { a = b + 1 }
                    if plus && a + b == 0 { b = a }
                    let c1 = plus ? a + b : a - b
                    let c0 = plus ? a * q + b * p : a * q - b * p
                    let denom = "(" + mcLin(1, "س", p) + ")(" + mcLin(1, "س", q) + ")"
                    func numText(_ c1: Int, _ c0: Int) -> String {
                        c1 == 0 ? mcI(c0) : mcLin(c1, "س", c0)
                    }
                    func build(_ n: String) -> String { m("(\(n))/" + denom) }
                    let ans = build(numText(c1, c0))
                    var cands: [String] = []
                    if plus {
                        cands = [build(numText(a + b, a * q - b * p)), build(numText(a - b, a * q + b * p)),
                                 build(numText(a + b, a * p + b * q)), build(numText(a + b, c0 + 1))]
                    } else {
                        cands = [build(numText(a + b, a * q - b * p)), build(numText(a - b, a * q + b * p)),
                                 build(numText(a - b, a * p - b * q)), build(numText(a - b, c0 + 1))]
                    }
                    let opText = plus ? "+" : "−"
                    let first = "\(a)/(" + mcLin(1, "س", p) + ")"
                    let second = "\(b)/(" + mcLin(1, "س", q) + ")"
                    return .text(
                        "بسّط: " + m(first + " \(opText) " + second),
                        steps: ["نوحّد المقامين: المقام المشترك " + m(denom),
                                "البسط: " + m("\(a)(" + mcLin(1, "س", q) + ") \(opText) \(b)(" + mcLin(1, "س", p) + ")"),
                                "بعد التوزيع والجمع: " + m(numText(c1, c0))],
                        answer: ans,
                        traps: cands)
                }),

            // MARK: التحليل بالتعويض
            Formula(
                id: "factor_sub", topic: .algebra, title: "التحليل بالتعويض ومربع المجموع",
                expression: "(ع)² − (ر+ك)ع + ر×ك = (ع − ر)(ع − ك)   ،   (س + ك + ص)(س + ك − ص) = (س + ك)² − ص²",
                symbolic: true,
                explanation: "عندما تتكرر عبارة مثل (أ + 2ب) في السؤال نعتبرها متغيراً واحداً ع ونحلّل كحدودية عادية من الدرجة الثانية: نبحث عن عددين حاصل ضربهما الحد الثابت ومجموعهما معامل ع. ثم نعيد العبارة مكان ع. وحاصل ضرب (س+ك+ص)(س+ك−ص) هو فرق مربعين (س+ك)² − ص².",
                trap: "نسيان إعادة العبارة الأصلية مكان ع، أو عكس إشارتي العددين (العددان في العاملين يعاكسان إشارتيهما في المعادلة).",
                gen: { d in
                    if d == .easy {
                        let k = rnd(1...4)
                        let mid = k == 1 ? "2س" : "\(2 * k)س"
                        let wrongMid = k == 1 ? "س" : "\(k)س"
                        let ans = "س² + \(mid) + \(k * k) − ص²"
                        let cands: [String] = ["س² + \(mid) + \(k * k) + ص²", "س² + \(k * k) − ص²",
                                               "س² + \(wrongMid) + \(k * k) − ص²", "س² + \(mid) − \(k * k) − ص²"]
                        return .text(
                            "بسّط: " + m("(س + \(k) + ص)(س + \(k) − ص)"),
                            steps: ["نكتب " + m("(س + \(k))") + " كعبارة واحدة، فيصبح فرق مربعين: " + m("(س + \(k))² − ص²"),
                                    "نفك المربع: " + m("س² + \(mid) + \(k * k) − ص²")],
                            answer: m(ans),
                            traps: cands.map { m($0) })
                    }
                    let lim = lv(d, 5, 6, 8)
                    var r = rnd(-lim...lim)
                    var s = rnd(-lim...lim)
                    var guardCount = 0
                    while (r == 0 || s == 0 || r == s || r + s == 0) && guardCount < 100 {
                        r = rnd(-lim...lim)
                        s = rnd(-lim...lim)
                        guardCount += 1
                    }
                    if r == 0 || s == 0 || r == s || r + s == 0 { r = 5; s = -2 }
                    let k = rnd(1...3)
                    let u = k == 1 ? "a + b" : "a + \(k)b"
                    let mc = -(r + s)
                    let midText = (mc < 0 ? "− " : "+ ") + (abs(mc) == 1 ? "" : "\(abs(mc))") + "(\(u))"
                    let expr = "(\(u))² \(midText) \(signed(r * s))"
                    func fac(_ x: Int, _ y: Int) -> String { "(\(u) \(signed(x)))(\(u) \(signed(y)))" }
                    let ans = fac(-r, -s)
                    let cands: [String] = [fac(r, s), fac(-r, s), fac(r, -s), "(\(u) \(signed(-r)))(\(signed(-s)))"]
                    return .text(
                        "حلّل: " + m(expr),
                        steps: ["نفرض " + m("ع = \(u)") + " فتصبح: " + m("ع² \(midText.replacingOccurrences(of: "(\(u))", with: "ع")) \(signed(r * s))"),
                                "نبحث عن عددين حاصل ضربهما " + m(mcI(r * s)) + " ومجموعهما " + m(mcI(-mc)) + ": " + m(mcI(r)) + " و " + m(mcI(s)),
                                "(ع − " + m(mcI(r)) + ")(ع − " + m(mcI(s)) + ") ثم نعيد " + m(u) + " مكان ع"],
                        answer: m(ans),
                        traps: cands.map { m($0) })
                }),

            // MARK: الجذر والقيمة المطلقة
            Formula(
                id: "sqrt_square", topic: .algebra, title: "الجذر التربيعي لمربع كامل",
                expression: "√(ع²) = |ع|   ،   √(أ²س² − 2أبس + ب²) = |أس − ب|",
                symbolic: true,
                explanation: "الجذر التربيعي لا يكون سالباً أبداً، لذلك جذر مربع أي عبارة يساوي قيمتها المطلقة وليس العبارة نفسها: √(س²) = |س|. وعندما يكون تحت الجذر مربعاً كاملاً (أس − ب)² نكتب الجذر |أس − ب|.",
                trap: "كتابة √(س²) = س بدون القيمة المطلقة (هذا صحيح فقط إذا كان س ≥ 0)، أو الخطأ في إشارة الحد داخل القوس.",
                gen: { d in
                    switch d {
                    case .easy:
                        var k = rnd(-8...8)
                        while k == 0 { k = rnd(-8...8) }
                        let inner = mcLin(1, "س", -k)
                        let ans = "|" + inner + "|"
                        let cands: [String] = [inner, "|" + mcLin(1, "س", k) + "|", mcLin(1, "س", k), "|س| " + signed(-k).replacingOccurrences(of: "+ ", with: "+ ")]
                        return .text(
                            "بسّط: " + m("√((" + inner + ")²)"),
                            steps: ["الجذر التربيعي لمربع أي عبارة يساوي قيمتها المطلقة",
                                    "الناتج: " + m(ans)],
                            answer: m(ans),
                            traps: cands.map { m(mcNg($0)) })
                    default:
                        let p = rnd(1...lv(d, 4, 4, 5))
                        let q = rnd(1...lv(d, 6, 6, 9))
                        let s = Bool.random() ? 1 : -1
                        let poly = mcPoly([p * p, -2 * p * q * s, q * q])
                        let innerText = mcLin(p, "س", -s * q)
                        let ans = "|" + innerText + "|"
                        let cands: [String] = [innerText, "|" + mcLin(p, "س", s * q) + "|",
                                               "|" + term(p) + "| " + signed(-s * q), mcLin(p, "س", s * q)]
                        return .text(
                            "بسّط: " + m("√(" + poly + ")"),
                            steps: ["نلاحظ أن ما تحت الجذر مربع كامل: " + m("(" + innerText + ")²"),
                                    "الجذر يعطي القيمة المطلقة: " + m(ans)],
                            answer: m(ans),
                            traps: cands.map { m(mcNg($0)) })
                    }
                }),

            // MARK: فصل المتغيرات
            Formula(
                id: "solve_for_var", topic: .algebra, title: "فصل المتغيرات (جعل متغير موضوع القانون)",
                expression: "نجمع الحدود التي فيها المتغير المطلوب في طرف، ونُخرجه عاملاً مشتركاً، ثم نقسم",
                symbolic: false,
                explanation: "للتعبير عن متغير بدلالة المتغيرات الأخرى: نتخلص من المقام بالضرب التبادلي، ثم ننقل كل الحدود التي فيها المتغير المطلوب إلى طرف والباقي إلى الطرف الآخر، ثم نُخرج المتغير عاملاً مشتركاً ونقسم على معامله.",
                trap: "عدم تغيير الإشارة عند نقل الحد من طرف إلى آخر، أو القسمة على جزء من المعامل فقط.",
                gen: { d in
                    switch d {
                    case .easy:
                        let k = rnd(2...9)
                        let ans = "x = " + mcFrac("\(k)y", "1 − y")
                        let cands: [String] = ["x = " + mcFrac("\(k)y", "y − 1"), "x = " + mcFrac("y", "1 − \(k)y"),
                                               "x = " + mcFrac("\(k)", "1 − y"), "x = " + mcFrac("1 − y", "\(k)y")]
                        return .text(
                            "إذا كان " + m("y = x/(x + \(k))") + " فإن " + m("x") + " تساوي:",
                            steps: ["نضرب الطرفين في المقام: " + m("y(x + \(k)) = x"),
                                    "نوزّع: " + m("xy + \(k)y = x") + "  ⇒  " + m("\(k)y = x − xy = x(1 − y)"),
                                    "نقسم على " + m("(1 − y)") + ": " + m(ans)],
                            answer: m(ans),
                            traps: cands.map { m($0) })
                    case .medium:
                        let k = rnd(2...5)
                        let kk = "\(k)"
                        let ans = "y = " + mcFrac("z − \(kk)xw", "\(kk)w + \(kk)x")
                        let cands: [String] = ["y = " + mcFrac("z − xw", "\(kk)w + \(kk)x"),
                                               "y = " + mcFrac("z − \(kk)xw", "\(kk)w − \(kk)x"),
                                               "y = " + mcFrac("z + \(kk)xw", "\(kk)w + \(kk)x"),
                                               "y = " + mcFrac("z − \(kk)xw", "\(kk)wx")]
                        return .text(
                            "إذا كان " + m("z = \(kk)xw + \(kk)yw + \(kk)yx") + " فإن " + m("y") + " تساوي:",
                            steps: ["ننقل الحد الذي لا يحوي y: " + m("z − \(kk)xw = \(kk)yw + \(kk)yx"),
                                    "نُخرج y عاملاً مشتركاً: " + m("z − \(kk)xw = y(\(kk)w + \(kk)x)"),
                                    "نقسم: " + m(ans)],
                            answer: m(ans),
                            traps: cands.map { m($0) })
                    case .hard:
                        var a = rnd(1...5)
                        var b = rnd(-5...5)
                        var c = rnd(1...4)
                        var dd = rnd(1...9)
                        var guardCount = 0
                        while (b == 0 || a * dd - b * c == 0) && guardCount < 100 {
                            a = rnd(1...5); b = rnd(-5...5); c = rnd(1...4); dd = rnd(1...9)
                            guardCount += 1
                        }
                        if b == 0 || a * dd - b * c == 0 { a = 5; b = -4; c = 2; dd = 9 }
                        let numerator = mcLin(a, "t", b)
                        let denominator = mcLin(c, "t", dd)
                        let ansNum = mcLin(dd, "s", -b)
                        let ansDen = mcNg("\(a) − " + term(c, "s"))
                        let ans = "t = " + mcFrac(ansNum, ansDen)
                        let cands: [String] = ["t = " + mcFrac(mcLin(dd, "s", b), ansDen),
                                               "t = " + mcFrac(ansNum, mcNg("\(a) + " + term(c, "s"))),
                                               "t = " + mcFrac(mcLin(a, "s", -b), mcNg("\(dd) − " + term(c, "s"))),
                                               "t = " + mcFrac(mcLin(dd, "s", b), mcNg("\(a) + " + term(c, "s")))]
                        return .text(
                            "إذا كان " + m("s = " + mcFrac(numerator, denominator)) + " فإن " + m("t") + " تساوي:",
                            steps: ["نضرب في المقام: " + m("s(\(denominator)) = \(numerator)"),
                                    "ننقل حدود t إلى طرف والباقي إلى الطرف الآخر ثم نُخرج t عاملاً مشتركاً",
                                    "بعد الترتيب والقسمة: " + m(ans)],
                            answer: m(ans),
                            traps: cands.map { m($0) })
                    }
                }),

            // MARK: المتوسط الحسابي
            Formula(
                id: "mean_change", topic: .stats, title: "المتوسط الحسابي: إضافة وحذف أعداد",
                expression: "المتوسط = المجموع ÷ العدد   ⇒   المجموع = المتوسط × العدد",
                symbolic: false,
                explanation: "في مسائل المتوسط نحوّل دائماً إلى مجاميع: مجموع الأعداد = المتوسط × عددها. عند إضافة أعداد نضيفها إلى المجموع ونقسم على العدد الجديد. وعند حذف عدد نطرح مجموع الباقي من المجموع الأصلي لنعرف العدد المحذوف.",
                trap: "جمع المتوسطات أو إيجاد متوسط المتوسطين بدلاً من العمل بالمجاميع.",
                gen: { d in
                    switch d {
                    case .easy:
                        let n = 3
                        let p = rnd(40...99)
                        let q = rnd(40...99)
                        var x = rnd(5...99)
                        while (x + p + q) % n != 0 { x += 1 }
                        let mean = (x + p + q) / n
                        return .int(
                            "المتوسط الحسابي لثلاثة أعداد هو " + m("\(mean)") + "، وعددان منها " + m("\(p)") + " و " + m("\(q)") + ". ما العدد الثالث؟",
                            steps: ["المجموع = " + m("\(mean) × 3 = \(mean * 3)"),
                                    "العدد الثالث = " + m("\(mean * 3) − \(p) − \(q) = \(x)")],
                            value: x,
                            traps: [mean, mean * 3 - p, p + q - mean, x + 3])
                    case .medium:
                        let n = pick([2, 3, 8])
                        let mean = rnd(6...30)
                        let p = rnd(3...30)
                        let q = rnd(3...30)
                        let total = n * mean + p + q
                        let v = Double(total) / Double(n + 2)
                        return .num(
                            "المتوسط الحسابي لـ \(n) أعداد هو " + m("\(mean)") + "، فعند إضافة العددين " + m("\(p)") + " و " + m("\(q)") + " يصبح المتوسط الحسابي:",
                            steps: ["المجموع الأصلي = " + m("\(mean) × \(n) = \(n * mean)"),
                                    "المجموع الجديد = " + m("\(n * mean) + \(p) + \(q) = \(total)") + " ، وعدد الأعداد " + m("\(n + 2)"),
                                    "المتوسط الجديد = " + m("\(total) ÷ \(n + 2) = \(fmt(v))")],
                            value: v,
                            traps: [Double(p + q + mean) / 3, Double(total) / Double(n), Double(mean + p + q) / Double(n + 2)])
                    case .hard:
                        let n = rnd(4...6)
                        let mean = rnd(10...40)
                        var mean2 = rnd(10...40)
                        while mean2 == mean { mean2 = rnd(10...40) }
                        let removed = n * mean - (n - 1) * mean2
                        return .int(
                            "المتوسط الحسابي لـ \(n) أعداد هو " + m("\(mean)") + ". إذا أزلنا أحد الأعداد أصبح المتوسط الحسابي للأعداد الباقية " + m("\(mean2)") + ". فما العدد الذي أزلناه؟",
                            steps: ["المجموع الأصلي = " + m("\(mean) × \(n) = \(n * mean)"),
                                    "مجموع الباقي = " + m("\(mean2) × \(n - 1) = \(mean2 * (n - 1))"),
                                    "العدد المحذوف = " + m(mcNg("\(n * mean) − \(mean2 * (n - 1)) = \(removed)"))],
                            value: removed,
                            traps: [mean - mean2, n * mean2 - (n - 1) * mean, mean2 - mean, -removed])
                    }
                }),

            // MARK: تحليل ثلاثي الحدود
            Formula(
                id: "quad_factor", topic: .algebra, title: "تحليل ثلاثي الحدود",
                expression: "س² + ب س + ج = (س + ر)(س + ك)  حيث ر×ك = ج و ر+ك = ب   ،   أس² + ب س + ج: (ن س + ر)(ل س + ك)",
                symbolic: true,
                explanation: "للحدودية س² + ب س + ج نبحث عن عددين حاصل ضربهما ج ومجموعهما ب. إذا كان ج موجباً فللعددين الإشارة نفسها (إشارة ب)، وإذا كان سالباً فإشارتاهما مختلفتان والأكبر يأخذ إشارة ب. وإذا كان معامل س² لا يساوي 1 نجرّب حاصل ضرب الطرفين والوسطين حتى يعطي الحد الأوسط.",
                trap: "أخذ إشارتين خطأ للعددين، أو التأكد من الحاصل والمجموع دون اختبار الضرب التبادلي في الحالة التي معامل س² فيها لا يساوي 1.",
                gen: { d in
                    if d == .easy {
                        var r = rnd(-9...9)
                        var s = rnd(-9...9)
                        var guardCount = 0
                        while (r == 0 || s == 0 || r == s || r + s == 0) && guardCount < 100 {
                            r = rnd(-9...9); s = rnd(-9...9); guardCount += 1
                        }
                        if r == 0 || s == 0 || r == s || r + s == 0 { r = 3; s = -5 }
                        let u = min(r, s)
                        let v = max(r, s)
                        let ans = mcNg(factor(1, u) + factor(1, v))
                        let cands: [String] = [mcNg(factor(1, -u) + factor(1, -v)), mcNg(factor(1, -u) + factor(1, v)),
                                               mcNg(factor(1, u) + factor(1, -v)), mcNg(factor(1, u + 1) + factor(1, v))]
                        return .text(
                            "حلّل: " + m(mcPoly([1, r + s, r * s])),
                            steps: ["نبحث عن عددين حاصل ضربهما " + m(mcI(r * s)) + " ومجموعهما " + m(mcI(r + s)),
                                    "العددان: " + m(mcI(u)) + " و " + m(mcI(v)),
                                    "التحليل: " + m(ans)],
                            answer: m(ans),
                            traps: cands.map { m($0) })
                    }
                    let maxP = lv(d, 2, 2, 4)
                    var p = rnd(1...maxP)
                    var r = rnd(2...(maxP + 1))
                    var q = rnd(-9...9)
                    var s = rnd(-9...9)
                    var guardCount = 0
                    while (q == 0 || s == 0 || gcd(p, abs(q)) != 1 || gcd(r, abs(s)) != 1 || (p == r && q == s)) && guardCount < 200 {
                        p = rnd(1...maxP); r = rnd(2...(maxP + 1)); q = rnd(-9...9); s = rnd(-9...9)
                        guardCount += 1
                    }
                    if q == 0 || s == 0 || gcd(p, abs(q)) != 1 || gcd(r, abs(s)) != 1 { p = 2; r = 3; q = 1; s = -4 }
                    let a = p * r
                    let b = p * s + q * r
                    let c = q * s
                    let ans = mcNg(factor(p, q) + factor(r, s))
                    let cands: [String] = [mcNg(factor(p, -q) + factor(r, -s)), mcNg(factor(p, q) + factor(r, -s)),
                                           mcNg(factor(p, -q) + factor(r, s)), mcNg(factor(p, q + 1) + factor(r, s))]
                    return .text(
                        "حلّل: " + m(mcPoly([a, b, c])),
                        steps: ["معامل " + m("س²") + " هو " + m("\(a)") + " والثابت " + m(mcI(c)) + ": نجرّب عوامل كل منهما",
                                "نختبر الضرب التبادلي حتى نحصل على الحد الأوسط " + m(mcNg(term(b))),
                                "التحليل: " + m(ans)],
                        answer: m(ans),
                        traps: cands.map { m($0) })
                }),

            // MARK: حل المعادلة التربيعية بالتحليل
            Formula(
                id: "quad_roots_set", topic: .algebra, title: "حل المعادلة التربيعية بالتحليل",
                expression: "(ن س − أ)(ل س − ب) = 0  ⇒  س = أ/ن  أو  س = ب/ل",
                symbolic: true,
                explanation: "نحلّل الحدودية إلى عاملين ثم نساوي كل عامل بالصفر لأن حاصل الضرب لا يساوي صفراً إلا إذا كان أحد العاملين صفراً. نحصل على حلّين. انتبه: الحل من العامل (ن س − أ) هو أ/ن بإشارة معاكسة لإشارة الثابت في العامل.",
                trap: "كتابة الحل بإشارة الثابت نفسها (من العامل س + 3 الحل هو −3 وليس 3)، أو قلب الكسر (ن/أ بدل أ/ن).",
                gen: { d in
                    let maxP = lv(d, 1, 3, 4)
                    var p = rnd(1...maxP)
                    var r = rnd(1...maxP)
                    var u1 = rnd(-9...9)
                    var u2 = rnd(-9...9)
                    var guardCount = 0
                    while (u1 == 0 || u2 == 0 || u1 * r == u2 * p || (p == 1 && r == 1 && u1 + u2 == 0)) && guardCount < 200 {
                        p = rnd(1...maxP); r = rnd(1...maxP); u1 = rnd(-9...9); u2 = rnd(-9...9)
                        guardCount += 1
                    }
                    if u1 == 0 || u2 == 0 || u1 * r == u2 * p { p = 1; r = 1; u1 = 3; u2 = -2 }
                    let a = p * r
                    let b = -(p * u2 + r * u1)
                    let c = u1 * u2
                    let ans = mcSetFr([(u1, p), (u2, r)])
                    let cands: [String] = [mcSetFr([(-u1, p), (-u2, r)]), mcSetFr([(u1, p), (-u2, r)]),
                                           mcSetFr([(p, u1), (r, u2)]), mcSetFr([(u1 + 1, p), (u2, r)]),
                                           mcSetFr([(u1, p), (u2 + 1, r)])]
                    let f1 = mcNg(factor(p, -u1))
                    let f2 = mcNg(factor(r, -u2))
                    return .text(
                        "مجموعة حل المعادلة " + m(mcPoly([a, b, c]) + " = 0") + " هي:",
                        steps: ["نحلّل: " + m(f1 + f2 + " = 0"),
                                "نساوي كل عامل بالصفر: " + m(mcNg("\(term(p)) = \(u1)")) + " أو " + m(mcNg("\(term(r)) = \(u2)")),
                                "الحلان: " + ans],
                        answer: ans,
                        traps: cands)
                }),

            // MARK: المميز وعدد الحلول
            Formula(
                id: "discriminant_count", topic: .algebra, title: "المميز وعدد حلول المعادلة التربيعية",
                expression: "Δ = ب² − 4أج   ،   Δ > 0: حلان   ،   Δ = 0: حل واحد (مربع كامل)   ،   Δ < 0: لا حل",
                symbolic: true,
                explanation: "نحسب المميز Δ = ب² − 4أج. إذا كان موجباً فللمعادلة حلان مختلفان (مجموعة الحل عنصران). وإذا كان صفراً فلها حل واحد مكرر (الحدودية مربع كامل). وإذا كان سالباً فلا يوجد حل حقيقي ومجموعة الحل خالية.",
                trap: "نسيان الإشارة السالبة عند حساب 4أج عندما يكون أ أو ج سالباً، أو الاعتقاد أن المعادلة التي أ فيها سالب ليس لها حل.",
                gen: { d in
                    let kind = rnd(0...2)
                    var a = rnd(1...4)
                    if Bool.random() { a = -a }
                    var b = 0
                    var c = 0
                    switch kind {
                    case 0:
                        b = rnd(-8...8)
                        c = (a > 0 ? -1 : 1) * rnd(1...9)
                    case 1:
                        var k = rnd(-4...4)
                        while k == 0 { k = rnd(-4...4) }
                        b = 2 * a * k
                        c = a * k * k
                    default:
                        b = rnd(-5...5)
                        let magnitude = (b * b) / (4 * abs(a)) + 1 + rnd(0...3)
                        c = (a > 0 ? 1 : -1) * magnitude
                    }
                    let disc = b * b - 4 * a * c
                    let answer: String
                    if disc > 0 { answer = "عنصران فقط" } else if disc == 0 { answer = "عنصر واحد فقط" } else { answer = "صفر" }
                    var e = Example.text(
                        "عدد عناصر مجموعة حل المعادلة " + m(mcPoly([a, b, c]) + " = 0") + " هو:",
                        steps: [m(mcNg("Δ = ب² − 4أج = (\(b))² − 4(\(a))(\(c)) = \(disc)")),
                                disc > 0 ? "المميز موجب: حلان مختلفان" : (disc == 0 ? "المميز صفر: حل واحد (مربع كامل)" : "المميز سالب: لا يوجد حل حقيقي")],
                        answer: answer,
                        traps: [])
                    e.fixedOptions = ["عنصران فقط", "عنصر واحد فقط", "صفر", "ليس أيا مما سبق"]
                    return e
                }),

            // MARK: مجموع وحاصل ضرب الجذرين
            Formula(
                id: "sum_roots", topic: .algebra, title: "مجموع وحاصل ضرب جذري المعادلة التربيعية",
                expression: "أس² + ب س + ج = 0  ⇒  مجموع الجذرين = −ب/أ   ،   حاصل ضربهما = ج/أ   ،   مجموع مربعيهما = (مجموعهما)² − 2×(حاصل ضربهما)",
                symbolic: true,
                explanation: "لا نحتاج حل المعادلة: مجموع الجذرين −ب/أ وحاصل ضربهما ج/أ. ولإيجاد مجموع المربعات نستعمل المتطابقة س₁² + س₂² = (س₁ + س₂)² − 2س₁س₂.",
                trap: "نسيان الإشارة السالبة في −ب/أ، أو اعتبار مجموع المربعات هو مربع المجموع.",
                gen: { d in
                    let a = rnd(1...3)
                    var r1 = rnd(-6...6)
                    var r2 = rnd(-6...6)
                    while r1 == 0 || r2 == 0 { r1 = rnd(-6...6); r2 = rnd(-6...6) }
                    let s = r1 + r2
                    let pr = r1 * r2
                    let poly = mcPoly([a, -a * s, a * pr])
                    switch d {
                    case .easy:
                        return .int(
                            "مجموع جذري المعادلة " + m(poly + " = 0") + " هو:",
                            steps: [m(mcNg("مجموع الجذرين = −ب/أ = −(\(-a * s))/\(a) = \(s)"))],
                            value: s,
                            traps: [-s, pr, -a * s, s + 1])
                    case .medium:
                        return .int(
                            "حاصل ضرب جذري المعادلة " + m(poly + " = 0") + " هو:",
                            steps: [m(mcNg("حاصل الضرب = ج/أ = \(a * pr)/\(a) = \(pr)"))],
                            value: pr,
                            traps: [-pr, s, a * pr, pr + 1])
                    case .hard:
                        let sq = s * s - 2 * pr
                        return .int(
                            "مجموع مربعي جذري المعادلة " + m(poly + " = 0") + " هو:",
                            steps: [m(mcNg("المجموع = \(s)  ،  حاصل الضرب = \(pr)")),
                                    m(mcNg("س₁² + س₂² = (\(s))² − 2(\(pr)) = \(sq)"))],
                            value: sq,
                            traps: [s * s, s * s + 2 * pr, s * s - pr, -sq])
                    }
                }),

            // MARK: متطابقات المجموع والفرق
            Formula(
                id: "square_identity", topic: .algebra, title: "المتطابقات: (س ± ص)² وحاصل الضرب",
                expression: "(س + ص)² = س² + ص² + 2س ص   ،   (س − ص)² = س² + ص² − 2س ص",
                symbolic: true,
                explanation: "كثير من أسئلة القدرات تعطي مجموع المربعات مع مجموع الأعداد أو فرقها وتطلب حاصل الضرب. نستعمل مربع المجموع أو مربع الفرق ثم نعزل الحد 2س ص.",
                trap: "قسمة الناتج على 2 قبل الأوان، أو استعمال إشارة خاطئة (الفرق يطرح 2س ص من مجموع المربعات).",
                gen: { d in
                    var x = rnd(1...9)
                    var y = rnd(1...9)
                    while x == y { y = rnd(1...9) }
                    if x < y { swap(&x, &y) }
                    let S = x * x + y * y
                    let P = x * y
                    switch d {
                    case .easy:
                        return .int(
                            "إذا كان " + m("x² + y² = \(S)") + " وكان " + m("xy = \(P)") + " فإن " + m("(x + y)²") + " تساوي:",
                            steps: [m("(x + y)² = x² + y² + 2xy = \(S) + 2(\(P)) = \(S + 2 * P)")],
                            value: S + 2 * P,
                            traps: [S - 2 * P, S + P, S * P, S + 4 * P])
                    case .medium:
                        let diff = x - y
                        return .int(
                            "إذا كان " + m("x² + y² = \(S)") + " وكان " + m("x − y = \(diff)") + " فإن " + m("xy") + " تساوي:",
                            steps: [m("(x − y)² = x² + y² − 2xy"),
                                    m("\(diff * diff) = \(S) − 2xy") + "  ⇒  " + m("2xy = \(S - diff * diff)"),
                                    m("xy = \(P)")],
                            value: P,
                            traps: [S - diff * diff, S + diff * diff, S - diff, diff * diff])
                    case .hard:
                        var xx = rnd(-6...9)
                        var yy = rnd(-6...9)
                        while xx == yy || (xx + yy) % 1 != 0 { xx = rnd(-6...9); yy = rnd(-6...9) }
                        let sum = xx + yy
                        let sq = xx * xx + yy * yy
                        let prod = xx * yy
                        return .int(
                            "إذا كان " + m(mcNg("x + y = \(sum)")) + " وكان " + m("x² + y² = \(sq)") + " فإن " + m("xy") + " تساوي:",
                            steps: [m(mcNg("(x + y)² = x² + y² + 2xy")),
                                    m(mcNg("\(sum * sum) = \(sq) + 2xy")) + "  ⇒  " + m(mcNg("2xy = \(sum * sum - sq)")),
                                    m(mcNg("xy = \(prod)"))],
                            value: prod,
                            traps: [sum * sum - sq, sum * sum + sq, -prod, (sum * sum + sq) / 2])
                    }
                }),

            // MARK: المعادلات من الدرجة الثالثة
            Formula(
                id: "cubic_roots", topic: .algebra, title: "حل معادلة من الدرجة الثالثة (الأصفار النسبية)",
                expression: "إذا كانت ح(أ) = 0 فإن (س − أ) عامل   ،   جرّب القواسم الصحيحة للحد الثابت",
                symbolic: true,
                explanation: "نجرّب القيم التي تقسم الحد الثابت (±1، ±2، ±3...) في المعادلة؛ فإذا أعطت صفراً فهي جذر. ثم نقسم قسمة تركيبية على (س − الجذر) فنحصل على معادلة تربيعية نحلّها بالتحليل. وبهذا نجد الجذور الثلاثة.",
                trap: "نسيان أحد الجذور بعد إيجاد جذر واحد، أو كتابة الجذر بإشارة معاكسة (إذا كان العامل س + 2 فالجذر −2).",
                gen: { d in
                    let lim = lv(d, 3, 5, 6)
                    var rs: [Int] = []
                    var guardCount = 0
                    while rs.count < 3 && guardCount < 200 {
                        guardCount += 1
                        let r = rnd(-lim...lim)
                        if r == 0 || rs.contains(r) { continue }
                        rs.append(r)
                    }
                    if rs.count < 3 { rs = [1, -2, 3] }
                    let e1 = rs[0] + rs[1] + rs[2]
                    let e2 = rs[0] * rs[1] + rs[0] * rs[2] + rs[1] * rs[2]
                    let e3 = rs[0] * rs[1] * rs[2]
                    let poly = mcPoly([1, -e1, e2, -e3])
                    let ans = mcSetInts(rs)
                    let cands: [String] = [mcSetInts(rs.map { -$0 }), mcSetInts([rs[0], rs[1], -rs[2]]),
                                           mcSetInts([rs[0] + 1, rs[1], rs[2]]), mcSetInts([rs[0], rs[1] - 1, rs[2]])]
                    return .text(
                        "أوجد مجموعة حل المعادلة " + m(poly + " = 0"),
                        steps: ["نجرّب قواسم الثابت " + m(mcI(-e3)) + ": العدد " + m(mcI(rs[0])) + " يعطي صفراً فهو جذر",
                                "نقسم قسمة تركيبية على " + m(mcNg(factor(1, -rs[0]))) + " ونحلّل الخارج: " + m(mcNg(factor(1, -rs[1]) + factor(1, -rs[2]))),
                                "الجذور: " + ans],
                        answer: ans,
                        traps: cands)
                })
        ]
    }
}
