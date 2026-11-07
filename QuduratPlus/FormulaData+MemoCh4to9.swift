import Foundation

// الفصول 4 إلى 9 من المذكرة (الأجزاء المتممة): القيمة المطلقة، الدوال ومجالها، النسبة والأوزان، المنطق.

/// حقيقة بسيطة وعكسها (للنفي).
private let factBank: [(String, String)] = [
    ("العدد 3 فردي", "العدد 3 ليس فردياً"),
    ("مصر تقع في آسيا", "مصر لا تقع في آسيا"),
    ("الكويت دولة عربية", "الكويت ليست دولة عربية"),
    ("أحمد كويتي", "أحمد ليس كويتياً"),
    ("الموز من الفواكه", "الموز ليس من الفواكه"),
    ("العدد 12 يقبل القسمة على 4", "العدد 12 لا يقبل القسمة على 4"),
    ("القاهرة عاصمة مصر", "القاهرة ليست عاصمة مصر"),
    ("الحوت من الأسماك", "الحوت ليس من الأسماك"),
    ("العدد 7 أولي", "العدد 7 ليس أولياً"),
    ("المثلث له ثلاثة أضلاع", "المثلث ليس له ثلاثة أضلاع"),
    ("سالم طالب", "سالم ليس طالباً"),
    ("الشاي ساخن", "الشاي ليس ساخناً")
]

/// (المجموعة، المحمول، نفيه) لنفي «جميع» و«يوجد».
private let quantBank: [(String, String, String)] = [
    ("طلاب الصف الثاني عشر العلمي", "يحبون الرياضيات", "لا يحبون الرياضيات"),
    ("المعلمين", "يستخدمون الحاسوب", "لا يستخدمون الحاسوب"),
    ("سكان المدينة", "يملكون سيارات", "لا يملكون سيارات"),
    ("الأعداد الأولية", "أعداد فردية", "ليست أعداداً فردية"),
    ("الطيور", "تستطيع الطيران", "لا تستطيع الطيران"),
    ("اللاعبين في الفريق", "يجيدون السباحة", "لا يجيدون السباحة")
]

private let deductiveBank: [String] = [
    "كل معلم رياضيات أصلع ، براك معلم رياضيات ، إذن براك أصلع",
    "جميع الحلويات تحوي سكراً ، الكنافة من الحلويات ، إذن الكنافة تحوي سكراً",
    "كل ما يكون في السماء غيوم تمطر ، السماء اليوم بها غيوم ، إذن اليوم ستمطر",
    "الأعداد الزوجية تقبل القسمة على 2 ، العدد 328 زوجي ، إذن العدد 328 يقبل القسمة على 2",
    "القطط لها قدرة قوية على الشم ، مرعوب قط ، إذن مرعوب لديه قدرة قوية على الشم",
    "جميع الطيور لها أجنحة ، الصقر طائر ، إذن للصقر أجنحة"
]

private let inductiveBank: [String] = [
    "أحمد وعلي ونورة مهندسون ، وهم أبناء الدكتور ، إذن كل أبناء الدكتور مهندسون",
    "سارة ومنيرة وهاجر يدرسن من علا ، وهن جميع بنات أحمد ، إذن جميع بنات أحمد يدرسن من علا",
    "الغراب الأول أسود والثاني أسود والثالث أسود ، إذن كل الغربان سوداء",
    "ثلاثة طلاب من الصف نجحوا في الاختبار ، إذن جميع طلاب الصف نجحوا",
    "جميع الأعداد الأولية التي جرّبناها ( 3 و 5 و 7 ) فردية ، إذن كل الأعداد الأولية فردية",
    "الكويت والسعودية وقطر دول خليجية تحوي نفطاً ، إذن كل الدول الخليجية تحوي نفطاً"
]

/// (المقدمات، النتيجة الصحيحة، نتائج خاطئة).
private let deductionBank: [(String, String, [String])] = [
    ("الأعداد الزوجية تقبل القسمة على 2 ، والعدد 328 زوجي ، إذن:", "العدد 328 يقبل القسمة على 2",
     ["العدد 328 لا يقبل القسمة على 2", "العدد 328 فردي", "كل الأعداد تقبل القسمة على 2"]),
    ("جميع الحلويات تحوي سكراً ، والكنافة من الحلويات ، إذن:", "الكنافة تحوي سكراً",
     ["الكنافة لا تحوي سكراً", "كل ما يحوي سكراً حلوى", "بعض الحلويات لا تحوي سكراً"]),
    ("كل ما يكون في السماء غيوم تمطر ، والسماء اليوم بها غيوم ، إذن:", "اليوم ستمطر",
     ["اليوم لن تمطر", "السماء دائماً بها غيوم", "كل الأيام ممطرة"]),
    ("القطط لها قدرة قوية على الشم ، ومرعوب قط ، إذن:", "مرعوب لديه قدرة قوية على الشم",
     ["مرعوب ليس لديه قدرة على الشم", "كل من له قدرة قوية على الشم قط", "بعض القطط لا تشم"]),
    ("جميع الطيور لها أجنحة ، والصقر طائر ، إذن:", "للصقر أجنحة",
     ["ليس للصقر أجنحة", "كل ما له أجنحة طائر", "الصقر لا يطير"])
]

extension FormulaData {

