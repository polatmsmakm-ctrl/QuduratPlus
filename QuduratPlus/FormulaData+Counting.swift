import Foundation

extension FormulaData {

    // MARK: - الاحتمال المركّب والعدّ مع التكرار

    static func counting() -> [Formula] {
        return [
            Formula(
                id: "compound_prob", topic: .stats, title: "الاحتمال المركّب",
                expression: "للحدثين المستقلين: ح(أ و ب) = ح(أ) × ح(ب)   ،   بدون إرجاع: يتغير المقام بعد كل سحب",
                explanation: "إذا كان الحدثان مستقلين (رمي نقود ونرد، سحب مع الإرجاع) نضرب الاحتمالين. وفي السحب بدون إرجاع ينقص العدد الكلي وعدد المطلوب بعد السحبة الأولى.",
                trap: "جمع الاحتمالين بدل ضربهما في «و»، أو نسيان أن المقام ينقص في السحب بدون إرجاع.",
                gen: { d in
                    switch d {
                    case .easy:
                        let options: [(String, Int, String)] = [
                            ("صورة والعدد 6", 1, "ظهور العدد 6: " + m("1/6")),
                            ("كتابة وعدد زوجي", 3, "ظهور عدد زوجي (2، 4، 6): " + m("3/6 = 1/2")),
                            ("صورة وعدد أكبر من 4", 2, "ظهور 5 أو 6: " + m("2/6 = 1/3")),
                            ("كتابة وعدد أولي", 3, "الأعداد الأولية 2، 3، 5: " + m("3/6 = 1/2")),
                            ("صورة وعدد أقل من 3", 2, "ظهور 1 أو 2: " + m("2/6 = 1/3"))
                        ]
                        let o = pick(options)
                        let ans = frac(o.1, 12)
                        return .text(
                            "رُميت قطعة نقود ونرد معاً. ما احتمال ظهور \(o.0)؟",
                            steps: ["احتمال وجه القطعة المطلوب: " + m("1/2"), o.2,
                                    "الحدثان مستقلان فنضرب: " + m("1/2 × \(frac(o.1, 6)) = \(ans)")],
                            answer: m(ans),
                            traps: distinct(m(ans), [m(frac(o.1 + 3, 6)), m(frac(o.1, 6)), m("1/2"), m(frac(o.1 + 1, 12)), m(frac(1, 8))]),
                            numeric: Double(o.1) / 12)
                    case .medium, .hard:
                        let red = rnd(2...6)
                        let other = rnd(3...8)
                        let total = red + other
                        let withReplacement = d == .medium
                        let num = withReplacement ? red * red : red * (red - 1)
                        let den = withReplacement ? total * total : total * (total - 1)
                        let ans = frac(num, den)
                        let mode = withReplacement ? "مع الإرجاع" : "بدون إرجاع"
                        let second = withReplacement
                            ? "السحبة الثانية (بعد الإرجاع): " + m("\(red)/\(total)")
                            : "السحبة الثانية (بقي \(red - 1) حمراء من \(total - 1)): " + m("\(red - 1)/\(total - 1)")
                        return .text(
                            "صندوق فيه \(red) كرات حمراء و\(other) كرات بيضاء. سُحبت كرتان واحدة بعد الأخرى \(mode). ما احتمال أن تكون الكرتان حمراوين؟",
                            steps: ["السحبة الأولى: " + m("\(red)/\(total)"), second,
                                    "نضرب: " + m("\(num)/\(den) = \(ans)")],
                            answer: m(ans),
                            traps: distinct(m(ans), [
                                m(withReplacement ? frac(red * (red - 1), total * (total - 1)) : frac(red * red, total * total)),
                                m(frac(red, total)),
                                m(frac(2 * red, total)),
                                m(frac(red * (red - 1), total * total)),
                                m(frac(red, total * total))
                            ]),
                            numeric: Double(num) / Double(den))
                    }
                }),
            Formula(
                id: "perm_rep", topic: .stats, title: "العدّ مع التكرار",
                expression: "رموز بطول ر من ن خيارات مع التكرار = نʳ   ،   ترتيب عناصر فيها تكرار = ن! ÷ (ك₁! × ك₂! × …)",
                explanation: "إذا سُمح بالتكرار فلكل خانة ن خيارات فنضرب ن في نفسه ر مرة (مبدأ العد). وعند ترتيب عناصر بعضها متكرر نقسم ن! على مضروب عدد مرات تكرار كل عنصر.",
                trap: "استعمال التباديل بدون تكرار (ن × (ن−1) × …) في مسألة تسمح بالتكرار، أو نسيان القسمة على مضروب المتكرر.",
                gen: { d in
                    switch d {
                    case .easy:
                        let n = rnd(3...6)
                        let r = pick([2, 3])
                        let res = ipow(n, r)
                        let noRep = (0..<r).reduce(1) { $0 * (n - $1) }
                        return .int(
                            "كم رمزاً مكوناً من \(r) خانات يمكن تكوينه من الأرقام 1 إلى \(n) مع السماح بالتكرار؟",
                            steps: ["لكل خانة \(n) خيارات",
                                    "نضرب: " + m("\(n)^\(r) = \(res)")],
                            value: res, traps: [noRep, n * r, ipow(r, n)])
                    case .medium:
                        let shapes: [(word: String, counts: [Int])] = [
                            ("س س ص ع", [2, 1, 1]), ("س س ص ص", [2, 2]), ("س س س ص ع", [3, 1, 1]),
                            ("س س ص ص ع", [2, 2, 1]), ("س س ص ع ل", [2, 1, 1, 1]), ("س س س ص ص", [3, 2])
                        ]
                        let s = pick(shapes)
                        let n = s.counts.reduce(0, +)
                        let denominator = s.counts.map { fact($0) }.reduce(1, *)
                        let res = fact(n) / denominator
                        let denomText = s.counts.filter { $0 > 1 }.map { "\($0)!" }.joined(separator: " × ")
                        return .int(
                            "بكم طريقة يمكن ترتيب الحروف " + m(s.word) + " في صف؟",
                            steps: ["عدد الحروف \(n)، وفيها تكرار",
                                    "نقسم مضروب العدد على مضروب التكرارات: " + m("\(n)! ÷ (\(denomText)) = \(fact(n)) ÷ \(denominator) = \(res)")],
                            value: res, traps: [fact(n), res * 2, n * n])
                    case .hard:
                        let k = pick([5, 6, 7, 9])
                        let evens = k / 2
                        let res = k * k * evens
                        return .int(
                            "كم عدداً زوجياً من 3 أرقام يمكن تكوينه من الأرقام 1 إلى \(k) مع السماح بالتكرار؟",
                            steps: ["خانة الآحاد يجب أن تكون زوجية: \(evens) خيارات",
                                    "خانة العشرات والمئات: \(k) خيارات لكل منهما",
                                    "نضرب: " + m("\(k) × \(k) × \(evens) = \(res)")],
                            value: res, traps: [k * k * k, k * (k - 1) * evens, k * k * (k - evens)])
                    }
                })
        ]
    }

