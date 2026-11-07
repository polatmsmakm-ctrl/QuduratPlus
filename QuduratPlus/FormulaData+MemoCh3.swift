import Foundation

// الفصل الثالث من المذكرة: المتباينات والفترات.

private func ivRay(_ op: String, _ t: Int) -> String {
    switch op {
    case "≥": return mcIv(mcI(t), "∞", true, false)
    case ">": return mcIv(mcI(t), "∞", false, false)
    case "≤": return mcIv("−∞", mcI(t), false, true)
    default: return mcIv("−∞", mcI(t), false, false)
    }
}

private func flipOp(_ op: String) -> String {
    switch op {
    case "≥": return "≤"
    case "≤": return "≥"
    case ">": return "<"
    default: return ">"
    }
}

private func toggleOp(_ op: String) -> String {
    switch op {
    case "≥": return ">"
    case ">": return "≥"
    case "≤": return "<"
    default: return "≤"
    }
}

private func isNonStrict(_ op: String) -> Bool { op == "≥" || op == "≤" }

private func outsideText(_ lo: Int, _ hi: Int, _ closed: Bool) -> String {
    mcIv("−∞", mcI(lo), false, closed) + " ∪ " + mcIv(mcI(hi), "∞", closed, false)
}

private func insideText(_ lo: Int, _ hi: Int, _ closed: Bool) -> String {
    mcIv(mcI(lo), mcI(hi), closed, closed)
}

/// حل (س − أ)/(س − ب) حيث أ صفر البسط وب صفر المقام.
private func ratSolution(_ a: Int, _ b: Int, outside: Bool, closedA: Bool, closedB: Bool) -> String {
    let lo = min(a, b)
    let hi = max(a, b)
    let loClosed = lo == a ? closedA : closedB
    let hiClosed = hi == a ? closedA : closedB
    if outside {
        return mcIv("−∞", mcI(lo), false, loClosed) + " ∪ " + mcIv(mcI(hi), "∞", hiClosed, false)
    }
    return mcIv(mcI(lo), mcI(hi), loClosed, hiClosed)
}

private func factorText(_ r: Int) -> String {
    r == 0 ? "س" : "(" + mcLin(1, "س", -r) + ")"
}

extension FormulaData {