    static func memoChapters4to9() -> [Formula] {
        return [

            // MARK: قيمة مطلقة: تقييم
            Formula(
                id: "abs_value_eval", topic: .functions, title: "تبسيط القيمة المطلقة",
                expression: "|س| = س  إذا س ≥ 0  ،  |س| = −س  إذا س < 0   ،   |√أ − √ب| = √ب − √أ  إذا أ < ب",
                symbolic: true,
                explanation: "القيمة المطلقة تحوّل الناتج إلى موجب. لحساب |عبارة| نحدد أولاً إشارة ما بداخلها: إذا كانت موجبة تبقى كما هي، وإذا كانت سالبة نغيّر إشارتها. مثال: |√13 − √15| سالب في الداخل (لأن 13 < 15) فيصبح √15 − √13.",
                trap: "كتابة |س − ص| = س − ص دون النظر هل س أكبر من ص، أو ترك الإشارة السالبة.",
                gen: { d in
                    switch d {
                    case .easy:
                        var a = rnd(-6...6)
                        var b = rnd(-6...6)
                        var k = rnd(-3...3)
                        var guardCount = 0
                        while (a == 0 || b == 0 || abs(a) == abs(b) || k == 0) && guardCount < 100 {
                            a = rnd(-6...6); b = rnd(-6...6); k = rnd(-3...3); guardCount += 1
                        }
                        if a == 0 || b == 0 || abs(a) == abs(b) || k == 0 { a = -2; b = 3; k = -2 }
                        let v = k * (abs(a) - abs(b))
                        return .int(
                            "احسب: " + m(mcNg("\(k)(|\(a)| − |\(b)|)")),
                            steps: [m("|\(mcI(a))| = \(abs(a))") + " ،  " + m("|\(mcI(b))| = \(abs(b))"),
                                    m(mcNg("\(k)(\(abs(a)) − \(abs(b))) = \(v)"))],
                            value: v,
                            traps: [-v, k * (a - b), k * (abs(a) + abs(b)), v + k])
                    case .medium:
                        let pool = [2, 3, 5, 6, 7, 10, 11, 13, 15]
                        var i = rnd(0...(pool.count - 2))
                        let j = rnd((i + 1)...(pool.count - 1))
                        if i >= j { i = 0 }
                        let mm = pool[i]
                        let nn = pool[j]
                        let ans = "√\(nn) − √\(mm)"
                        let cands: [String] = ["√\(mm) − √\(nn)", "√\(nn) + √\(mm)", "√\(nn - mm)", "−√\(nn) − √\(mm)"]
                        return .text(
                            "بسّط: " + m("|√\(mm) − √\(nn)|"),
                            steps: [m("\(mm) < \(nn)") + " إذن " + m("√\(mm) < √\(nn)") + " والفرق " + m("√\(mm) − √\(nn)") + " سالب",
                                    "القيمة المطلقة تعكس الإشارة: " + m(ans)],
                            answer: m(ans),
                            traps: cands.map { m(mcNg($0)) })
                    case .hard:
                        let a = rnd(-3...3)
                        let b = a + 1
                        let ans = mcLin(2, "س", -(a + b))
                        let cands: [String] = [mcLin(2, "س", a + b), mcLin(-2, "س", a + b), "1", "−1"]
                        return .text(
                            "إذا كان " + m(mcNg("\(a) < س < \(b)")) + " فإن " + m("|" + mcLin(1, "س", -a) + "| − |" + mcLin(1, "س", -b) + "|") + " تساوي:",
                            steps: [m(mcLin(1, "س", -a) + " > 0") + " فتبقى كما هي: " + m(mcLin(1, "س", -a)),
                                    m(mcLin(1, "س", -b) + " < 0") + " فتنعكس إشارتها: " + m("−(" + mcLin(1, "س", -b) + ")"),
                                    "نطرح: " + m("(" + mcLin(1, "س", -a) + ") − (−(" + mcLin(1, "س", -b) + ")) = " + ans)],
                            answer: m(ans),
                            traps: cands.map { m($0) })
                    }
                }),

            // MARK: |أ| = |ب|
            Formula(
                id: "abs_eq_two", topic: .functions, title: "معادلة قيمتين مطلقتين",
                expression: "|أ| = |ب|  ⇒  أ = ب   أو   أ = −ب",
                symbolic: true,
                explanation: "إذا تساوت القيمتان المطلقتان لعبارتين فإما أن تتساويا أو تكونا متعاكستين (أحدهما سالب الأخرى). نحل المعادلتين ونجمع الحلين.",
                trap: "الاكتفاء بالحالة الأولى أ = ب، أو نسيان توزيع الإشارة السالبة على كل حدود العبارة الثانية.",
                gen: { d in
                    let p = rnd(2...3)
                    var q = rnd(-5...5)
                    var s = rnd(-5...5)
                    var guardCount = 0
                    while (q + s) * (p + 1) == (q - s) * (p - 1) && guardCount < 50 {
                        q = rnd(-5...5); s = rnd(-5...5); guardCount += 1
                    }
                    if (q + s) * (p + 1) == (q - s) * (p - 1) { q = 1; s = 3 }
                    let x1 = (q + s, p - 1)
                    let x2 = (q - s, p + 1)
                    let lhs = mcLin(p, "س", -q)
                    let rhs = mcLin(1, "س", s)
                    let ans = mcSetFr([x1, x2])
                    let cands: [String] = [mcSetFr([(q - s, p - 1), (q + s, p + 1)]), mcSetFr([x1]),
                                           mcSetFr([(-(q + s), p - 1), (-(q - s), p + 1)]), mcSetFr([x2])]
                    return .text(
                        "مجموعة حل المعادلة " + m("|" + lhs + "| = |" + rhs + "|") + " هي:",
                        steps: ["الحالة الأولى: " + m(lhs + " = " + rhs) + "  ⇒  " + m("س = " + mcNg(frac(x1.0, x1.1))),
                                "الحالة الثانية: " + m(lhs + " = −(" + rhs + ")") + "  ⇒  " + m("س = " + mcNg(frac(x2.0, x2.1))),
                                "الحلان: " + ans],
                        answer: ans,
                        traps: cands)
                }),

            // MARK: متباينة القيمة المطلقة
            Formula(
                id: "abs_ineq", topic: .inequalities, title: "متباينات القيمة المطلقة",
                expression: "|أس − ب| < ج  ⇔  −ج < أس − ب < ج   ،   |أس − ب| > ج  ⇔  أس − ب > ج  أو  أس − ب < −ج",
                symbolic: true,
                explanation: "القيمة المطلقة هي بُعد العدد عن الصفر. |ع| < ج تعني أن ع قريبة من الصفر أي بين −ج و ج (متباينة مركبة، حل داخل الفترة). |ع| > ج تعني أن ع بعيدة أي أكبر من ج أو أصغر من −ج (حل خارج الفترة، فترتان). نحل ثم نقسم على معامل س.",
                trap: "الخلط بين «و» و«أو» (< تعني داخل الفترة، > تعني خارجها)، أو نسيان قسمة طرفي الفترة على المعامل.",
                gen: { d in
                    let ops = ["<", "≤", ">", "≥"]
                    let op = pick(ops)
                    let closed = isNonStrictOp(op)
                    let inside = op == "<" || op == "≤"
                    let coef = d == .hard ? rnd(2...4) : 1
                    let k = rnd(-6...6)
                    let w = rnd(1...(d == .easy ? 6 : 9))
                    let loS = mcNg(frac(k * coef - w, coef))
                    let hiS = mcNg(frac(k * coef + w, coef))
                    func inText(_ cl: Bool, _ a: String, _ b: String) -> String { mcIv(a, b, cl, cl) }
                    func outText(_ cl: Bool, _ a: String, _ b: String) -> String {
                        mcIv("−∞", a, false, cl) + " ∪ " + mcIv(b, "∞", cl, false)
                    }
                    let ans = inside ? inText(closed, loS, hiS) : outText(closed, loS, hiS)
                    let rawLo = mcI(k * coef - w)
                    let rawHi = mcI(k * coef + w)
                    var cands: [String] = [inside ? outText(closed, loS, hiS) : inText(closed, loS, hiS),
                                           inside ? inText(!closed, loS, hiS) : outText(!closed, loS, hiS)]
                    if coef > 1 {
                        cands.append(inside ? inText(closed, rawLo, rawHi) : outText(closed, rawLo, rawHi))
                    } else {
                        cands.append(inside ? inText(closed, mcI(-k - w), mcI(-k + w)) : outText(closed, mcI(-k - w), mcI(-k + w)))
                    }
                    cands.append("ℝ")
                    let expr = "|" + mcLin(coef, "س", -k * coef) + "| \(op) \(w)"
                    return .text(
                        "مجموعة حل المتباينة " + m(expr) + " هي:",
                        steps: [inside ? "تتحول إلى متباينة مركبة: " + m(mcNg("−\(w) \(op) \(mcLin(coef, "س", -k * coef)) \(op) \(w)"))
                                       : "تنفصل إلى حالتين: " + m(mcNg("\(mcLin(coef, "س", -k * coef)) \(op) \(w)  أو  \(mcLin(coef, "س", -k * coef)) \(flipOpText(op)) −\(w)")),
                                "نحل ونقسم على " + m("\(coef)") + ": الحدّان " + m(loS) + " و " + m(hiS),
                                inside ? "الحل داخل الفترة: " + m(ans) : "الحل خارج الفترة: " + m(ans)],
                        answer: m(ans),
                        traps: cands.map { m($0) })
                }),

            // MARK: حالات خاصة للقيمة المطلقة
            Formula(
                id: "abs_special", topic: .inequalities, title: "حالات خاصة: |س − أ| مقارنة بالصفر",
                expression: "|ع| ≥ 0: ℝ   ،   |ع| < 0: φ   ،   |ع| > 0: ℝ − {صفر ع}   ،   |ع| ≤ 0: {صفر ع}",
                symbolic: true,
                explanation: "القيمة المطلقة لا تكون سالبة أبداً، وتساوي صفراً فقط عندما يكون ما بداخلها صفراً. لذلك: ≥ 0 صحيحة دائماً (ℝ)، و< 0 مستحيلة (φ)، و> 0 صحيحة إلا عند الصفر (ℝ − {أ})، و≤ 0 لا يحققها إلا الصفر نفسه ({أ}).",
                trap: "فتح القيمة المطلقة إلى حالتين وحلهما بينما الجواب معروف من تعريفها.",
                gen: { d in
                    let a = rnd(-7...8)
                    let op = pick(["≥", "<", ">", "≤"])
                    let inner = mcLin(1, "س", -a)
                    let ans: String
                    switch op {
                    case "≥": ans = m("ℝ")
                    case "<": ans = m("φ")
                    case ">": ans = m("ℝ − {\(mcI(a))}")
                    default: ans = m("{\(mcI(a))}")
                    }
                    var e = Example.text(
                        "مجموعة حل المتباينة " + m("|" + inner + "| \(op) 0") + " هي:",
                        steps: ["القيمة المطلقة لا تكون سالبة، وتساوي صفراً فقط عند " + m(mcNg("س = \(a)")),
                                "الحل: " + ans],
                        answer: ans,
                        traps: [])
                    e.fixedOptions = [m("ℝ"), m("φ"), m("ℝ − {\(mcI(a))}"), m("{\(mcI(a))}")]
                    return e
                }),

            // MARK: مجال الدالة
            Formula(
                id: "domain_func", topic: .functions, title: "مجال الدالة",
                expression: "كسر: المقام ≠ 0   ،   √(ع): ع ≥ 0   ،   1/√(ع): ع > 0   ،   مجموع أو ضرب دالتين: تقاطع المجالين",
                symbolic: true,
                explanation: "المجال هو كل القيم المسموح التعويض بها. في الكسر نستبعد أصفار المقام. تحت الجذر الزوجي يجب أن يكون المقدار ≥ 0، وإذا كان الجذر في المقام فيجب أن يكون المقدار > 0 (لأن المقام لا يساوي صفراً). وإذا اجتمع شرطان نأخذ تقاطع مجاليهما.",
                trap: "نسيان أن الجذر في المقام يتطلب مقداراً أكبر تماماً من الصفر، أو نسيان استبعاد صفر المقام عند اجتماعه مع الجذر.",
                gen: { d in
                    switch d {
                    case .easy:
                        if Bool.random() {
                            var p = rnd(-6...6)
                            var q = rnd(-6...6)
                            var guardCount = 0
                            while q == p && guardCount < 50 { p = rnd(-6...6); q = rnd(-6...6); guardCount += 1 }
                            if q == p { p = 2; q = -3 }
                            let ans = "ℝ − {\(mcI(q))}"
                            let cands: [String] = ["ℝ − {\(mcI(-q))}", "ℝ", "ℝ − {\(mcI(p))}", "ℝ − {\(mcI(-p))}"]
                            return .text(
                                "مجال الدالة " + m("f(س) = " + mcFrac(mcLin(1, "س", p), mcLin(1, "س", -q))) + " هو:",
                                steps: ["المقام لا يساوي صفراً: " + m(mcNg("س ≠ \(q)")),
                                        "المجال: " + m(ans)],
                                answer: m(ans),
                                traps: cands.map { m($0) })
                        } else {
                            let c = rnd(2...7)
                            let p = rnd(-5...5)
                            let ans = "ℝ − {\(mcI(-c)) , \(c)}"
                            let cands: [String] = ["ℝ − {\(c)}", "ℝ − {\(mcI(-c))}", "ℝ", "ℝ − {\(mcI(-c)) , \(c) , \(mcI(p))}"]
                            return .text(
                                "مجال الدالة " + m("f(س) = " + mcFrac(mcLin(1, "س", p), "س² − \(c * c)")) + " هو:",
                                steps: ["المقام: " + m("س² − \(c * c) = (س − \(c))(س + \(c))") + " يساوي صفراً عند " + m(mcI(-c)) + " و " + m("\(c)"),
                                        "المجال: " + m(ans)],
                                answer: m(ans),
                                traps: cands.map { m($0) })
                        }
                    case .medium:
                        let a = rnd(-6...8)
                        let kind = rnd(0...3)
                        let forms: [String] = ["√(" + mcLin(1, "س", -a) + ")", "√(" + mcNg("\(a) − س") + ")",
                                               "1/√(" + mcLin(1, "س", -a) + ")", "1/√(" + mcNg("\(a) − س") + ")"]
                        let answers: [String] = [mcIv(mcI(a), "∞", true, false), mcIv("−∞", mcI(a), false, true),
                                                 mcIv(mcI(a), "∞", false, false), mcIv("−∞", mcI(a), false, false)]
                        var cands: [String] = []
                        for i in 0..<4 where i != kind { cands.append(answers[i]) }
                        cands.append("ℝ − {\(mcI(a))}")
                        let reason: String
                        switch kind {
                        case 0: reason = "ما تحت الجذر ≥ 0"
                        case 1: reason = "ما تحت الجذر ≥ 0، فنحل " + mcNg("\(a) − س ≥ 0")
                        case 2: reason = "ما تحت الجذر > 0 لأنه في المقام"
                        default: reason = "ما تحت الجذر > 0 لأنه في المقام، فنحل " + mcNg("\(a) − س > 0")
                        }
                        return .text(
                            "مجال الدالة " + m("f(س) = " + forms[kind]) + " هو:",
                            steps: [reason, "المجال: " + m(answers[kind])],
                            answer: m(answers[kind]),
                            traps: cands.map { m($0) })
                    case .hard:
                        let a = rnd(-5...3)
                        let b = a + rnd(2...6)
                        let kind = rnd(0...3)
                        let forms: [String] = ["√(" + mcLin(1, "س", -a) + ") + √(" + mcNg("\(b) − س") + ")",
                                               mcFrac("√(" + mcLin(1, "س", -a) + ")", mcLin(1, "س", -b)),
                                               mcFrac("√(" + mcNg("\(b) − س") + ")", "√(" + mcLin(1, "س", -a) + ")"),
                                               mcFrac("√(" + mcNg("\(b) − س") + ")", mcLin(1, "س", -a))]
                        let answers: [String] = [mcIv(mcI(a), mcI(b), true, true),
                                                 mcIv(mcI(a), "∞", true, false) + " − {\(mcI(b))}",
                                                 mcIv(mcI(a), mcI(b), false, true),
                                                 mcIv("−∞", mcI(b), false, true) + " − {\(mcI(a))}"]
                        var cands: [String] = []
                        for i in 0..<4 where i != kind { cands.append(answers[i]) }
                        cands.append("ℝ")
                        let reason: String
                        switch kind {
                        case 0: reason = "شرطان: " + mcNg("س ≥ \(a)") + " و " + mcNg("س ≤ \(b)") + ": نأخذ التقاطع"
                        case 1: reason = "تحت الجذر " + mcNg("س − \(a) ≥ 0") + " أي " + mcNg("س ≥ \(a)") + "، والمقام " + mcNg("س ≠ \(b)")
                        case 2: reason = "الجذر في المقام: " + mcNg("س − \(a) > 0") + "، وفي البسط: " + mcNg("\(b) − س ≥ 0") + "، فيتبقى " + mcNg("\(a) < س ≤ \(b)")
                        default: reason = "في البسط " + mcNg("س ≤ \(b)") + "، والمقام " + mcNg("س ≠ \(a)")
                        }
                        return .text(
                            "مجال الدالة " + m("f(س) = " + forms[kind]) + " هو:",
                            steps: [reason, "المجال: " + m(answers[kind])],
                            answer: m(answers[kind]),
                            traps: cands.map { m($0) })
                    }
                }),

            // MARK: إيجاد ثابت في الدالة
            Formula(
                id: "func_param", topic: .functions, title: "إيجاد ثابت في قاعدة الدالة",
                expression: "إذا كان ح(أ) = ب فنعوّض س = أ في القاعدة ونحل المعادلة الناتجة في الثابت",
                symbolic: false,
                explanation: "عندما تُعطى قيمة الدالة عند نقطة نعوّض المتغير بقيمته فتتكوّن معادلة في الثابت المجهول، نحلها. ويمكن التأكد بإعادة التعويض في القاعدة وفحص أي شرط إضافي (مثل ح(1) < 6).",
                trap: "التعويض في الثابت بدل المتغير، أو نسيان أن (−ك)·س عند س موجب يعطي حداً سالباً.",
                gen: { d in
                    switch d {
                    case .easy:
                        let a = rnd(2...5)
                        let k = rnd(-6...9)
                        let p = rnd(1...4)
                        let v = a * p + k
                        return .int(
                            "إذا كانت " + m("f(س) = \(a)س + ك") + " وكان " + m("f(\(p)) = \(v)") + " فإن " + m("ك") + " تساوي:",
                            steps: [m("f(\(p)) = \(a)(\(p)) + ك = \(v)"),
                                    m(mcNg("\(a * p) + ك = \(v)")) + "  ⇒  " + m(mcNg("ك = \(k)"))],
                            value: k,
                            traps: [-k, v, v + a * p, k + 1])
                    case .medium:
                        let a0 = rnd(1...3)
                        var k = rnd(-4...4)
                        while k == 0 { k = rnd(-4...4) }
                        let c = rnd(1...9)
                        let v = a0 * a0 - k * a0 + c
                        return .int(
                            "إذا كانت " + m("f(س) = س² − ك س + \(c)") + " وكان " + m("f(\(a0)) = \(v)") + " فإن " + m("ك") + " تساوي:",
                            steps: [m(mcNg("f(\(a0)) = \(a0 * a0) − \(a0)ك + \(c) = \(v)")),
                                    m(mcNg("\(a0)ك = \(a0 * a0 + c - v)")) + "  ⇒  " + m(mcNg("ك = \(k)"))],
                            value: k,
                            traps: [-k, a0 * a0 + c - v, k + 1, v - c])
                    case .hard:
                        let b = pick([2, 3])
                        let k = rnd(1...4)
                        let p = rnd(1...3)
                        let n = p * p + ipow(b, k)
                        return .int(
                            "لتكن " + m("f(س) = س² + \(b)^ك") + ". إذا كان " + m("f(\(p)) = \(n)") + " فإن " + m("ك") + " تساوي:",
                            steps: [m("f(\(p)) = \(p * p) + \(b)^ك = \(n)"),
                                    m("\(b)^ك = \(ipow(b, k))") + "  ⇒  " + m("ك = \(k)")],
                            value: k,
                            traps: [k + 1, k - 1, ipow(b, k), n - p * p + 1])
                    }
                }),

            // MARK: التعويض بعد الإزاحة
            Formula(
                id: "func_shift_eval", topic: .functions, title: "قيمة الدالة المعطاة بدلالة (س − ه)",
                expression: "ح(س − ه) = ق(س)  ⇒  ح(ن) = ق(ن + ه)   (نضع س − ه = ن)",
                symbolic: true,
                explanation: "إذا أُعطيت f(س − ه) كعبارة في س وطُلب f(ن) نساوي ما بداخل الدالة: س − ه = ن، فيكون س = ن + ه. ثم نعوّض هذه القيمة في العبارة المعطاة.",
                trap: "التعويض بـ س = ن مباشرة في العبارة المعطاة، أو طرح الإزاحة بدل إضافتها.",
                gen: { d in
                    let h = rnd(1...4)
                    let p = rnd(1...6)
                    var q = rnd(-5...9)
                    var t = rnd(1...8)
                    var guardCount = 0
                    while (t + h - q == 0 || t + h + p == 0) && guardCount < 100 {
                        q = rnd(-5...9); t = rnd(1...8); guardCount += 1
                    }
                    if t + h - q == 0 { q = t + h + 1 }
                    let x = t + h
                    let num = x + p
                    let den = x - q
                    let ans = frac(num, den)
                    var cands: [String] = [frac(t + p, t - q), frac(t - h + p, t - h - q), frac(den, num), frac(num, den + 1)]
                    cands = cands.filter { $0 != "—" }
                    return .text(
                        "إذا كان " + m("f(س − \(h)) = " + mcFrac(mcLin(1, "س", p), mcLin(1, "س", -q))) + " فإن " + m("f(\(t))") + " تساوي:",
                        steps: [m("س − \(h) = \(t)") + "  ⇒  " + m("س = \(x)"),
                                "نعوّض في العبارة: " + m(mcNg("(\(x) + \(p))/(\(x) − \(q)) = \(num)/\(den)")),
                                "الناتج: " + m(mcNg(ans))],
                        answer: m(mcNg(ans)),
                        traps: cands.map { m(mcNg($0)) },
                        numeric: Double(num) / Double(den))
                }),

            // MARK: النسبة والتناسب: توزيع مبلغ
            Formula(
                id: "ratio_parts", topic: .ratios, title: "توزيع مقدار بنسبة معطاة",
                expression: "نصيب = (الجزء ÷ مجموع الأجزاء) × المقدار الكلي   ،   قيمة الجزء الواحد = الكلي ÷ مجموع الأجزاء",
                symbolic: false,
                explanation: "نجمع أجزاء النسبة لنعرف عدد الأجزاء الكلي، ثم نقسم المقدار الكلي على هذا العدد لنحصل على قيمة الجزء الواحد، ثم نضرب في عدد أجزاء كل شخص.",
                trap: "قسمة المقدار على عدد الأشخاص (يجعل الأنصبة متساوية)، أو الضرب في الجزء دون قسمة على المجموع.",
                gen: { d in
                    let ratios: [[Int]] = lv(d, [[1, 2], [2, 3], [1, 3], [3, 5]], [[3, 4, 5], [1, 2, 3], [2, 3, 5], [1, 3, 4]], [[3, 4, 5], [2, 3, 7], [1, 4, 5], [2, 5, 6]])
                    let r = pick(ratios)
                    let total = r.reduce(0, +)
                    let unit = rnd(3...12)
                    let amount = total * unit
                    var people: [String] = []
                    var used: Set<String> = []
                    for i in 0..<r.count {
                        var n = i == 0 ? nm() : pick(maleNames)
                        while used.contains(n) { n = pick(maleNames) }
                        used.insert(n)
                        people.append(n)
                    }
                    let ratioText = r.map { String($0) }.joined(separator: " : ")
                    let biggest = r.max() ?? 1
                    let smallest = r.min() ?? 1
                    if d == .hard {
                        let diff = (biggest - smallest) * unit
                        return .int(
                            "وُزّع مبلغ \(amount) ديناراً على " + people.joined(separator: " و ") + " بنسبة " + m(ratioText) + ". فما الفرق بين أكبر نصيب وأصغر نصيب (بالدينار)؟",
                            steps: ["مجموع الأجزاء " + m("\(total)") + " والجزء الواحد " + m("\(amount) ÷ \(total) = \(unit)"),
                                    "الفرق بين الأجزاء " + m("\(biggest) − \(smallest) = \(biggest - smallest)"),
                                    "الفرق = " + m("\(biggest - smallest) × \(unit) = \(diff)")],
                            value: diff,
                            traps: [amount / r.count, biggest * unit, smallest * unit, diff + unit])
                    }
                    return .int(
                        "الأجر اليومي الإجمالي لـ \(r.count) عمال هو \(amount) ديناراً موزعة بينهم بنسبة " + m(ratioText) + ". فما أجر العامل الأكبر نصيباً (بالدينار)؟",
                        steps: ["مجموع الأجزاء " + m("\(r.map { String($0) }.joined(separator: " + ")) = \(total)"),
                                "قيمة الجزء الواحد " + m("\(amount) ÷ \(total) = \(unit)"),
                                "الأكبر نصيباً " + m("\(biggest) × \(unit) = \(biggest * unit)")],
                        value: biggest * unit,
                        traps: [amount / r.count, smallest * unit, (biggest - 1) * unit, biggest * unit + unit])
                }),

            // MARK: نسبة الفوز إلى الخسارة
            Formula(
                id: "win_loss_ratio", topic: .ratios, title: "نسبة الفوز إلى الخسارة (عدد المباريات)",
                expression: "فوز : خسارة = أ : ب  ⇒  عدد مرات الفوز = (أ/ب) × الخسارة   ،   المباريات الكلية = الفوز + الخسارة",
                symbolic: false,
                explanation: "نحدد قيمة الجزء الواحد من النسبة بقسمة عدد الخسارة المعروف على جزء الخسارة. ثم نضرب في جزء الفوز للحصول على عدد الفوز. وإذا سُئل عن عدد المباريات الكلي نجمع الفوز والخسارة (وليس الأجزاء).",
                trap: "الاكتفاء بجمع جزأي النسبة (15 + 16 = 31) كعدد للمباريات بدل ضربه بقيمة الجزء.",
                gen: { d in
                    let pairs: [(Int, Int)] = [(15, 16), (3, 2), (5, 3), (7, 4), (9, 5), (4, 3), (5, 2)]
                    let (w, l) = pick(pairs)
                    let k = rnd(2...8)
                    let losses = l * k
                    let wins = w * k
                    if d == .easy {
                        return .int(
                            "إذا كانت نسبة الفوز إلى الخسارة " + m("\(w) : \(l)") + " وكان عدد مرات الخسارة \(losses) فما عدد مرات الفوز؟",
                            steps: ["قيمة الجزء الواحد " + m("\(losses) ÷ \(l) = \(k)"),
                                    "الفوز " + m("\(w) × \(k) = \(wins)")],
                            value: wins,
                            traps: [losses + w - l, w + l, wins + k, losses * w])
                    }
                    return .int(
                        "إذا كانت نسبة الفوز إلى الخسارة " + m("\(w) : \(l)") + " وكان عدد مرات الخسارة \(losses) مباراة. فكم مباراة لعب الفريق؟",
                        steps: ["قيمة الجزء الواحد " + m("\(losses) ÷ \(l) = \(k)"),
                                "الفوز " + m("\(w) × \(k) = \(wins)"),
                                "المجموع " + m("\(wins) + \(losses) = \(wins + losses)")],
                        value: wins + losses,
                        traps: [wins, w + l, losses + k, wins + losses + k])
                }),

            // MARK: أوزان: مجموع وفرق
            Formula(
                id: "weights_sum_diff", topic: .ratios, title: "مسائل الأوزان: المجموع والفرق",
                expression: "الأكبر = (المجموع + الفرق) ÷ 2   ،   الأصغر = (المجموع − الفرق) ÷ 2",
                symbolic: false,
                explanation: "إذا عرفنا مجموع كميتين وفرقهما: الأكبر = (المجموع + الفرق) ÷ 2 والأصغر = (المجموع − الفرق) ÷ 2. أو نفرض الأصغر س والأكبر س + الفرق ونكوّن معادلة المجموع.",
                trap: "قسمة المجموع على 2 مباشرة (هذا يعطي المتوسط وليس الوزن الفعلي)، أو خلط الأكبر بالأصغر.",
                gen: { d in
                    let (a, b) = twoNames()
                    let heavy = rnd(55...95)
                    let light = rnd(35...(heavy - 5))
                    let total = heavy + light
                    let diff = heavy - light
                    let askHeavy = Bool.random()
                    return .int(
                        "وزن \(a) و\(b) معاً \(total) كلغ. فما وزن \(askHeavy ? a : b) (بالكيلوغرام) إذا كان \(a) أثقل من \(b) بـ \(diff) كلغ؟",
                        steps: ["نفرض وزن \(b) = س فيكون وزن \(a) = " + m("س + \(diff)"),
                                m("س + س + \(diff) = \(total)") + "  ⇒  " + m("2س = \(total - diff)") + "  ⇒  " + m("س = \(light)"),
                                "وزن \(a) = " + m("\(light) + \(diff) = \(heavy)")],
                        value: askHeavy ? heavy : light,
                        traps: [total / 2, askHeavy ? light : heavy, total - diff, total + diff])
                }),

            // MARK: أوزان بنسبة متسلسلة
            Formula(
                id: "weights_chain", topic: .ratios, title: "أوزان بنسب متسلسلة (نصف، ضعف)",
                expression: "إذا كان الثاني ن مثل الأول والثالث ن مثل الثاني: الأجزاء 1 : ن : ن²   والمجموع = (1 + ن + ن²) × الأصغر",
                symbolic: false,
                explanation: "نأخذ الأصغر وزناً كوحدة (س) ثم نعبّر عن الباقي بدلالته: إذا كان الكلب ضعف القطة والحمل ضعف الكلب فالقطة س والكلب 2س والحمل 4س. المجموع 7س، فنقسم المجموع الكلي على 7 لنجد س.",
                trap: "جمع النسبتين (2 + 2) بدل سلسلة الأجزاء 1 + 2 + 4، أو إعطاء الأكبر وزن الأصغر.",
                gen: { d in
                    let useTwo = d != .hard || Bool.random()
                    let n = useTwo ? 2 : 3
                    let parts = 1 + n + n * n
                    let unit = rnd(2...9)
                    let total = parts * unit
                    let mult = n * n
                    let animals = ["القطة", "الكلب", "الحمل"]
                    let ratioWord = n == 2 ? "ضعف" : "ثلاثة أمثال"
                    let ask = rnd(1...2)
                    let value = ask == 1 ? n * unit : mult * unit
                    return .int(
                        "وزن القطة والكلب والحمل معاً \(total) كلغ. فما وزن \(animals[ask]) (بالكيلوغرام) إذا كان الكلب \(ratioWord) القطة والحمل \(ratioWord) الكلب؟",
                        steps: ["القطة " + m("س") + " والكلب " + m("\(n)س") + " والحمل " + m("\(mult)س"),
                                m("\(parts)س = \(total)") + "  ⇒  " + m("س = \(unit)"),
                                animals[ask] + " = " + m("\(value)")],
                        value: value,
                        traps: [unit, total / 3, n * unit + unit, mult * unit - unit])
                }),

            // MARK: مقاييس الوزن القديمة
            Formula(
                id: "imperial_weight", topic: .ratios, title: "تحويل مقاييس الوزن (ستون ورطل إلى كيلوغرام)",
                expression: "1 ستون = 14 رطلاً   ،   1 رطل ≈ 450 غراماً   ،   1 كلغ = 1000 غرام",
                symbolic: false,
                explanation: "نحوّل الستون إلى أرطال أولاً (نضرب في 14) ونضيف الأرطال المتبقية، ثم نضرب العدد الكلي للأرطال في 450 غراماً ونقسم على 1000 لنحصل على الكيلوغرامات.",
                trap: "ضرب الستون في 450 مباشرة بدل تحويله إلى أرطال أولاً، أو القسمة على 100 بدل 1000.",
                gen: { d in
                    let s = rnd(7...14)
                    let p = rnd(0...13)
                    let pounds = 14 * s + p
                    let kg = Double(pounds * 450) / 1000
                    return .num(
                        "في مقاييس الوزن الإمبراطورية: كل ستون واحد يساوي 14 رطلاً، والرطل الواحد يساوي 450 غراماً تقريباً. إذا كان وزن رجل يساوي \(s) ستون و \(p) أرطال فما وزنه بالكيلوغرام؟",
                        steps: ["الأرطال الكلية " + m("\(s) × 14 + \(p) = \(pounds)"),
                                "بالغرام " + m("\(pounds) × 450 = \(pounds * 450)"),
                                "بالكيلوغرام " + m("\(pounds * 450) ÷ 1000 = \(fmt(kg))")],
                        value: kg,
                        unit: " كلغ",
                        traps: [Double((s + p) * 450) / 1000, Double(14 * s * 450) / 1000, Double(pounds * 45) / 1000, kg + 5])
                }),

            // MARK: حجم الكرة بدلالة القطر
            Formula(
                id: "sphere_ratio", topic: .geometry, title: "نسبة حجمي كرتين من نسبة قطريهما",
                expression: "ح = (4/3)π نق³   ⇒   إذا ضاعفنا القطر ن مرة يتضاعف الحجم ن³ مرة   (المساحة ن²)",
                symbolic: true,
                explanation: "الحجم يتناسب مع مكعب نصف القطر. إذا كان قطر الكرة أ يساوي ن أمثال قطر الكرة ب فإن نصف قطرها ن أمثال أيضاً، وحجمها ن³ مرة. مثلاً ضعف القطر يعني ثمانية أمثال الحجم.",
                trap: "ربط الحجم بالقطر مباشرة (ضعف القطر = ضعف الحجم) أو استعمال المربع بدل المكعب (هذا للمساحة).",
                gen: { d in
                    let n = rnd(2...4)
                    let word = n == 2 ? "ضعف" : (n == 3 ? "ثلاثة أمثال" : "أربعة أمثال")
                    let ans = "Va = \(n * n * n)Vb"
                    let cands: [String] = ["Va = \(n * n)Vb", "Va = \(n)Vb", "Va = (1/\(n * n * n))Vb", "Va = \(2 * n)Vb"]
                    var e = Example.text(
                        "لدينا كرتان a و b. إذا كان طول قطر الكرة a هو " + word + " قطر الكرة b فإن العبارة الصحيحة مما يلي هي:",
                        steps: ["الحجم يتناسب مع مكعب نصف القطر",
                                m("(\(n))³ = \(n * n * n)") + ": حجم الكرة a يساوي \(n * n * n) أمثال حجم b"],
                        answer: m(ans),
                        traps: cands.map { m($0) })
                    e.fixedOptions = ([ans] + cands.prefix(3)).shuffled().map { m($0) }
                    return e
                }),

            // MARK: صهر الأسطوانة إلى كرات
            Formula(
                id: "melt_pieces", topic: .geometry, title: "صهر أسطوانة وصنع كرات",
                expression: "حجم الأسطوانة = π نق² ع   ،   حجم الكرة = (4/3) π نق³   ،   عدد الكرات = حجم الأسطوانة ÷ حجم الكرة",
                symbolic: true,
                explanation: "عند الصهر يبقى الحجم ثابتاً. نحسب حجم الأسطوانة (الكابل) وحجم الكرة الواحدة ثم نقسم. π تُختصر من البسط والمقام. انتبه: الكرة تعطى بقطرها فنصف القطر نصفه.",
                trap: "استعمال القطر في صيغة الحجم بدل نصف القطر، أو نسيان العامل 4/3 في حجم الكرة.",
                gen: { d in
                    let r = rnd(1...3)
                    let k = rnd(2...8)
                    let h = 36 * k / (r * r)
                    let valid = (36 * k) % (r * r) == 0
                    let rr = valid ? r : 2
                    let hh = valid ? h : 9 * k
                    let cylinder = rr * rr * hh
                    return .int(
                        "كابل نحاس طوله \(hh) سم ونصف قطر مقطعه \(rr) سم. إذا صُهر هذا الكابل لصنع عدد " + m("ك") + " من الكرات طول قطر كل منها 6 سم فإن " + m("ك") + " تساوي: (اعتبر أن الحجم ثابت)",
                        steps: ["حجم الكابل " + m("π × \(rr)² × \(hh) = \(cylinder)π"),
                                "نصف قطر الكرة 3 سم، حجمها " + m("(4/3)π × 3³ = 36π"),
                                "العدد " + m("\(cylinder)π ÷ 36π = \(k)")],
                        value: k,
                        traps: [2 * k, cylinder / 27, k + 1, k - 1])
                }),

            // MARK: نفي العبارات المنطقية
            Formula(
                id: "logic_negation", topic: .logic, title: "نفي العبارات المركبة والمكافئات",
                expression: "¬(P ∧ Q) = ¬P ∨ ¬Q   ،   ¬(P ∨ Q) = ¬P ∧ ¬Q   ،   ¬(P ⇒ Q) = P ∧ ¬Q   ،   P ⇒ Q ≡ ¬Q ⇒ ¬P",
                symbolic: true,
                explanation: "قوانين دي مورغان: نفي «و» يصبح «أو» مع نفي الطرفين، ونفي «أو» يصبح «و» مع نفي الطرفين. ونفي «إذا كان P فإن Q» هو «P و ¬Q» (الشرط يتحقق والنتيجة لا تتحقق). والعبارة الشرطية تكافئ عكسها السالب: «إذا كان ¬Q فإن ¬P». ونفي «جميع» هو «يوجد على الأقل واحد لا يحقق»، ونفي «يوجد» هو «جميع لا تحقق».",
                trap: "الإبقاء على «و» عند النفي (يجب تبديلها بـ «أو»)، أو نفي النتيجة فقط في الشرطية، أو الخلط بين العكس (Q ⇒ P) والعكس السالب (¬Q ⇒ ¬P).",
                gen: { d in
                    let allowed = lv(d, [0, 1], [0, 1, 2, 3], [0, 1, 2, 3, 4, 5])
                    let kind = pick(allowed)
                    var i = rnd(0...(factBank.count - 1))
                    var j = rnd(0...(factBank.count - 1))
                    while j == i { j = rnd(0...(factBank.count - 1)) }
                    if i == j { i = 0; j = 1 }
                    let (p, np) = factBank[i]
                    let (q, nq) = factBank[j]
                    let statement: String
                    let correct: String
                    var wrongs: [String]
                    var rule = ""
                    var question = "نفي العبارة التالية هو:"
                    switch kind {
                    case 0:
                        statement = "\(p) و\(q)"
                        correct = "\(np) أو \(nq)"
                        wrongs = ["\(np) و\(nq)", "\(p) أو \(q)", "\(p) و\(nq)"]
                        rule = "نفي «و» يصبح «أو» مع نفي الطرفين"
                    case 1:
                        statement = "\(p) أو \(q)"
                        correct = "\(np) و\(nq)"
                        wrongs = ["\(np) أو \(nq)", "\(p) و\(q)", "\(np) أو \(q)"]
                        rule = "نفي «أو» يصبح «و» مع نفي الطرفين"
                    case 2:
                        statement = "إذا كان \(p) فإن \(q)"
                        correct = "\(p) و\(nq)"
                        wrongs = ["إذا كان \(np) فإن \(nq)", "إذا كان \(q) فإن \(p)", "\(np) و\(q)"]
                        rule = "نفي «إذا كان P فإن Q» هو «P و ¬Q»"
                    case 3:
                        statement = "إذا كان \(p) فإن \(q)"
                        question = "العبارة المكافئة للعبارة التالية هي:"
                        correct = "إذا كان \(nq) فإن \(np)"
                        wrongs = ["إذا كان \(np) فإن \(nq)", "إذا كان \(q) فإن \(p)", "\(p) و\(nq)"]
                        rule = "الشرطية تكافئ عكسها السالب: ¬Q ⇒ ¬P"
                    default:
                        let qb = pick(quantBank)
                        let all = Bool.random()
                        if all {
                            statement = "جميع \(qb.0) \(qb.1)"
                            correct = "يوجد من \(qb.0) من \(qb.2)"
                            wrongs = ["جميع \(qb.0) \(qb.2)", "يوجد من \(qb.0) من \(qb.1)", "لا يوجد من \(qb.0) من \(qb.2)"]
                            rule = "نفي «جميع» هو «يوجد على الأقل واحد لا يحقق»"
                        } else {
                            statement = "يوجد من \(qb.0) من \(qb.1)"
                            correct = "جميع \(qb.0) \(qb.2)"
                            wrongs = ["يوجد من \(qb.0) من \(qb.2)", "جميع \(qb.0) \(qb.1)", "ليس جميع \(qb.0) \(qb.2)"]
                            rule = "نفي «يوجد» هو «جميع لا تحقق»"
                        }
                    }
                    var e = Example.text(
                        question + "\n" + statement,
                        steps: [rule, "الجواب: " + correct],
                        answer: correct,
                        traps: [])
                    e.fixedOptions = ([correct] + wrongs).shuffled()
                    return e
                }),

            // MARK: استنباط أو استقراء
            Formula(
                id: "deduction_induction", topic: .logic, title: "الاستنباط والاستقراء",
                expression: "الاستنباط: من الكل إلى الجزء   ،   الاستقراء: من الجزء إلى الكل",
                symbolic: false,
                explanation: "الاستنباط ينتقل من قاعدة عامة إلى حالة خاصة (كل معلم رياضيات أصلع، وبراك معلم رياضيات، إذن براك أصلع) ونتيجته صحيحة بالضرورة إذا صحّت المقدمات. أما الاستقراء فينتقل من عدة أمثلة خاصة إلى قاعدة عامة (ثلاثة أبناء مهندسون فكل الأبناء مهندسون) ونتيجته محتملة وليست مؤكدة.",
                trap: "الحكم من وجود كلمة «كل» فقط، بينما المهم اتجاه الانتقال: من العام إلى الخاص استنباط، ومن الخاص إلى العام استقراء.",
                gen: { d in
                    let deductive = Bool.random()
                    let text = deductive ? pick(deductiveBank) : pick(inductiveBank)
                    let ans = deductive ? "استنباط (من الكل إلى الجزء)" : "استقراء (من الجزء إلى الكل)"
                    var e = Example.text(
                        "نوع الاستدلال في العبارة التالية:\n" + text,
                        steps: [deductive ? "ننتقل من قاعدة عامة إلى حالة خاصة" : "ننتقل من حالات خاصة إلى قاعدة عامة",
                                "النوع: " + ans],
                        answer: ans,
                        traps: [])
                    e.fixedOptions = ["استنباط (من الكل إلى الجزء)", "استقراء (من الجزء إلى الكل)", "نفي منطقي", "ليس أيا مما سبق"]
                    return e
                }),

            // MARK: إكمال الاستنباط
            Formula(
                id: "deduction_complete", topic: .logic, title: "إكمال الاستنباط المنطقي",
                expression: "كل أ هو ب   ،   س هو أ   ⇒   س هو ب",
                symbolic: false,
                explanation: "في الاستنباط نطبّق القاعدة العامة على الحالة الخاصة مباشرة. النتيجة هي ما يلزم بالضرورة عن المقدمتين، لا أكثر. احذر من عكس القاعدة (كل أ هو ب لا يعني كل ب هو أ) ومن نفي النتيجة.",
                trap: "عكس القاعدة العامة بدل تطبيقها، أو تعميم أكثر من اللازم.",
                gen: { d in
                    let item = pick(deductionBank)
                    var e = Example.text(
                        "أكمل العبارة التالية:\n" + item.0,
                        steps: ["نطبّق القاعدة العامة على الحالة الخاصة", "النتيجة: " + item.1],
                        answer: item.1,
                        traps: [])
                    e.fixedOptions = ([item.1] + item.2).shuffled()
                    return e
                })
        ]
    }
}

private func isNonStrictOp(_ op: String) -> Bool { op == "≥" || op == "≤" }

private func flipOpText(_ op: String) -> String {
    switch op {
    case "≥": return "≤"
    case "≤": return "≥"
    case ">": return "<"
    default: return ">"
    }
}
