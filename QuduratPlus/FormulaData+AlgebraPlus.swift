import Foundation

extension FormulaData {

    // MARK: - الجبر: الأعمار، التربيعية، المعادلتان، الجذور

    static func algebraPlus() -> [Formula] {
        return [
            Formula(
                id: "ages", topic: .algebra, title: "مسائل الأعمار",
                expression: "بعد ن سنوات يزيد عمر كل شخص ن   ،   قبل ن سنوات ينقص ن",
                explanation: "سمِّ العمر المجهول الآن س، واكتب أعمار الجميع الآن ثم في الزمن المذكور (بإضافة أو طرح السنوات نفسها لكل شخص)، ثم كوّن معادلة من شرط المسألة.",
                trap: "إضافة السنوات لشخص واحد فقط، أو نسيان أن الفرق بين عمرين ثابت لا يتغير مع الزمن.",
                gen: { d in
                    switch d {
                    case .easy:
                        let k = pick([2, 3, 4])
                        let son = rnd(6...15)
                        let sum = son * (k + 1)
                        return .int(
                            "عمر الأب \(k) أمثال عمر ابنه، ومجموع عمريهما \(sum) سنة. كم عمر الابن؟",
                            steps: ["نفرض عمر الابن س، فعمر الأب " + m("\(k)س"),
                                    "المجموع: " + m("س + \(k)س = \(k + 1)س = \(sum)"),
                                    "عمر الابن: " + m("س = \(sum) ÷ \(k + 1) = \(son)")],
                            value: son, unit: " سنة")
                        .withTraps([Double(sum) / Double(k), Double(son * k), Double(sum) / 2])
                    case .medium:
                        let k = pick([2, 3])
                        let son = rnd(5...12)
                        let n = rnd(2...10)
                        let father = k * (son + n) - n
                        return .int(
                            "عمر أب \(father) سنة وعمر ابنه \(son) سنة. بعد كم سنة يصبح عمر الأب \(k == 2 ? "ضعف" : "ثلاثة أمثال") عمر ابنه؟",
                            steps: ["بعد ن سنة: " + m("\(father) + ن = \(k)(\(son) + ن)"),
                                    "نفك القوس: " + m("\(father) + ن = \(k * son) + \(k)ن"),
                                    "نجمع الحدود: " + m("\(father - k * son) = \(k - 1)ن") + " إذن " + m("ن = \(n)")],
                            value: n, unit: " سنة")
                        .withTraps([Double(father - k * son) / Double(k), Double(father - son), Double(n + k)])
                    case .hard:
                        var son = 0, n = 0, k = 0
                        repeat {
                            son = rnd(10...20)
                            n = rnd(2...6)
                            k = pick([2, 3, 4])
                        } while son - n < 2
                        let father = k * (son - n) + n
                        let sum = father + son
                        return .int(
                            "قبل \(n) سنوات كان عمر الأب \(k) أمثال عمر ابنه، ومجموع عمريهما الآن \(sum) سنة. كم عمر الابن الآن؟",
                            steps: ["نفرض عمر الابن الآن س، فعمر الأب الآن " + m("\(sum) − س"),
                                    "قبل \(n) سنوات: " + m("\(sum) − س − \(n) = \(k)(س − \(n))"),
                                    "نبسّط: " + m("\(sum - n) + \(k * n) = \(k + 1)س") + " ← " + m("\(sum - n + k * n) = \(k + 1)س"),
                                    "عمر الابن: " + m("س = \(sum - n + k * n) ÷ \(k + 1) = \(son)")],
                            value: son, unit: " سنة")
                        .withTraps([Double(sum) / Double(k + 1), Double(son - n), Double(father)])
                    }
                }),
            Formula(
                id: "quadratic", topic: .algebra, title: "المعادلة التربيعية",
                expression: "(س − أ)(س − ب) = 0  ⇒  س = أ أو س = ب   ،   مجموع الجذرين = −ب/أ   ،   حاصل ضربهما = ج/أ",
                symbolic: true,
                explanation: "حلّل المعادلة إلى عاملين وساوِ كل عامل بالصفر. وللمعادلة أس² + بس + ج = 0: مجموع الجذرين −ب/أ وحاصل ضربهما ج/أ (بدون حلّها).",
                trap: "عكس إشارة الجذرين: إذا كان العامل (س − 3) فالجذر +3 وليس −3.",
                gen: { d in
                    switch d {
                    case .easy, .medium:
                        var r1 = 0, r2 = 0
                        repeat {
                            r1 = rnd(1...9)
                            r2 = d == .easy ? rnd(1...9) : -rnd(1...9)
                        } while r1 == abs(r2)
                        let eq = quad(1, -(r1 + r2), r1 * r2) + " = 0"
                        func roots(_ a: Int, _ b: Int) -> String {
                            let lo = min(a, b), hi = max(a, b)
                            return m("س = \(lo) أو س = \(hi)".replacingOccurrences(of: "-", with: "−"))
                        }
                        let answer = roots(r1, r2)
                        return .text(
                            "حلّ المعادلة: " + m(eq),
                            steps: ["نبحث عن عددين مجموعهما " + m("\(r1 + r2)".replacingOccurrences(of: "-", with: "−")) + " وحاصل ضربهما " + m("\(r1 * r2)".replacingOccurrences(of: "-", with: "−")),
                                    "نحلّل: " + m(factor(1, -r1) + factor(1, -r2) + " = 0"),
                                    "الحل: " + answer],
                            answer: answer,
                            traps: distinct(answer, [roots(-r1, -r2), roots(r1, -r2), roots(-r1, r2), roots(r1 + r2, r1 * r2), roots(1, r1 * r2)]))
                    case .hard:
                        let a = pick([2, 3])
                        var r1 = 0, r2 = 0
                        repeat {
                            r1 = rnd(-6...6)
                            r2 = rnd(1...7)
                        } while r1 == 0 || r1 == r2
                        let b = -a * (r1 + r2)
                        let c = a * r1 * r2
                        let askProduct = Bool.random()
                        let value = askProduct ? r1 * r2 : r1 + r2
                        let what = askProduct ? "حاصل ضرب" : "مجموع"
                        let rule = askProduct ? m("ج ÷ أ = \(c) ÷ \(a)") : m("−ب ÷ أ = \(-b) ÷ \(a)")
                        return .int(
                            "ما \(what) جذري المعادلة " + m(quad(a, b, c) + " = 0") + "؟",
                            steps: ["المعاملات: " + m("أ = \(a) ، ب = \(b) ، ج = \(c)".replacingOccurrences(of: "-", with: "−")),
                                    "\(what) الجذرين = " + rule.replacingOccurrences(of: "-", with: "−") + " = " + m("\(value)".replacingOccurrences(of: "-", with: "−"))],
                            value: value,
                            traps: askProduct ? [c, -value, r1 + r2] : [b, -value, r1 * r2])
                    }
                }),
            Formula(
                id: "system_eq", topic: .algebra, title: "نظام معادلتين",
                expression: "بالحذف: اجمع أو اطرح المعادلتين لتختفي إحدى المتغيرات",
                explanation: "رتّب المعادلتين ثم اجمعهما أو اطرحهما (بعد الضرب في عدد مناسب إذا لزم) لتختفي إحدى المتغيرات. وأحياناً المطلوب س + ص مباشرة، فاجمع المعادلتين بدل إيجاد كل متغير.",
                trap: "الخطأ في الإشارة عند طرح المعادلتين، أو الاكتفاء بقيمة متغير واحد والمطلوب غيره.",
                gen: { d in
                    switch d {
                    case .easy:
                        let y = rnd(1...12)
                        let x = y + rnd(1...10)
                        let s = x + y, df = x - y
                        return .int(
                            "إذا كان " + m("س + ص = \(s)") + " و" + m("س − ص = \(df)") + "، فما قيمة س؟",
                            steps: ["نجمع المعادلتين: " + m("2س = \(s) + \(df) = \(s + df)"),
                                    "نقسم على 2: " + m("س = \(x)")],
                            value: x, traps: [y, s + df, s - df])
                    case .medium:
                        var a = 0, b = 0
                        repeat {
                            a = rnd(2...5)
                            b = rnd(1...3)
                        } while a <= b
                        let x = rnd(1...10), y = rnd(1...10)
                        let c = a * x + b * y, s = x + y
                        return .int(
                            "إذا كان " + m("\(term(a)) + \(term(b, "ص")) = \(c)") + " و" + m("س + ص = \(s)") + "، فما قيمة س؟",
                            steps: ["نضرب المعادلة الثانية في \(b): " + m("\(term(b)) + \(term(b, "ص")) = \(b * s)"),
                                    "نطرح من الأولى: " + m("\(term(a - b)) = \(c) − \(b * s) = \(c - b * s)"),
                                    "إذن " + m("س = \(c - b * s) ÷ \(a - b) = \(x)")],
                            value: x, traps: [y, s, x + 1])
                    case .hard:
                        var p = 0, q = 0
                        repeat {
                            p = rnd(2...6)
                            q = rnd(1...5)
                        } while p == q
                        let x = rnd(1...9), y = rnd(1...9)
                        let c1 = p * x + q * y, c2 = q * x + p * y
                        return .int(
                            "إذا كان " + m("\(term(p)) + \(term(q, "ص")) = \(c1)") + " و" + m("\(term(q)) + \(term(p, "ص")) = \(c2)") + "، فما قيمة " + m("س + ص") + "؟",
                            steps: ["نجمع المعادلتين مباشرة: " + m("\(term(p + q)) + \(term(p + q, "ص")) = \(c1 + c2)"),
                                    "نقسم على \(p + q): " + m("س + ص = \(c1 + c2) ÷ \(p + q) = \(x + y)")],
                            value: x + y, traps: [c1 + c2, abs(x - y), x * y])
                    }
                }),
            Formula(
                id: "radicals", topic: .algebra, title: "الجذور وتبسيطها",
                expression: "√(أ × ب) = √أ × √ب   ،   √(ك² × ن) = ك√ن   ،   ك√ن + ل√ن = (ك + ل)√ن",
                symbolic: true,
                explanation: "لتبسيط جذر: حلّل ما تحته إلى مربع كامل × عدد، وأخرج جذر المربع. تُجمع الجذور فقط إذا تشابه ما تحت الجذر.",
                trap: "جمع ما تحت الجذور: √أ + √ب لا تساوي √(أ + ب).",
                gen: { d in
                    switch d {
                    case .easy:
                        let pr = pick([(2, 8), (3, 12), (2, 18), (5, 20), (3, 27), (6, 24), (2, 32), (7, 28), (2, 50)])
                        let prod = pr.0 * pr.1
                        let root = Int(Double(prod).squareRoot().rounded())
                        return .int(
                            "احسب: " + m("√\(pr.0) × √\(pr.1)"),
                            steps: ["نجمعهما تحت جذر واحد: " + m("√(\(pr.0) × \(pr.1)) = √\(prod)"),
                                    "الجذر: " + m("√\(prod) = \(root)")],
                            value: root, traps: [prod, pr.0 + pr.1, root * 2])
                    case .medium:
                        let k = rnd(2...6)
                        let n = pick([2, 3, 5, 6, 7])
                        let inside = k * k * n
                        let answer = m("\(k)√\(n)")
                        return .text(
                            "بسّط: " + m("√\(inside)"),
                            steps: ["نحلّل: " + m("\(inside) = \(k * k) × \(n)"),
                                    "نخرج جذر المربع: " + m("√\(k * k) × √\(n) = \(k)√\(n)")],
                            answer: answer,
                            traps: distinct(answer, [m("\(n)√\(k)"), m("\(k * k)√\(n)"), m("\(k)√\(n * 2)"), m("\(k + 1)√\(n)"), m("\(n)√\(k * k)")]))
                    case .hard:
                        let n = pick([2, 3, 5])
                        var a = 0, b = 0
                        repeat {
                            a = rnd(2...5)
                            b = rnd(2...6)
                        } while a == b
                        let x = a * a * n, y = b * b * n
                        let answer = m("\(a + b)√\(n)")
                        return .text(
                            "احسب: " + m("√\(x) + √\(y)"),
                            steps: ["نبسّط كل جذر: " + m("√\(x) = \(a)√\(n)") + " و" + m("√\(y) = \(b)√\(n)"),
                                    "نجمع الجذور المتشابهة: " + m("\(a)√\(n) + \(b)√\(n) = \(a + b)√\(n)")],
                            answer: answer,
                            traps: distinct(answer, [m("√\(x + y)"), m("\(a * b)√\(n)"), m("\(a + b)√\(2 * n)"), m("\(a + b + 1)√\(n)")]))
                    }
                })
        ]
    }
}