    static func memoChapter3() -> [Formula] {
        return [

            // MARK: التقاطع والاتحاد
            Formula(
                id: "interval_ops", topic: .inequalities, title: "تقاطع واتحاد الفترات",
                expression: "التقاطع ∩ = العناصر المشتركة فقط   ،   الاتحاد ∪ = كل عناصر الفترتين   ،   [ ] تحوي الطرف و ( ) لا تحويه",
                symbolic: true,
                explanation: "نرسم الفترتين على خط الأعداد. التقاطع هو الجزء المشترك: يبدأ من الأكبر بين بدايتي الفترتين وينتهي عند الأصغر بين نهايتيهما، والقوس يتبع الفترة التي تحدد الطرف (وإذا اتفقتا يكون الطرف مغلقاً فقط إذا كان مغلقاً في الفترتين). الاتحاد يبدأ من الأصغر وينتهي عند الأكبر إذا كانت الفترتان متصلتين، وإلا يبقى فترتين.",
                trap: "الخلط بين القوس [ ] والقوس ( ) عند الطرف المشترك، أو كتابة فترة غير فارغة عندما تكون الفترتان منفصلتين (التقاطع فارغ φ).",
                gen: { d in
                    func rndIv() -> McInterval {
                        let lo = rnd(-4...3)
                        return McInterval(lo: lo, hi: lo + rnd(2...5), loClosed: Bool.random(), hiClosed: Bool.random())
                    }
                    let a = rndIv()
                    var b = rndIv()
                    if a.lo == b.lo && a.hi == b.hi { b.hi += 1 }
                    let doIntersect = d == .easy ? true : Bool.random()
                    let inter = a.intersect(b)
                    let interText = inter?.text ?? "φ"
                    let unionText = a.union(b)
                    let answer = doIntersect ? interText : unionText
                    let other = doIntersect ? unionText : interText
                    var cands: [String] = [other]
                    if doIntersect, let r = inter {
                        var f1 = r; f1.loClosed.toggle()
                        var f2 = r; f2.hiClosed.toggle()
                        cands += [f1.text, f2.text]
                    } else {
                        cands += [a.text, b.text]
                    }
                    var f3 = a; f3.hiClosed.toggle()
                    cands.append(f3.text)
                    cands.append(McInterval(lo: a.lo, hi: b.hi + 1, loClosed: a.loClosed, hiClosed: b.hiClosed).text)
                    let symbol = doIntersect ? "∩" : "∪"
                    let hint: String
                    if doIntersect {
                        hint = inter == nil ? "الفترتان لا تشتركان في أي عنصر، فالتقاطع فارغ φ" : "نأخذ الجزء المشترك: يبدأ من الأكبر بين البدايتين وينتهي عند الأصغر بين النهايتين"
                    } else {
                        hint = "نجمع كل عناصر الفترتين ونرسمهما على خط الأعداد"
                    }
                    return .text(
                        "أوجد: " + m(a.text + " " + symbol + " " + b.text),
                        steps: ["نرسم الفترتين على خط الأعداد",
                                hint,
                                "الناتج: " + m(answer)],
                        answer: m(answer),
                        traps: cands.map { m($0) })
                }),

            // MARK: المتباينات الخطية
            Formula(
                id: "linear_ineq", topic: .inequalities, title: "حل المتباينة الخطية وكتابة الحل كفترة",
                expression: "نحل كالمعادلة الخطية، لكن عند الضرب أو القسمة على عدد سالب تنعكس إشارة المتباينة",
                symbolic: false,
                explanation: "ننقل حدود س إلى طرف والأعداد إلى الطرف الآخر، ثم نقسم على معامل س. إذا كان المعامل سالباً ينعكس اتجاه المتباينة (≥ تصبح ≤). ثم نكتب الحل كفترة: القوس المغلق [ ] مع ≥ و ≤، والمفتوح ( ) مع > و <.",
                trap: "نسيان عكس المتباينة عند القسمة على سالب، أو استعمال قوس مغلق مع > و <.",
                gen: { d in
                    let ops = ["≥", "≤", ">", "<"]
                    var k = 0
                    var a = 0
                    var c = 0
                    var guardCount = 0
                    repeat {
                        k = rnd(1...lv(d, 3, 4, 5)) * (d == .easy ? 1 : (Bool.random() ? 1 : -1))
                        c = rnd(-3...3)
                        a = k + c
                        guardCount += 1
                    } while a == 0 && guardCount < 100
                    if a == 0 { k = 2; c = 1; a = 3 }
                    let op = pick(ops)
                    var t = rnd(-6...8)
                    while t == 0 { t = rnd(-6...8) }
                    let b = rnd(-9...9)
                    let dd = b + k * t
                    let lhs = mcLin(a, "س", b)
                    let rhs = c == 0 ? mcI(dd) : mcLin(c, "س", dd)
                    let finalOp = k > 0 ? op : flipOp(op)
                    let ans = ivRay(finalOp, t)
                    let cands: [String] = [ivRay(flipOp(finalOp), t), ivRay(toggleOp(finalOp), t),
                                           ivRay(finalOp, -t), ivRay(flipOp(finalOp), -t)]
                    return .text(
                        "مجموعة حل المتباينة " + m(lhs + " \(op) " + rhs) + " هي:",
                        steps: ["ننقل حدود س إلى طرف والأعداد إلى الآخر: " + m(mcNg("\(term(k)) \(op) \(k * t)")),
                                k > 0 ? "نقسم على " + m("\(k)") + " (موجب) فلا تنعكس المتباينة: " + m(mcNg("س \(finalOp) \(t)"))
                                      : "نقسم على " + m(mcI(k)) + " (سالب) فتنعكس المتباينة: " + m(mcNg("س \(finalOp) \(t)")),
                                "الحل كفترة: " + m(ans)],
                        answer: m(ans),
                        traps: cands.map { m($0) })
                }),

            // MARK: المتباينة المركبة
            Formula(
                id: "compound_ineq", topic: .inequalities, title: "المتباينة الخطية المحصورة بين عددين",
                expression: "م₁ < أ س + ب < م₂  ⇒  نطرح ب من الأطراف الثلاثة ثم نقسم على أ  (وإذا كان أ سالباً نعكس المتباينتين)",
                symbolic: true,
                explanation: "لإيجاد حل المتباينة المحصورة نجري العملية نفسها على الأطراف الثلاثة معاً: نطرح الثابت ثم نقسم على معامل س. إذا قسمنا على عدد سالب ينعكس الاتجاه فيتبدل ترتيب الحدّين الأيمن والأيسر.",
                trap: "نسيان قسمة أحد الأطراف الثلاثة، أو عدم تبديل ترتيب طرفي الفترة عند القسمة على سالب.",
                gen: { d in
                    let lo = rnd(-4...3)
                    let hi = lo + rnd(2...6)
                    var p = rnd(1...lv(d, 2, 3, 4))
                    if d != .easy && Bool.random() { p = -p }
                    let q = rnd(-6...6)
                    let closed = d == .hard ? Bool.random() : false
                    let m1: Int
                    let m2: Int
                    if p > 0 {
                        m1 = p * lo + q
                        m2 = p * hi + q
                    } else {
                        m1 = p * hi + q
                        m2 = p * lo + q
                    }
                    let sym = closed ? "≤" : "<"
                    let mid = mcLin(p, "س", q)
                    let ans = mcIv(mcI(lo), mcI(hi), closed, closed)
                    let cands: [String] = [mcIv(mcI(lo), mcI(hi), !closed, !closed),
                                           mcIv(mcI(m1 - q), mcI(m2 - q), closed, closed),
                                           mcIv(mcI(-hi), mcI(-lo), closed, closed),
                                           mcIv(mcI(lo - 1), mcI(hi), closed, closed),
                                           mcIv(mcI(lo), mcI(hi + 1), closed, closed)]
                    return .text(
                        "مجموعة حل المتباينة " + m(mcI(m1) + " \(sym) " + mid + " \(sym) " + mcI(m2)) + " هي:",
                        steps: ["نطرح " + m(mcI(q)) + " من الأطراف الثلاثة: " + m(mcI(m1 - q) + " \(sym) " + mcLin(p, "س", 0) + " \(sym) " + mcI(m2 - q)),
                                p > 0 ? "نقسم على " + m("\(p)") + " فتبقى الإشارات كما هي"
                                      : "نقسم على " + m(mcI(p)) + " (سالب) فتنعكس الإشارتان ونبدّل الحدّين",
                                "الحل: " + m(ans)],
                        answer: m(ans),
                        traps: cands.map { m($0) })
                }),

            // MARK: متباينة من الدرجة الثانية
            Formula(
                id: "quad_ineq", topic: .inequalities, title: "المتباينات من الدرجة الثانية",
                expression: "(س − ر)(س − ك) ≥ 0 أو > 0: الحل خارج الجذرين   ،   (س − ر)(س − ك) ≤ 0 أو < 0: الحل بين الجذرين",
                symbolic: true,
                explanation: "ننقل كل الحدود إلى طرف واحد ونحلّل الحدودية لنجد الصفرين. بما أن معامل س² موجب فالتمثيل على شكل «كأس» مفتوح للأعلى: القيم الموجبة خارج الصفرين، والسالبة بينهما. فنأخذ ما بين الصفرين إذا طُلب ≤ 0 أو < 0، وما خارجهما إذا طُلب ≥ 0 أو > 0. القوس مغلق مع ≥ و ≤.",
                trap: "الخلط بين «بين الجذرين» و«خارج الجذرين»، أو استعمال القوس المغلق مع المتباينة الصارمة.",
                gen: { d in
                    var r = rnd(-6...6)
                    var s = rnd(-6...6)
                    var guardCount = 0
                    while r == s && guardCount < 50 { r = rnd(-6...6); s = rnd(-6...6); guardCount += 1 }
                    if r == s { r = 2; s = -3 }
                    let lo = min(r, s)
                    let hi = max(r, s)
                    let op = pick(["≥", "≤", ">", "<"])
                    let closed = isNonStrict(op)
                    let outside = op == "≥" || op == ">"
                    let expr: String
                    switch d {
                    case .easy:
                        expr = factorText(r) + factorText(s) + " \(op) 0"
                    case .medium:
                        expr = mcPoly([1, -(r + s), r * s]) + " \(op) 0"
                    case .hard:
                        expr = "س² \(op) " + mcLin(r + s, "س", -r * s)
                    }
                    let ans = outside ? outsideText(lo, hi, closed) : insideText(lo, hi, closed)
                    let cands: [String] = [outside ? insideText(lo, hi, closed) : outsideText(lo, hi, closed),
                                           outside ? outsideText(lo, hi, !closed) : insideText(lo, hi, !closed),
                                           outside ? outsideText(-hi, -lo, closed) : insideText(-hi, -lo, closed),
                                           "ℝ − {" + mcI(lo) + " , " + mcI(hi) + "}"]
                    return .text(
                        "مجموعة حل المتباينة " + m(expr) + " هي:",
                        steps: ["نحلّل ونجد الصفرين: " + m(mcI(lo)) + " و " + m(mcI(hi)),
                                outside ? "المطلوب موجب، فالحل خارج الصفرين" : "المطلوب سالب، فالحل بين الصفرين",
                                "الحل: " + m(ans)],
                        answer: m(ans),
                        traps: cands.map { m($0) })
                }),

            // MARK: متباينة نسبية
            Formula(
                id: "rational_ineq", topic: .inequalities, title: "المتباينات النسبية",
                expression: "(س − أ)/(س − ب) ≥ 0  ⇒  نحلّ بجدول الإشارات، وصفر المقام لا يدخل في الحل أبداً",
                symbolic: true,
                explanation: "نجد صفر البسط وصفر المقام ونرسمهما على خط الأعداد، ثم ندرس إشارة الكسر في كل منطقة. صفر البسط يدخل في الحل (قوس مغلق) إذا كانت المتباينة ≥ أو ≤، أما صفر المقام فيُستبعد دائماً (قوس مفتوح) لأن القسمة على صفر غير معرفة.",
                trap: "إدخال صفر المقام في الحل بقوس مغلق، أو عكس المناطق الموجبة والسالبة.",
                gen: { d in
                    var a = rnd(-5...6)
                    var b = rnd(-5...6)
                    var guardCount = 0
                    while a == b && guardCount < 50 { a = rnd(-5...6); b = rnd(-5...6); guardCount += 1 }
                    if a == b { a = 1; b = 3 }
                    let op = pick(["≥", "≤", ">", "<"])
                    let closedA = isNonStrict(op)
                    let outside = op == "≥" || op == ">"
                    let frText = mcFrac(mcLin(1, "س", -a), mcLin(1, "س", -b))
                    let ans = ratSolution(a, b, outside: outside, closedA: closedA, closedB: false)
                    let cands: [String] = [ratSolution(a, b, outside: outside, closedA: closedA, closedB: true),
                                           ratSolution(a, b, outside: !outside, closedA: closedA, closedB: false),
                                           ratSolution(a, b, outside: outside, closedA: !closedA, closedB: false),
                                           ratSolution(a, b, outside: !outside, closedA: closedA, closedB: true)]
                    return .text(
                        "مجموعة حل المتباينة " + m(frText + " \(op) 0") + " هي:",
                        steps: ["صفر البسط: " + m(mcI(a)) + " ، صفر المقام: " + m(mcI(b)) + " (لا يدخل في الحل)",
                                "ندرس الإشارة: الكسر موجب خارج الصفرين وسالب بينهما",
                                "الحل: " + m(ans)],
                        answer: m(ans),
                        traps: cands.map { m($0) })
                }),

            // MARK: متباينة من الدرجة الثالثة
            Formula(
                id: "cubic_ineq", topic: .inequalities, title: "المتباينات من الدرجة الثالثة (جدول الإشارات)",
                expression: "(س − أ)(س − ب)(س − ج) ≥ 0  حيث أ < ب < ج:  الحل [أ , ب] ∪ [ج , ∞)",
                symbolic: true,
                explanation: "نجد الأصفار الثلاثة مرتبة أ < ب < ج ونرسمها على خط الأعداد. الحدودية موجبة على يمين أكبر صفر (ج, ∞)، ثم تتبدل الإشارة عند كل صفر: سالبة في (ب , ج)، موجبة في (أ , ب)، سالبة في (−∞ , أ). نختار المناطق الموافقة للمتباينة.",
                trap: "نسيان تبديل الإشارة عند كل صفر، أو البدء بإشارة خاطئة في أقصى اليمين.",
                gen: { d in
                    let lim = lv(d, 3, 4, 5)
                    var rs: [Int] = []
                    var guardCount = 0
                    while rs.count < 3 && guardCount < 200 {
                        guardCount += 1
                        let r = rnd(-lim...lim)
                        if !rs.contains(r) { rs.append(r) }
                    }
                    if rs.count < 3 { rs = [-1, 1, 3] }
                    let sorted = rs.sorted()
                    let a = sorted[0], b = sorted[1], c = sorted[2]
                    let shown = rs.shuffled()
                    let op = pick(["≥", "≤", ">", "<"])
                    let closed = isNonStrict(op)
                    let positive = op == "≥" || op == ">"
                    func region(_ pos: Bool, _ cl: Bool, _ x: Int, _ y: Int, _ z: Int) -> String {
                        if pos {
                            return mcIv(mcI(x), mcI(y), cl, cl) + " ∪ " + mcIv(mcI(z), "∞", cl, false)
                        }
                        return mcIv("−∞", mcI(x), false, cl) + " ∪ " + mcIv(mcI(y), mcI(z), cl, cl)
                    }
                    let ans = region(positive, closed, a, b, c)
                    let cands: [String] = [region(!positive, closed, a, b, c), region(positive, !closed, a, b, c),
                                           region(positive, closed, -c, -b, -a), mcIv(mcI(a), mcI(c), closed, closed)]
                    let expr = shown.map { factorText($0) }.joined() + " \(op) 0"
                    return .text(
                        "مجموعة حل المتباينة " + m(expr) + " هي:",
                        steps: ["الأصفار مرتبة: " + m(mcI(a) + " , " + mcI(b) + " , " + mcI(c)),
                                "نبدأ بالموجب على يمين أكبر صفر " + m(mcI(c)) + " ونبدّل الإشارة عند كل صفر",
                                "الحل: " + m(ans)],
                        answer: m(ans),
                        traps: cands.map { m($0) })
                }),

            // MARK: المتباينات التي فيها مقلوب
            Formula(
                id: "reciprocal_ineq", topic: .inequalities, title: "متباينات المقلوب (1/س)",
                expression: "1/س > 1/ك  (ك > 0)  ⇒  0 < س < ك   ،   1/س < 1/ك  ⇒  س < 0 أو س > ك",
                symbolic: true,
                explanation: "لا نضرب في س قبل معرفة إشارته لأنه قد يكون سالباً فتنعكس المتباينة. نفصل حالتين: س موجب (فنضرب دون عكس) وس سالب (فنضرب مع العكس). النتيجة: 1/س > 1/ك مع ك موجب تعطي 0 < س < ك، و1/س < 1/ك تعطي س سالباً أو س > ك. والمقلوب لعدد أكبر من ك الموجب يقع في (0 , 1/ك).",
                trap: "ضرب الطرفين في س مباشرة دون الانتباه لإشارته، أو نسيان أن س ≠ 0 وأن الأعداد السالبة تحقق المتباينة 1/س < 1/ك.",
                gen: { d in
                    let k = rnd(2...lv(d, 6, 8, 9))
                    switch d {
                    case .easy:
                        let ans = mcIv("0", "1/\(k)", false, false)
                        let cands: [String] = [mcIv("−∞", "1/\(k)", false, false), mcIv("1/\(k)", "∞", false, false),
                                               mcIv("0", "\(k)", false, false), mcIv("\(k)", "∞", false, false)]
                        return .text(
                            "عدد حقيقي مقلوبه يعطي عدداً أكبر من " + m("\(k)") + "، فإن العدد ينتمي إلى الفترة:",
                            steps: ["المقلوب موجب إذن العدد موجب: " + m("1/س > \(k)"),
                                    "نضرب في س (موجب) ونقسم على " + m("\(k)") + ": " + m("س < 1/\(k)"),
                                    "العدد بين الصفر و " + m("1/\(k)") + ": " + m(ans)],
                            answer: m(ans),
                            traps: cands.map { m($0) })
                    case .medium:
                        let ans = mcIv("0", "\(k)", false, false)
                        let cands: [String] = [mcIv("\(k)", "∞", false, false), mcIv("−∞", "0", false, false) + " ∪ " + mcIv("\(k)", "∞", false, false),
                                               mcIv("0", "1/\(k)", false, false), mcIv("−∞", "\(k)", false, false)]
                        return .text(
                            "مجموعة حل المتباينة " + m("1/س > 1/\(k)") + " هي:",
                            steps: ["إذا كان س سالباً فالمقلوب سالب ولا يمكن أن يكون أكبر من عدد موجب",
                                    "إذا كان س موجباً نضرب في س ثم في " + m("\(k)") + ": " + m("س < \(k)"),
                                    "الحل: " + m(ans)],
                            answer: m(ans),
                            traps: cands.map { m($0) })
                    case .hard:
                        let ans = mcIv("−∞", "0", false, false) + " ∪ " + mcIv("\(k)", "∞", false, false)
                        let cands: [String] = [mcIv("0", "\(k)", false, false), mcIv("\(k)", "∞", false, false),
                                               mcIv("−∞", "\(k)", false, false), mcIv("−∞", "0", false, false) + " ∪ " + mcIv("1/\(k)", "∞", false, false)]
                        return .text(
                            "مجموعة حل المتباينة " + m("1/س < 1/\(k)") + " هي:",
                            steps: ["إذا كان س سالباً فالمقلوب سالب وهو أصغر من " + m("1/\(k)") + ": كل الأعداد السالبة حل",
                                    "إذا كان س موجباً نضرب في س ثم في " + m("\(k)") + ": " + m("س > \(k)"),
                                    "الحل: " + m(ans)],
                            answer: m(ans),
                            traps: cands.map { m($0) })
                    }
                }),

            // MARK: مدى العبارة الخطية
            Formula(
                id: "ineq_range", topic: .inequalities, title: "تحديد فترة العبارة من فترة المتغير",
                expression: "أ < س < ب  ⇒  ك·أ + ج < ك س + ج < ك·ب + ج   (ك > 0)   ،   وإذا كان ك < 0 تنعكس المتباينة",
                symbolic: true,
                explanation: "نجري على الأطراف الثلاثة ما أُجري على المتغير: نضرب في ك ثم نضيف ج. إذا كان ك سالباً تنعكس الإشارتان، أي يصبح الطرف الأكبر هو الأول، فنكتب الفترة من الأصغر إلى الأكبر.",
                trap: "عدم عكس ترتيب الطرفين عند الضرب في سالب، أو نسيان إضافة الثابت.",
                gen: { d in
                    let a = rnd(-5...4)
                    let b = a + rnd(2...6)
                    var k = rnd(1...lv(d, 3, 4, 5))
                    if d != .easy && Bool.random() { k = -k }
                    var c = rnd(-6...6)
                    while c == 0 { c = rnd(-6...6) }
                    let closed = d == .hard ? Bool.random() : false
                    let sym = closed ? "≤" : "<"
                    let vLo = k * a + c
                    let vHi = k * b + c
                    let lowEnd = min(vLo, vHi)
                    let highEnd = max(vLo, vHi)
                    let ans = mcIv(mcI(lowEnd), mcI(highEnd), closed, closed)
                    let cands: [String] = [mcIv(mcI(vLo), mcI(vHi), closed, closed), mcIv(mcI(k * a), mcI(k * b), closed, closed),
                                           mcIv(mcI(a + c), mcI(b + c), closed, closed), mcIv(mcI(lowEnd), mcI(highEnd), !closed, !closed),
                                           mcIv(mcI(lowEnd + 1), mcI(highEnd), closed, closed)]
                    let expr = mcLin(k, "س", c)
                    return .text(
                        "إذا كان " + m(mcI(a) + " \(sym) س \(sym) " + mcI(b)) + " فإن " + m(expr) + " ينتمي إلى الفترة:",
                        steps: ["نضرب الأطراف الثلاثة في " + m(mcI(k)) + (k < 0 ? " فتنعكس الإشارتان" : ""),
                                "ثم نضيف " + m(mcI(c)) + ": الطرفان " + m(mcI(vLo)) + " و " + m(mcI(vHi)),
                                "الفترة من الأصغر إلى الأكبر: " + m(ans)],
                        answer: m(ans),
                        traps: cands.map { m($0) })
                }),

            // MARK: حالات خاصة
            Formula(
                id: "ineq_special", topic: .inequalities, title: "متباينات نسبية خاصة (مقام معاكس للبسط)",
                expression: "(س − أ)/(أ − س) = −1  (س ≠ أ)  ⇒  المتباينة إما φ أو ℝ − {أ}",
                symbolic: true,
                explanation: "عندما يكون البسط والمقام متعاكسين في الإشارة فإن الكسر يساوي −1 دائماً لكل س ≠ أ. وهذا يعني: المتباينة > 0 أو ≥ 0 لا يحققها أي عدد فمجموعة حلها φ، والمتباينة < 0 أو ≤ 0 يحققها كل عدد عدا أ فمجموعة حلها ℝ − {أ}.",
                trap: "إدخال العدد أ في الحل (المقام صفر عنده)، أو فتح جدول إشارات طويل بدون الانتباه إلى أن الكسر ثابت.",
                gen: { d in
                    let a = rnd(-6...8)
                    let op = pick([">", "≥", "<", "≤"])
                    let positive = op == ">" || op == "≥"
                    let numer = mcLin(1, "س", -a)
                    let denom = mcNg("\(a) − س")
                    let expr = mcFrac(numer, denom)
                    let options: [String] = [m("φ"), m("ℝ"), m("ℝ − {\(mcI(a))}"), m("{\(mcI(a))}")]
                    let ans = positive ? m("φ") : m("ℝ − {\(mcI(a))}")
                    var e = Example.text(
                        "مجموعة حل المتباينة " + m(expr + " \(op) 0") + " هي:",
                        steps: ["البسط والمقام متعاكسان: " + m(mcNg("(\(numer))/(\(denom)) = −1")) + "  لكل  " + m(mcNg("س ≠ \(a)")),
                                positive ? "−1 ليس أكبر من الصفر، فلا يوجد حل" : "−1 أصغر من الصفر، فكل عدد عدا " + m(mcI(a)) + " حل"],
                        answer: ans,
                        traps: [])
                    e.fixedOptions = options
                    return e
                })
        ]
    }
}
