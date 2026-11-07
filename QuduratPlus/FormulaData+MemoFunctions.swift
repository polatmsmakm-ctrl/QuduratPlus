import Foundation

// أنماط مأخوذة من مذكرة الاختبار: القيمة المطلقة، الدوال، والمنطق.

// MARK: - مساعدات خاصة بهذا الملف

/// سالب بإشارة رياضية.
private func neg(_ s: String) -> String { s.replacingOccurrences(of: "-", with: "−") }

/// عدد بين قوسين إذا كان سالباً: (−3).
private func pr(_ k: Int) -> String { k < 0 ? "(−\(-k))" : "\(k)" }

/// عبارة خطية: أس + ب.
private func lin(_ a: Int, _ b: Int) -> String {
    let core = b == 0 ? term(a) : term(a) + " " + signed(b)
    return neg(core)
}

/// مجموعة حلول مرتبة تصاعدياً مثل {−1 , 7}.
private func setText(_ xs: [Int]) -> String {
    let parts = xs.sorted().map { neg(String($0)) }
    return m("{" + parts.joined(separator: " , ") + "}")
}

private let noSolution = "لا يوجد حل"

/// جملة مع نوعها: 0 صحيحة، 1 خاطئة، 2 ليست عبارة.
private struct Claim {
    let text: String
    let kind: Int
}

private let claimBank: [Claim] = [
    Claim(text: "العدد الزوجي يقبل القسمة على " + m("2"), kind: 0),
    Claim(text: "حاصل ضرب عددين زوجيين هو عدد زوجي", kind: 0),
    Claim(text: "الجذر التربيعي للعدد " + m("49") + " يساوي " + m("7"), kind: 0),
    Claim(text: "العدد " + m("12") + " من مضاعفات العدد " + m("4"), kind: 0),
    Claim(text: "مجموع زوايا المثلث يساوي " + m("180°"), kind: 0),
    Claim(text: "الكويت دولة عربية", kind: 0),
    Claim(text: "العدد " + m("1") + " ليس عدداً أولياً", kind: 0),
    Claim(text: "العدد " + m("3") + " من عوامل العدد " + m("12"), kind: 0),
    Claim(text: "إذا كان " + m("س = 2") + " فإن " + m("س² − 5س + 6 = 0"), kind: 0),
    Claim(text: "نصف العدد " + m("50") + " هو " + m("25"), kind: 0),
    Claim(text: "حاصل ضرب عددين فرديين هو عدد زوجي", kind: 1),
    Claim(text: "الجذر التربيعي لأي عدد حقيقي يكون دائماً عدداً موجباً", kind: 1),
    Claim(text: "العدد " + m("329") + " يقبل القسمة على " + m("9"), kind: 1),
    Claim(text: "العدد " + m("2") + " عدد فردي", kind: 1),
    Claim(text: "مجموع زوايا الشكل الرباعي يساوي " + m("180°"), kind: 1),
    Claim(text: "الكويت تقع في قارة أفريقيا", kind: 1),
    Claim(text: "العدد " + m("15") + " عدد أولي", kind: 1),
    Claim(text: m("7 × 8 = 54"), kind: 1),
    Claim(text: "العدد " + m("0") + " عدد موجب", kind: 1),
    Claim(text: "مربع أي عدد حقيقي هو عدد موجب", kind: 1),
    Claim(text: "هل سجلت في اختبار القدرات؟", kind: 2),
    Claim(text: "ما أجمل مادة الرياضيات!", kind: 2),
    Claim(text: m("س + 3 = 5"), kind: 2),
    Claim(text: "احسب مساحة المستطيل", kind: 2),
    Claim(text: "ليتني أنجح في الاختبار", kind: 2),
    Claim(text: m("س² − 9 = 0"), kind: 2),
    Claim(text: "كم عدد طلاب الصف؟", kind: 2),
    Claim(text: "اجتهد في دراستك", kind: 2)
]

private let claimOptions = ["عبارة صحيحة", "عبارة خاطئة", "ليست عبارة", "لا يمكن تحديد صحتها"]

extension FormulaData {