    // MARK: - الأعداد: الأسس، آحاد القوى، الكسور

    static func numbersPlus() -> [Formula] {
        return [
            Formula(
                id: "powers", topic: .numbers, title: "الأسس السالبة والكسرية",
                expression: "أ⁻ⁿ = 1 ÷ أⁿ   ،   أ^(م/ن) = (الجذر النوني لـ أ)^م   ،   أ⁰ = 1",
                explanation: "الأس السالب يعني المقلوب. والأس الكسري: المقام جذر والبسط قوة؛ ابدأ بالجذر لتبقى الأرقام صغيرة.",
                trap: "الظن أن الأس السالب يجعل الناتج سالباً، أو ضرب الأساس في الكسر بدل أخذ الجذر.",
                gen: { d in
                    switch d {
                    case .easy:
                        let base = pick([2, 3, 4, 5, 10])
                        let n = base <= 3 ? rnd(2...4) : 2
                        let den = ipow(base, n)
                        let ans = frac(1, den)
                        return .text(
                            "احسب: " + m("\(base)^(−\(n))"),
                            steps: ["الأس السالب يعني المقلوب: " + m("\(base)^(−\(n)) = 1 ÷ \(base)^\(n)"),
                                    "نحسب: " + m("1 ÷ \(den) = \(ans)")],
                            answer: m(ans),
                            traps: distinct(m(ans), [m("−\(den)"), m("−\(base * n)"), m(frac(1, base * n)), m(frac(-1, den))]),
                            numeric: 1 / Double(den))
                    case .medium:
                        let item = pick([(8, 2, 3, 2), (27, 2, 3, 3), (16, 3, 4, 2), (32, 2, 5, 2), (25, 3, 2, 5), (4, 3, 2, 2), (9, 3, 2, 3), (64, 2, 3, 4), (81, 3, 4, 3)])
                        let base = item.0, mm = item.1, nn = item.2, root = item.3
                        let value = ipow(root, mm)
                        return .int(
                            "احسب: " + m("\(base)^(\(mm)/\(nn))"),
                            steps: ["المقام \(nn) يعني جذراً: " + rootName(nn) + " لـ " + m("\(base)") + " يساوي " + m("\(root)"),
                                    "ثم نرفع للقوة \(mm): " + m("\(root)^\(mm) = \(value)")],
                            value: value)
                        .withTraps([Double(base * mm) / Double(nn), Double(root), Double(value * root)])
                    case .hard:
                        var a = 0, b = 0
                        repeat {
                            a = rnd(2...5)
                            b = rnd(3...9)
                        } while b - a < 1 || b - a > 6
                        let value = ipow(2, b - a)
                        return .int(
                            "احسب: " + m("2^(−\(a)) × 2^\(b)"),
                            steps: ["نجمع الأسس: " + m("−\(a) + \(b) = \(b - a)"),
                                    "الناتج: " + m("2^\(b - a) = \(value)")],
                            value: value, traps: [ipow(2, a + b), 2 * (b - a), ipow(2, b) - ipow(2, a)])
                    }
                }),
            Formula(
                id: "units_digit", topic: .numbers, title: "رقم آحاد القوى",
                expression: "آحاد قوى أي عدد تتكرر بدورة طولها 4 على الأكثر",
                explanation: "انظر لرقم آحاد الأساس فقط. دورات الآحاد: 2 → 2، 4، 8، 6 / 3 → 3، 9، 7، 1 / 7 → 7، 9، 3، 1 / 8 → 8، 4، 2، 6 / 4 → 4، 6 / 9 → 9، 1 / و0، 1، 5، 6 ثابتة. اقسم الأس على طول الدورة واستعمل الباقي (الباقي 0 يعني آخر الدورة).",
                trap: "حساب القوة كاملة، أو اعتبار الباقي 0 أول الدورة بدل آخرها.",
                gen: { d in
                    func cycle(_ digit: Int) -> [Int] {
                        var seen: [Int] = []
                        var v = digit % 10
                        repeat {
                            seen.append(v)
                            v = (v * digit) % 10
                        } while !seen.contains(v)
                        return seen
                    }
                    func unit(_ base: Int, _ e: Int) -> Int {
                        let c = cycle(base % 10)
                        let r = e % c.count
                        return c[r == 0 ? c.count - 1 : r - 1]
                    }
                    switch d {
                    case .easy:
                        let base = pick([2, 3])
                        let e = rnd(5...10)
                        let value = ipow(base, e)
                        let u = value % 10
                        return .int(
                            "ما رقم آحاد العدد " + m("\(base)^\(e)") + "؟",
                            steps: ["دورة آحاد قوى \(base): " + m(cycle(base).map { String($0) }.joined(separator: " ، ")),
                                    "تحقق: " + m("\(base)^\(e) = \(value)") + "، وآحاده \(u)"],
                            value: u, traps: [base, e % 10, (u + 2) % 10])
                    case .medium, .hard:
                        let bases = d == .medium ? [12, 13, 17, 23, 27, 38, 47] : [2, 3, 7, 8]
                        let base = pick(bases)
                        let e = d == .medium ? rnd(20...99) : rnd(100...999)
                        let c = cycle(base % 10)
                        let r = e % c.count
                        let u = unit(base, e)
                        let pos = r == 0 ? c.count : r
                        let wrongPos = c[r % c.count]
                        return .int(
                            "ما رقم آحاد العدد " + m("\(base)^\(e)") + "؟",
                            steps: ["ننظر لآحاد الأساس: \(base % 10)، ودورته: " + m(c.map { String($0) }.joined(separator: " ، ")) + " (طولها \(c.count))",
                                    "باقي قسمة الأس على \(c.count): " + m("\(e) ÷ \(c.count)") + " والباقي \(r)" + (r == 0 ? " (يعني آخر الدورة)" : ""),
                                    "العنصر رقم \(pos) في الدورة: \(u)"],
                            value: u, traps: [wrongPos, base % 10, e % 10])
                    }
                }),
            Formula(
                id: "fractions", topic: .numbers, title: "العمليات على الكسور",
                expression: "أ/ب + ج/د = (أد + بج) ÷ بد   ،   أ/ب ÷ ج/د = أ/ب × د/ج",
                symbolic: true,
                explanation: "للجمع والطرح وحّد المقامات أولاً. للضرب اضرب البسط في البسط والمقام في المقام. وللقسمة اقلب الكسر الثاني واضرب. وجزء من العدد = الكسر × العدد.",
                trap: "جمع البسطين والمقامين مباشرة (أ+ج)/(ب+د)، أو قلب الكسر الأول بدل الثاني في القسمة.",
                gen: { d in
                    switch d {
                    case .easy:
                        var b = 0, dd = 0
                        repeat {
                            b = pick([2, 3, 4, 5, 6])
                            dd = pick([3, 4, 5, 6, 8])
                        } while b == dd
                        let a = rnd(1...(b - 1)), c = rnd(1...(dd - 1))
                        let num = a * dd + b * c, den = b * dd
                        let ans = frac(num, den)
                        return .text(
                            "احسب: " + m("\(a)/\(b) + \(c)/\(dd)"),
                            steps: ["نوحّد المقامات: " + m("(\(a) × \(dd) + \(b) × \(c)) ÷ (\(b) × \(dd)) = \(num)/\(den)"),
                                    "نبسّط: " + m(ans)],
                            answer: m(ans),
                            traps: distinct(m(ans), [m(frac(a + c, b + dd)), m(frac(a * c, b * dd)), m(frac(a + c, b * dd)), m(frac(num + 1, den))]),
                            numeric: Double(num) / Double(den))
                    case .medium:
                        let a = rnd(1...5), b = rnd(2...9), c = rnd(1...5), dd = rnd(2...9)
                        let num = a * dd, den = b * c
                        let ans = frac(num, den)
                        return .text(
                            "احسب: " + m("\(a)/\(b) ÷ \(c)/\(dd)"),
                            steps: ["نقلب الكسر الثاني ونضرب: " + m("\(a)/\(b) × \(dd)/\(c)"),
                                    "الناتج: " + m("\(num)/\(den) = \(ans)")],
                            answer: m(ans),
                            traps: distinct(m(ans), [m(frac(a * c, b * dd)), m(frac(b * c, a * dd)), m(frac(a * dd + 1, b * c)), m(frac(num, den + 1))]),
                            numeric: Double(num) / Double(den))
                    case .hard:
                        var p = 0, q = 0, r = 0, s = 0
                        repeat {
                            p = rnd(1...3)
                            q = pick([3, 4, 5, 6])
                            r = rnd(1...3)
                            s = pick([2, 4, 5, 8])
                        } while p >= q || r >= s || gcd(p, q) != 1 || gcd(r, s) != 1 || (p == r && q == s)
                        let x = lcmInt(q, s) * rnd(1...4) * 2
                        let given = x * p / q
                        let want = x * r / s
                        return .int(
                            "إذا كان " + m("\(p)/\(q)") + " عدد يساوي \(given)، فكم يساوي " + m("\(r)/\(s)") + " العدد نفسه؟",
                            steps: ["العدد: " + m("\(given) ÷ \(p)/\(q) = \(given) × \(q)/\(p) = \(x)"),
                                    "المطلوب: " + m("\(r)/\(s) × \(x) = \(want)")],
                            value: want)
                        .withTraps([Double(given * r) / Double(s), Double(x), Double(given * s) / Double(r)])
                    }
                })
        ]
    }
}

/// اسم الجذر حسب رتبته.
func rootName(_ n: Int) -> String {
    switch n {
    case 2: return "الجذر التربيعي"
    case 3: return "الجذر التكعيبي"
    default: return "الجذر من الرتبة \(n)"
    }
}