    static func memoFunctionsLogic() -> [Formula] {
        return [

            // MARK: معادلات القيمة المطلقة
            Formula(
                id: "abs_eq", topic: .functions, title: "معادلات القيمة المطلقة",
                expression: "|أس + ب| = ج  ⇒  أس + ب = ج  أو  أس + ب = −ج   (ج ≥ 0)",
                symbolic: true,
                explanation: "القيمة المطلقة هي بُعد العدد عن الصفر، فلا تكون سالبة أبداً. المعادلة |أس + ب| = ج لها حلّان (نفصلها لحالتين: موجبة وسالبة) إذا كانت ج > 0، وحلّ واحد إذا كانت ج = 0، ولا حلّ لها إذا كانت ج < 0.",
                trap: "نسيان الحل الثاني، أو البحث عن حل لمعادلة قيمتها المطلقة تساوي عدداً سالباً (لا حل لها أصلاً).",
                gen: { d in
                    switch d {
                    case .easy:
                        let k = rnd(-8...8)
                        let w = rnd(1...7)
                        let inner = k == 0 ? "س" : "س " + signed(-k)
                        let eq = neg(m("|" + inner + "| = \(w)"))
                        let first = neg(m(inner + " = \(w)"))
                        let second = neg(m(inner + " = −\(w)"))
                        let s1 = neg(m("س = \(k + w)"))
                        let s2 = neg(m("س = \(k - w)"))
                        return .text(
                            "مجموعة حل المعادلة \(eq) هي:",
                            steps: ["نفصل الحالتين: \(first)  أو  \(second)",
                                    "الحلان: \(s1)  أو  \(s2)"],
                            answer: setText([k + w, k - w]),
                            traps: [setText([k + w]), setText([k - w]),
                                    setText([k + w + 1, k - w + 1]), setText([k + w - 1, k - w - 1]),
                                    setText([-(k + w), -(k - w)]), setText([w, -w])])
                    case .medium:
                        let kind = rnd(0...2)
                        if kind == 0 {
                            var b = 0
                            repeat { b = rnd(-9...9) } while b == 0
                            let inner = "س " + signed(b)
                            let eq = neg(m("|" + inner + "| = 0"))
                            let sol = -b
                            return .text(
                                "مجموعة حل المعادلة \(eq) هي:",
                                steps: ["القيمة المطلقة تساوي صفراً فقط عندما يكون ما بداخلها صفراً",
                                        neg(m(inner + " = 0")) + "  ⇒  " + neg(m("س = \(sol)")),
                                        "حل واحد فقط"],
                                answer: setText([sol]),
                                traps: [setText([sol, -sol]), setText([b]), setText([0]),
                                        setText([sol + 1]), setText([sol - 1])])
                        } else if kind == 1 {
                            let b = rnd(-9...9)
                            let c = rnd(1...6)
                            let inner = b == 0 ? "س" : "س " + signed(b)
                            let eq = neg(m("|" + inner + "| = −\(c)"))
                            return .text(
                                "مجموعة حل المعادلة \(eq) هي:",
                                steps: ["القيمة المطلقة لا تكون سالبة أبداً، والطرف الأيمن يساوي " + neg(m("−\(c)")),
                                        "إذن لا يوجد أي عدد يحقق المعادلة"],
                                answer: noSolution,
                                traps: [setText([c - b]), setText([-c - b]), setText([c - b, -c - b]),
                                        setText([c, -c])])
                        } else {
                            var a = 2, s1 = 0, s2 = 0
                            repeat {
                                a = rnd(2...3)
                                s1 = rnd(-6...8)
                                s2 = rnd(-6...8)
                            } while s1 == s2 || (a * (s1 + s2)) % 2 != 0
                            let b = -a * (s1 + s2) / 2
                            let c = a * abs(s1 - s2) / 2
                            let inner = lin(a, b)
                            let eq = neg(m("|" + inner + "| = \(c)"))
                            let e1 = neg(m(inner + " = \(c)"))
                            let e2 = neg(m(inner + " = −\(c)"))
                            let x1 = neg(m("س = \(max(s1, s2))"))
                            let x2 = neg(m("س = \(min(s1, s2))"))
                            return .text(
                                "مجموعة حل المعادلة \(eq) هي:",
                                steps: ["الحالة الأولى: \(e1)  ⇒  \(x1)",
                                        "الحالة الثانية: \(e2)  ⇒  \(x2)"],
                                answer: setText([s1, s2]),
                                traps: [setText([s1]), setText([s2]),
                                        setText([-s1, -s2]), setText([s1 + 1, s2 + 1]),
                                        setText([s1 - 1, s2 - 1])])
                        }
                    case .hard:
                        var a = 2, s1 = 0, s2 = 0
                        repeat {
                            a = rnd(2...4)
                            s1 = rnd(-5...9)
                            s2 = rnd(-5...9)
                        } while s1 == s2 || (a * (s1 + s2)) % 2 != 0
                        let b = -a * (s1 + s2) / 2
                        let c = a * abs(s1 - s2) / 2
                        let inner = lin(a, b)
                        let eq = neg(m("|" + inner + "| = \(c)"))
                        let e1 = neg(m(inner + " = \(c)"))
                        let e2 = neg(m(inner + " = −\(c)"))
                        let x1 = neg(m("س = \(max(s1, s2))"))
                        let x2 = neg(m("س = \(min(s1, s2))"))
                        let mode = rnd(0...2)
                        let sum = s1 + s2
                        let product = s1 * s2
                        let diff = abs(s1 - s2)
                        var steps = ["الحالة الأولى: \(e1)  ⇒  \(x1)",
                                     "الحالة الثانية: \(e2)  ⇒  \(x2)"]
                        if mode == 0 {
                            steps.append("المجموع: " + neg(m("\(s1) + \(pr(s2)) = \(sum)")))
                            return .int("ما مجموع حلّي المعادلة \(eq)؟", steps: steps, value: sum,
                                        traps: [product, diff, c, sum * 2])
                        } else if mode == 1 {
                            steps.append("حاصل الضرب: " + neg(m("\(pr(s1)) × \(pr(s2)) = \(product)")))
                            return .int("ما حاصل ضرب حلّي المعادلة \(eq)؟", steps: steps, value: product,
                                        traps: [sum, diff, c, -product])
                        } else {
                            steps.append("الفرق بين الحلين: " + neg(m("\(max(s1, s2)) − \(pr(min(s1, s2))) = \(diff)")))
                            return .int("ما الفرق بين الحل الأكبر والحل الأصغر للمعادلة \(eq)؟", steps: steps, value: diff,
                                        traps: [sum, product, c, diff * 2])
                        }
                    }
                }),

            // MARK: قيمة الدالة
            Formula(
                id: "func_eval", topic: .functions, title: "قيمة الدالة (التعويض)",
                expression: "f(س) = أس² + بس + ج  ⇒  f(ك) = أك² + بك + ج",
                symbolic: true,
                explanation: "عوّض القيمة في كل موضع فيه المتغير. ضع العدد السالب بين قوسين قبل التربيع حتى لا تضيع الإشارة. وفي f(أس + ب) عوّض العبارة كلها بدل س ثم فُكّ الأقواس بعناية.",
                trap: "تربيع العدد السالب بدون قوس فيصير (−3)² مثل −9 بدل 9، ونسيان الحد الأوسط عند فكّ مربع مجموع.",
                gen: { d in
                    switch d {
                    case .easy:
                        let a = rnd(2...6)
                        let b = rnd(-9...9)
                        let k = rnd(2...9)
                        let v = a * k + b
                        let fx = m("f(س) = " + lin(a, b))
                        let line = neg(m("f(\(k)) = \(a) × \(k) " + signed(b) + " = \(v)"))
                        return .int("إذا كانت \(fx)، فإن \(m("f(\(k))")) تساوي:",
                                    steps: ["نعوّض " + m("س = \(k)") + ": \(line)"],
                                    value: v, traps: [a + k + b, a * k - b, a * (k + b), v + a])
                    case .medium:
                        var k = 0
                        repeat { k = rnd(-4...4) } while k == 0
                        let a = rnd(1...4)
                        let b = rnd(-5...5)
                        let c = rnd(-9...9)
                        let v = a * k * k + b * k + c
                        let fx = m("f(س) = " + quad(a, b, c))
                        let sub = "\(a) × \(pr(k))² " + signed(b) + " × \(pr(k)) " + signed(c)
                        let line = neg(m("f(\(k)) = " + sub + " = \(v)"))
                        return .int("إذا كانت \(fx)، فإن \(m("f(\(neg(String(k))))")) تساوي:",
                                    steps: ["نعوّض " + neg(m("س = \(k)")) + ": \(line)",
                                            "تربيع العدد السالب يعطي عدداً موجباً"],
                                    value: v,
                                    traps: [-a * k * k + b * k + c, a * k + b * k + c, a * k * k - b * k + c, a * k * k + b * k - c])
                    case .hard:
                        let a = rnd(1...3)
                        let c = rnd(-9...9)
                        var q = 0
                        repeat { q = rnd(-3...3) } while q == 0
                        let p = rnd(2...3)
                        let bigA = a * p * p
                        let bigB = 2 * a * p * q
                        let bigC = a * q * q + c
                        let fx = m("f(س) = " + quad(a, 0, c))
                        let arg = lin(p, q)
                        let step1 = m("f(\(arg)) = \(a)(\(arg))² " + signed(c))
                        let step2 = m("(\(arg))² = " + quad(p * p, 2 * p * q, q * q))
                        let answer = m(quad(bigA, bigB, bigC))
                        return .text("إذا كانت \(fx)، فإن \(m("f(\(arg))")) تساوي:",
                                     steps: ["نعوّض العبارة كلها بدل س: \(step1)",
                                             "نفكّ المربع: \(step2)",
                                             "نضرب في \(a) ونضيف الثابت: \(answer)"],
                                     answer: answer,
                                     traps: [m(quad(bigA, 0, bigC)), m(quad(bigA, -bigB, bigC)),
                                             m(quad(bigA, bigB, a * q + c)), m(quad(a * p, bigB, bigC))])
                    }
                }),

            // MARK: تركيب الدوال
            Formula(
                id: "func_compose", topic: .functions, title: "تركيب الدوال",
                expression: "(f ∘ g)(س) = f(g(س))   ،   (g ∘ f)(س) = g(f(س))",
                symbolic: true,
                explanation: "في (f ∘ g)(س) نحسب الدالة الداخلية g أولاً ثم نعوّض ناتجها في f. الترتيب مهم: (f ∘ g) تختلف عادةً عن (g ∘ f).",
                trap: "عكس الترتيب (البدء بالدالة الخارجية)، أو نسيان الحد الأوسط عند تربيع مجموع في الدالة التربيعية.",
                gen: { d in
                    switch d {
                    case .easy:
                        let a = rnd(2...5), b = rnd(-5...5)
                        let c = rnd(2...4), dd = rnd(-5...5)
                        let k = rnd(1...5)
                        let g = c * k + dd
                        let v = a * g + b
                        let fx = m("f(س) = " + lin(a, b))
                        let gx = m("g(س) = " + lin(c, dd))
                        let st1 = neg(m("g(\(k)) = \(c) × \(k) " + signed(dd) + " = \(g)"))
                        let st2 = neg(m("f(\(g)) = \(a) × \(pr(g)) " + signed(b) + " = \(v)"))
                        let rev = c * (a * k + b) + dd
                        return .int("إذا كانت \(fx) و\(gx)، فأوجد \(m("(f ∘ g)(\(k))")).",
                                    steps: ["نحسب الدالة الداخلية أولاً: \(st1)",
                                            "نعوّض الناتج في f: \(st2)"],
                                    value: v, traps: [rev, a * k + b + g, g, v + a])
                    case .medium:
                        let a = rnd(2...4), b = rnd(-4...4)
                        let c = rnd(-6...6)
                        let k = rnd(1...4)
                        let fx = m("f(س) = " + lin(a, b))
                        let gx = m("g(س) = " + quad(1, 0, c))
                        if Bool.random() {
                            let inner = a * k + b
                            let v = inner * inner + c
                            let st1 = neg(m("f(\(k)) = \(a) × \(k) " + signed(b) + " = \(inner)"))
                            let st2 = neg(m("g(\(inner)) = \(pr(inner))² " + signed(c) + " = \(v)"))
                            let rev = a * (k * k + c) + b
                            return .int("إذا كانت \(fx) و\(gx)، فأوجد \(m("(g ∘ f)(\(k))")).",
                                        steps: ["نبدأ بالداخلية f: \(st1)", "ثم نعوّض في g: \(st2)"],
                                        value: v, traps: [rev, inner + c, inner * inner, v + a])
                        } else {
                            let inner = k * k + c
                            let v = a * inner + b
                            let st1 = neg(m("g(\(k)) = \(k)² " + signed(c) + " = \(inner)"))
                            let st2 = neg(m("f(\(pr(inner))) = \(a) × \(pr(inner)) " + signed(b) + " = \(v)"))
                            let rev = (a * k + b) * (a * k + b) + c
                            return .int("إذا كانت \(fx) و\(gx)، فأوجد \(m("(f ∘ g)(\(k))")).",
                                        steps: ["نبدأ بالداخلية g: \(st1)", "ثم نعوّض في f: \(st2)"],
                                        value: v, traps: [rev, inner + b, a * inner, v + a])
                        }
                    case .hard:
                        let a = rnd(2...3), b = rnd(1...4)
                        let c = rnd(-6...6)
                        let fx = m("f(س) = " + lin(a, b))
                        let gx = m("g(س) = " + quad(1, 0, c))
                        let bigA = a * a, bigB = 2 * a * b, bigC = b * b + c
                        let correct = m(quad(bigA, bigB, bigC))
                        let st1 = m("(g ∘ f)(س) = g(" + lin(a, b) + ") = (" + lin(a, b) + ")² " + signed(c))
                        let st2 = m("(" + lin(a, b) + ")² = " + quad(a * a, 2 * a * b, b * b))
                        return .text("إذا كانت \(fx) و\(gx)، فإن \(m("(g ∘ f)(س)")) تساوي:",
                                     steps: ["نعوّض f داخل g: \(st1)",
                                             "نفكّ مربع المجموع: \(st2)",
                                             "نضيف الثابت: \(correct)"],
                                     answer: correct,
                                     traps: [m(quad(bigA, bigB, c)), m(quad(bigA, a * b, bigC)),
                                             m(quad(a, 0, a * c + b)), m(quad(bigA, bigB, b * b - c))])
                    }
                }),

            // MARK: الدالة المتشعبة
            Formula(
                id: "piecewise", topic: .functions, title: "الدالة ذات الفرعين",
                expression: "نحدّد الفرع أولاً من الشرط على س، ثم نعوّض في قاعدة ذلك الفرع فقط",
                explanation: "الدالة المتشعبة لها قاعدتان لكل منهما شرط على س. قبل التعويض اسأل: هل القيمة تحقق الشرط الأول أم الثاني؟ ثم استعمل قاعدة ذلك الفرع وحدها.",
                trap: "تطبيق القاعدة الخاطئة، خصوصاً عند القيمة الحدّية (س = الحد الفاصل تنتمي للفرع الذي فيه إشارة ≥).",
                gen: { d in
                    let t = rnd(2...4)
                    let p = pick([-3, -2, -1, 1, 2])
                    let q = pick([3, 5, 6, 8, 10])
                    let u = rnd(t...(t + 6))
                    let v = rnd(-4...(t - 1))
                    func f1(_ x: Int) -> Int { x + p }
                    func f2(_ x: Int) -> Int { q - x * x }
                    func f(_ x: Int) -> Int { x >= t ? f1(x) : f2(x) }
                    let rule1 = neg(m("f(س) = س " + signed(p)))
                    let rule2 = neg(m("f(س) = \(q) − س²"))
                    let intro = "الدالة f معرّفة كالتالي: \(rule1) عندما " + m("س ≥ \(t)") + "، و\(rule2) عندما " + m("س < \(t)") + "."
                    switch d {
                    case .easy:
                        let useUpper = Bool.random()
                        let x = useUpper ? u : v
                        let ans = f(x)
                        let which = useUpper ? "س ≥ \(t)" : "س < \(t)"
                        let calc = useUpper ? "\(x) " + signed(p) : "\(q) − \(pr(x))²"
                        return .int("\(intro) أوجد \(neg(m("f(\(x))"))).",
                                    steps: [neg(m("\(x)")) + " تحقق الشرط " + m(which) + " فنستعمل القاعدة المناسبة",
                                            neg(m("f(\(x)) = " + calc + " = \(ans)"))],
                                    value: ans, traps: [useUpper ? f2(x) : f1(x), ans + 1, -ans])
                    case .medium:
                        let ans = f(u) + f(v)
                        return .int("\(intro) أوجد \(neg(m("f(\(u)) + f(\(v))"))).",
                                    steps: [neg(m("\(u) ≥ \(t)")) + " فنستعمل القاعدة الأولى: " + neg(m("f(\(u)) = \(f1(u))")),
                                            neg(m("\(v) < \(t)")) + " فنستعمل القاعدة الثانية: " + neg(m("f(\(v)) = \(q) − \(pr(v))² = \(f2(v))")),
                                            "المجموع: " + neg(m("\(f(u)) + \(pr(f(v))) = \(ans)"))],
                                    value: ans,
                                    traps: [f1(u) + f1(v), f2(u) + f2(v), f2(u) + f1(v), f(u) - f(v)])
                    case .hard:
                        let ans = f(u) * f(v)
                        return .int("\(intro) أوجد \(neg(m("f(\(u)) × f(\(v))"))).",
                                    steps: [neg(m("f(\(u)) = \(f(u))")) + " (القاعدة الأولى لأن " + m("\(u) ≥ \(t)") + ")",
                                            neg(m("f(\(v)) = \(f(v))")) + " (القاعدة الثانية لأن " + neg(m("\(v) < \(t)")) + ")",
                                            "حاصل الضرب: " + neg(m("\(pr(f(u))) × \(pr(f(v))) = \(ans)"))],
                                    value: ans,
                                    traps: [f(u) + f(v), f1(u) * f1(v), f2(u) * f2(v), -ans])
                    }
                }),

            // MARK: الدوال الزوجية والفردية
            Formula(
                id: "even_odd", topic: .functions, title: "الدوال الزوجية والفردية",
                expression: "زوجية: f(−س) = f(س)   ،   فردية: f(−س) = −f(س)",
                symbolic: true,
                explanation: "إذا كانت كل أسس س في الدالة زوجية (والثابت أسّه صفر) فهي زوجية، وإذا كانت كلها فردية فهي فردية. وإذا اجتمع النوعان أو وُجد ثابت مع أس فردي فهي لا زوجية ولا فردية.",
                trap: "اعتبار الثابت حداً فردياً: س³ + 5 ليست فردية لأن الثابت أسّه زوجي (صفر).",
                gen: { d in
                    let a = rnd(2...6)
                    let b = rnd(2...6)
                    let odds = [m("f(س) = س³"), m("f(س) = \(a)س³ + \(b)س"), m("f(س) = س⁵ − \(a)س"), m("f(س) = \(a)س")]
                    let evens = [m("f(س) = س² + \(a)"), m("f(س) = س⁴ − \(a)س²"), m("f(س) = \(a)س² + \(b)"), m("f(س) = س⁶ + \(a)")]
                    let neithers = [m("f(س) = س³ + \(a)"), m("f(س) = س² + \(a)س"), m("f(س) = س⁴ + س"),
                                    m("f(س) = \(a)س + \(b)"), m("f(س) = س³ + س²")]
                    let mode = d == .hard ? 2 : rnd(0...1)
                    if mode == 0 {
                        let ans = pick(odds)
                        let wrong = [pick(evens)] + Array(neithers.shuffled().prefix(2))
                        return .text("أي من الدوال التالية دالة فردية؟",
                                     steps: ["الدالة الفردية تحقق " + m("f(−س) = −f(س)"),
                                             "جميع الأسس في \(ans) فردية (س، س³، س⁵...) فعند التعويض بـ (−س) تنعكس إشارة كل حد",
                                             "الدوال الأخرى فيها ثابت أو أسس زوجية فلا تحقق الشرط"],
                                     answer: ans, traps: wrong)
                    } else if mode == 1 {
                        let ans = pick(evens)
                        let wrong = [pick(odds)] + Array(neithers.shuffled().prefix(2))
                        return .text("أي من الدوال التالية دالة زوجية؟",
                                     steps: ["الدالة الزوجية تحقق " + m("f(−س) = f(س)"),
                                             "جميع الأسس في \(ans) زوجية، والثابت أسّه صفر (زوجي)، فتبقى الإشارة كما هي عند التعويض بـ (−س)",
                                             "الدوال الأخرى فيها أسس فردية فلا تحقق الشرط"],
                                     answer: ans, traps: wrong)
                    } else {
                        let ans = pick(neithers)
                        let shuffledOdds = odds.shuffled()
                        let wrong = [shuffledOdds[0], pick(evens), shuffledOdds[1]]
                        return .text("أي من الدوال التالية ليست زوجية ولا فردية؟",
                                     steps: ["في \(ans) اجتمع أس فردي مع ثابت أو أس زوجي",
                                             "لذلك لا تحقق " + m("f(−س) = f(س)") + " ولا " + m("f(−س) = −f(س)")],
                                     answer: ans, traps: wrong)
                    }
                }),

            // MARK: العبارة الصحيحة والخاطئة
            Formula(
                id: "logic_statement", topic: .logic, title: "العبارة الصحيحة والخاطئة",
                expression: "العبارة = جملة تحتمل الصواب أو الخطأ فقط",
                explanation: "العبارة جملة خبرية يمكن الحكم عليها بأنها صحيحة أو خاطئة. السؤال والتعجب والأمر والدعاء ليست عبارات، وكذلك الجملة التي فيها مجهول (مثل س + 3 = 5) لأنها قد تكون صحيحة وقد تكون خاطئة حسب قيمة س.",
                trap: "اعتبار المعادلة التي فيها مجهول عبارة صحيحة أو خاطئة. وللحكم على «إذا كان… فإن…» عوّض القيمة المعطاة أولاً.",
                gen: { d in
                    let claim = pick(claimBank)
                    var e: Example
                    let answer = claimOptions[claim.kind]
                    var reason = ""
                    if claim.kind == 0 {
                        reason = "الجملة خبرية، ويمكن التأكد من صحتها، وهي هنا صحيحة"
                    } else if claim.kind == 1 {
                        reason = "الجملة خبرية ويمكن الحكم عليها، لكنها خاطئة"
                    } else {
                        reason = "ليست عبارة: فهي سؤال أو تعجب أو أمر أو تمنٍّ، أو معادلة فيها مجهول لا يمكن الحكم عليها بدون قيمته"
                    }
                    e = Example.text(
                        "حدد ما إذا كانت الجملة التالية عبارة صحيحة أو عبارة خاطئة أو ليست عبارة:\n«" + claim.text + "»",
                        steps: [reason, "الإجابة: " + answer],
                        answer: answer,
                        traps: claimOptions.filter { $0 != answer })
                    e.fixedOptions = claimOptions
                    return e
                }),

            // MARK: أدوات الربط
            Formula(
                id: "logic_connectives", topic: .logic, title: "أدوات الربط: و، أو، إذا… فإن",
                expression: "p ∧ q صحيحة فقط إذا صحّت الاثنتان   ،   p ∨ q خاطئة فقط إذا خطأت الاثنتان   ،   p ⇒ q خاطئة فقط إذا كانت p صحيحة وq خاطئة",
                symbolic: true,
                explanation: "«و» (∧) لا تصح إلا إذا صحّت العبارتان. «أو» (∨) تصح إذا صحّت واحدة على الأقل. «إذا كان p فإن q» (⇒) تخطئ في حالة واحدة فقط: p صحيحة وq خاطئة. والنفي (¬) يعكس قيمة العبارة.",
                trap: "الظن أن «إذا… فإن» تخطئ كلما كانت إحدى العبارتين خاطئة. فهي تصح دائماً إذا كانت المقدّمة p خاطئة.",
                gen: { d in
                    if d == .hard {
                        var pv = Bool.random()
                        var qv = Bool.random()
                        if Bool.random() { pv = !pv }
                        if Bool.random() { qv = !qv }
                        let forms: [(String, (Bool, Bool) -> Bool)] = [
                            ("p ∧ q", { p, q in p && q }),
                            ("p ∨ q", { p, q in p || q }),
                            ("¬p ∧ q", { p, q in !p && q }),
                            ("p ∧ ¬q", { p, q in p && !q }),
                            ("¬p ∨ ¬q", { p, q in !p || !q }),
                            ("p ⇒ q", { p, q in !p || q }),
                            ("q ⇒ p", { p, q in !q || p })
                        ]
                        let trues = forms.filter { $0.1(pv, qv) }.shuffled()
                        let falses = forms.filter { !$0.1(pv, qv) }.shuffled()
                        guard let right = trues.first, falses.count >= 3 else {
                            return .text("أي العبارات التالية صحيحة إذا كانت p صحيحة وq خاطئة؟",
                                         steps: ["p ∨ q صحيحة لأن إحدى العبارتين صحيحة"],
                                         answer: m("p ∨ q"), traps: [m("p ∧ q"), m("¬p ∧ q"), m("p ⇒ q")])
                        }
                        let options = ([right] + Array(falses.prefix(3))).shuffled().map { m($0.0) }
                        let pt = pv ? "صحيحة" : "خاطئة"
                        let qt = qv ? "صحيحة" : "خاطئة"
                        var e = Example.text(
                            "إذا كانت p عبارة \(pt) وq عبارة \(qt)، فأي العبارات التالية صحيحة؟",
                            steps: ["نعوّض القيم في كل خيار: \(m("p = " + (pv ? "T" : "F")))  و\(m("q = " + (qv ? "T" : "F")))",
                                    "العبارة الصحيحة الوحيدة هي " + m(right.0)],
                            answer: m(right.0),
                            traps: options.filter { $0 != m(right.0) })
                        e.fixedOptions = options
                        return e
                    }
                    let useImplication = d == .medium && Bool.random()
                    let statements = claimBank.filter { $0.kind != 2 }
                    let a = pick(statements)
                    var b = pick(statements)
                    while b.text == a.text { b = pick(statements) }
                    let ta = a.kind == 0, tb = b.kind == 0
                    var joined = ""
                    var truth = false
                    var rule = ""
                    if useImplication {
                        joined = "إذا كانت «" + a.text + "» فإن «" + b.text + "»"
                        truth = !ta || tb
                        rule = "«إذا… فإن» تخطئ فقط عندما تكون المقدّمة صحيحة والنتيجة خاطئة"
                    } else if Bool.random() {
                        joined = "«" + a.text + "» و«" + b.text + "»"
                        truth = ta && tb
                        rule = "«و» لا تصح إلا إذا صحّت العبارتان معاً"
                    } else {
                        joined = "«" + a.text + "» أو «" + b.text + "»"
                        truth = ta || tb
                        rule = "«أو» تصح إذا صحّت إحدى العبارتين على الأقل"
                    }
                    let answer = truth ? claimOptions[0] : claimOptions[1]
                    var e = Example.text(
                        "هل العبارة التالية صحيحة أم خاطئة؟\n" + joined,
                        steps: ["العبارة الأولى: " + (ta ? "صحيحة" : "خاطئة") + "، والثانية: " + (tb ? "صحيحة" : "خاطئة"),
                                rule,
                                "الإجابة: " + answer],
                        answer: answer,
                        traps: claimOptions.filter { $0 != answer })
                    e.fixedOptions = claimOptions
                    return e
                })
        ]
    }
}
