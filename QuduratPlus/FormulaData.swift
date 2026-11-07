import Foundation

enum FormulaData {
    static let all: [Formula] = {
        var l: [Formula] = []
        l += FormulaData.ratios()
        l += FormulaData.algebra()
        l += FormulaData.geometry()
        l += FormulaData.motion()
        l += FormulaData.stats()
        l += FormulaData.sequences()
        l += FormulaData.numbers()
        // المرحلة 2: توسيع المنهج والمقارنات
        l += FormulaData.commerce()
        l += FormulaData.algebraPlus()
        l += FormulaData.geometryPlus()
        l += FormulaData.counting()
        l += FormulaData.numbersPlus()
        l += FormulaData.comparisons()
        // المرحلة 5: أنماط المذكرة (الدوال، المنطق، السرعة، النسب، السعة...)
        l += FormulaData.memoFunctionsLogic()
        l += FormulaData.memoApplied()
        l += FormulaData.memoChapter1()
        l += FormulaData.memoChapter2()
        l += FormulaData.memoChapter3()
        l += FormulaData.memoChapters4to9()
        return l
    }()

    static func formula(forDay day: Date) -> Formula {
        let n = Calendar.current.ordinality(of: .day, in: .era, for: day) ?? 0
        return all[n % all.count]
    }

    static func formulaOfDay() -> Formula {
        return formula(forDay: Date())
    }

    static func formula(id: String) -> Formula? {
        all.first { $0.id == id }
    }

    // MARK: - الحساب والنسب

    static func ratios() -> [Formula] {
        return [
            Formula(
                id: "pct_of", topic: .ratios, title: "النسبة المئوية من عدد",
                expression: "الجزء = (النسبة ÷ 100) × الكل",
                explanation: "حوّل النسبة المئوية إلى كسر بقسمتها على 100، ثم اضربها في العدد. كلمة «من» تعني ضرب.",
                trap: "نسيان القسمة على 100، أو الخلط بين 5% و0.5 (الصحيح أن 5% تساوي 0.05). وفي «نسبة من نسبة» لا تجمع النسبتين.",
                gen: { d in
                    if d == .hard {
                        var total = 0, p = 0, q = 0
                        repeat {
                            total = pick([200, 400, 500, 800, 1000, 1200, 2000])
                            p = pick([10, 20, 25, 40, 50])
                            q = pick([10, 20, 25, 50])
                        } while (total * p) % 100 != 0 || ((total * p / 100) * q) % 100 != 0
                        let a = total * p / 100
                        let r = a * q / 100
                        return .int(
                            "كم يساوي \(q)% من \(p)% من العدد \(total)؟",
                            steps: ["نبدأ بالنسبة الأقرب للعدد: " + m("\(p)% × \(total) = \(a)"),
                                    "ثم نأخذ النسبة الثانية من الناتج: " + m("\(q)% × \(a) = \(r)"),
                                    "لا نجمع النسبتين؛ النسبة الثانية تُحسب من ناتج الأولى"],
                            value: r, traps: [total * (p + q) / 100, a, r * 10])
                    }
                    var total = 0, p = 0
                    repeat {
                        total = d == .easy ? pick([40, 60, 80, 100, 200, 300, 400]) : pick([60, 80, 120, 150, 240, 250, 360, 450, 500])
                        p = d == .easy ? pick([10, 20, 25, 50]) : pick([5, 15, 30, 35, 40, 60, 75])
                    } while (total * p) % 100 != 0
                    let r = total * p / 100
                    return .int(
                        "كم يساوي \(p)% من \(total)؟",
                        steps: ["نحوّل النسبة إلى كسر: " + m("\(p)% = \(p) ÷ 100"),
                                "نضرب في العدد: " + m("\(p) ÷ 100 × \(total) = \(r)")],
                        value: r, traps: [r * 10, total - r, r * 2])
                }),
            Formula(
                id: "pct_find", topic: .ratios, title: "إيجاد النسبة المئوية",
                expression: "النسبة = (الجزء ÷ الكل) × 100",
                explanation: "اقسم الجزء على الكل ثم اضرب الناتج في 100. تأكد أن الكل هو العدد الذي بعد «من». قد تزيد النسبة على 100% إذا كان الجزء أكبر من الكل.",
                trap: "قلب الجزء مع الكل. السؤال «ما نسبة أ من ب؟» يعني أ ÷ ب وليس العكس. ونسيان الضرب في 100.",
                gen: { d in
                    var total = 0, pc = 0
                    repeat {
                        total = lv(d, pick([20, 40, 50, 100, 200]), pick([40, 60, 80, 120, 150, 250, 300, 400]), pick([20, 40, 60, 80, 120, 200]))
                        pc = lv(d, pick([10, 25, 50, 75]), pick([5, 15, 20, 30, 35, 40, 60, 80]), pick([110, 120, 125, 150, 175, 200, 250]))
                    } while (total * pc) % 100 != 0
                    let part = total * pc / 100
                    return .int(
                        "ما النسبة المئوية للعدد \(part) من العدد \(total)؟",
                        steps: ["نقسم الجزء على الكل: " + m("\(part) ÷ \(total) = \(fmt(Double(part) / Double(total)))"),
                                "نضرب في 100: " + m("\(fmt(Double(part) / Double(total))) × 100 = \(pc)%")],
                        value: pc, unit: "%",
                        traps: [])
                    .withTraps([Double(part) / Double(total), Double(total) * 100 / Double(part), Double(100 - pc)])
                }),
            Formula(
                id: "pct_change", topic: .ratios, title: "نسبة الزيادة أو النقصان",
                expression: "نسبة التغيّر = (الفرق ÷ القيمة القديمة) × 100",
                explanation: "احسب الفرق بين القيمتين، ثم اقسمه دائماً على القيمة القديمة (الأصلية) واضرب في 100. ولإيجاد القيمة الأصلية بعد زيادة ن% اقسم الجديدة على (1 + ن%).",
                trap: "القسمة على القيمة الجديدة بدل القديمة. وزيادة 20% ثم نقصان 20% لا تعيدك للقيمة الأصلية.",
                gen: { d in
                    if d == .hard {
                        var old = 0, pc = 0
                        repeat {
                            old = pick([40, 60, 80, 100, 120, 200, 240, 400])
                            pc = pick([10, 20, 25, 50])
                        } while (old * (100 + pc)) % 100 != 0
                        let nw = old * (100 + pc) / 100
                        return .int(
                            "ارتفع سعر سلعة بنسبة \(pc)% فأصبح \(nw) دينار. كم كان سعرها قبل الزيادة؟",
                            steps: ["السعر الجديد يساوي " + m("\(100 + pc)%") + " من القديم",
                                    "نقسم الجديد على هذه النسبة: " + m("\(nw) × 100 ÷ \(100 + pc) = \(old)"),
                                    "لا نطرح \(pc)% من السعر الجديد؛ النسبة محسوبة من القديم"],
                            value: old, unit: " دينار")
                        .withTraps([Double(nw * (100 - pc)) / 100, Double(nw - pc), Double(old + pc)])
                    }
                    var old = 0, pc = 0
                    repeat {
                        old = d == .easy ? pick([20, 40, 50, 80, 100, 200]) : pick([40, 60, 80, 120, 150, 240, 300, 500])
                        pc = d == .easy ? pick([10, 20, 25, 50]) : pick([5, 15, 20, 30, 40, 60])
                    } while (old * pc) % 100 != 0
                    let up = Bool.random()
                    let diff = old * pc / 100
                    let nw = up ? old + diff : old - diff
                    let word = up ? "الزيادة" : "النقصان"
                    let verb = up ? "ارتفع" : "انخفض"
                    return .int(
                        "\(verb) سعر سلعة من \(old) إلى \(nw). ما نسبة \(word)؟",
                        steps: ["مقدار التغيّر: " + m("|\(nw) − \(old)| = \(diff)"),
                                "نقسم على القيمة القديمة ونضرب في 100: " + m("\(diff) ÷ \(old) × 100 = \(pc)%")],
                        value: pc, unit: "%")
                    .withTraps([Double(diff) * 100 / Double(nw), Double(diff), Double(100 - pc)])
                }),
            Formula(
                id: "discount", topic: .ratios, title: "الخصم والسعر بعد الخصم",
                expression: "السعر بعد الخصم = السعر × (1 − نسبة الخصم)",
                explanation: "مقدار الخصم = السعر × نسبة الخصم. أو اضرب مباشرة في (100% − الخصم). مثلاً خصم 20% يعني الدفع 80%. والخصمان المتتاليان يُطبّقان واحداً بعد الآخر.",
                trap: "طرح النسبة المئوية من السعر مباشرة (مثل 200 − 20). وجمع خصمين متتاليين (20% ثم 10% لا تساوي 30%).",
                gen: { d in
                    if d == .hard {
                        var price = 0, d1 = 0, d2 = 0
                        repeat {
                            price = pick([200, 400, 500, 800, 1000, 2000])
                            d1 = pick([10, 20, 25, 50])
                            d2 = pick([10, 20])
                        } while (price * (100 - d1)) % 100 != 0 || ((price * (100 - d1) / 100) * (100 - d2)) % 100 != 0
                        let after1 = price * (100 - d1) / 100
                        let finalPrice = after1 * (100 - d2) / 100
                        return .int(
                            "سلعة سعرها \(price) دينار، خُصم منها \(d1)% ثم خُصم \(d2)% من السعر الجديد. كم سعرها النهائي؟",
                            steps: ["بعد الخصم الأول: " + m("\(price) × \(100 - d1)% = \(after1)"),
                                    "بعد الخصم الثاني: " + m("\(after1) × \(100 - d2)% = \(finalPrice)"),
                                    "لا نجمع الخصمين (\(d1 + d2)%)؛ الثاني يُحسب من السعر بعد الأول"],
                            value: finalPrice, unit: " دينار",
                            traps: [price * (100 - d1 - d2) / 100, after1, price - d1 - d2])
                    }
                    var price = 0, dc = 0
                    repeat {
                        price = d == .easy ? pick([100, 200, 400, 500, 1000]) : pick([80, 120, 150, 240, 300, 360, 450, 600])
                        dc = d == .easy ? pick([10, 20, 25, 50]) : pick([15, 20, 30, 35, 40])
                    } while (price * dc) % 100 != 0
                    let off = price * dc / 100
                    let after = price - off
                    return .int(
                        "سعر سلعة \(price) دينار وعليها خصم \(dc)%. كم سعرها بعد الخصم؟",
                        steps: ["مقدار الخصم: " + m("\(price) × \(dc) ÷ 100 = \(off)"),
                                "السعر بعد الخصم: " + m("\(price) − \(off) = \(after)")],
                        value: after, unit: " دينار", traps: [off, price - dc, price + off])
                }),
            Formula(
                id: "proportion", topic: .ratios, title: "التناسب (الضرب التبادلي)",
                expression: "أ ÷ ب = ج ÷ س  ⇒  س = (ب × ج) ÷ أ",
                symbolic: true,
                explanation: "في التناسب حاصل ضرب الطرفين يساوي حاصل ضرب الوسطين. اضرب بالتقاطع ثم اقسم. وفي المسائل اللفظية احسب قيمة الوحدة الواحدة أولاً.",
                trap: "ترتيب الحدود: تأكد أن الكميات المتشابهة في نفس الجهة (ساعات مع ساعات، ودنانير مع دنانير). والتفكير بالجمع بدل الضرب.",
                gen: { d in
                    if d == .hard {
                        let n1 = pick([3, 4, 5, 6, 8])
                        let unitPrice = pick([5, 7, 9, 12, 15, 25])
                        var n2 = 0
                        repeat { n2 = pick([7, 9, 11, 13, 14]) } while n2 == n1
                        let total1 = n1 * unitPrice
                        let answer = n2 * unitPrice
                        return .int(
                            "ثمن \(n1) كتب \(total1) ديناراً. كم ثمن \(n2) كتاباً من النوع نفسه؟",
                            steps: ["ثمن الكتاب الواحد: " + m("\(total1) ÷ \(n1) = \(unitPrice)"),
                                    "ثمن \(n2) كتاباً: " + m("\(n2) × \(unitPrice) = \(answer)")],
                            value: answer, unit: " دينار",
                            traps: [total1 + (n2 - n1), total1 * n2, answer + unitPrice])
                    }
                    let a = d == .easy ? pick([2, 3, 4, 5]) : rnd(3...9)
                    let b = d == .easy ? pick([3, 5, 7, 9, 10]) : rnd(4...15)
                    let t = d == .easy ? pick([2, 3]) : rnd(3...8)
                    let c = a * t
                    let x = b * t
                    return .int(
                        "إذا كانت النسبة \(m("\(a) : \(b) = \(c) : س"))، فما قيمة س؟",
                        steps: ["نضرب بالتقاطع: " + m("\(a) × س = \(b) × \(c) = \(b * c)"),
                                "نقسم: " + m("س = \(b * c) ÷ \(a) = \(x)")],
                        value: x)
                    .withTraps([Double(a * c) / Double(b), Double(b * c), Double(c + b - a)])
                }),
            Formula(
                id: "average", topic: .ratios, title: "المتوسط الحسابي",
                expression: "المتوسط = مجموع القيم ÷ عددها",
                explanation: "اجمع كل القيم ثم اقسم على عددها. إذا عرفت المتوسط وعدد القيم فمجموع القيم = المتوسط × العدد، ومنه تجد أي قيمة ناقصة.",
                trap: "القسمة على عدد خاطئ (نسيان قيمة مكررة). ومتوسط المتوسطات لا يساوي المتوسط العام إلا إذا تساوت المجموعات.",
                gen: { d in
                    let a = rnd(10...40)
                    let x = rnd(1...8)
                    let y = rnd(1...8)
                    var nums = [a + x, a + y, a - x, a - y]
                    if d == .medium { nums.append(a) }
                    nums.shuffle()
                    let count = nums.count
                    let sum = nums.reduce(0, +)
                    if d == .hard {
                        let three = Array(nums.prefix(3))
                        let s3 = three.reduce(0, +)
                        let missing = 4 * a - s3
                        return .int(
                            "متوسط 4 أعداد يساوي \(a). إذا كانت ثلاثة منها \(list(three))، فما العدد الرابع؟",
                            steps: ["مجموع الأعداد الأربعة = المتوسط × العدد: " + m("\(a) × 4 = \(4 * a)"),
                                    "مجموع الثلاثة المعلومة: " + m("\(s3)"),
                                    "العدد الرابع: " + m("\(4 * a) − \(s3) = \(missing)")],
                            value: missing, traps: [a, 3 * a - s3, missing + 4])
                    }
                    return .int(
                        "ما المتوسط الحسابي للأعداد: \(list(nums))؟",
                        steps: ["نجمع الأعداد: " + m("\(sum)"),
                                "نقسم على عددها (\(count)): " + m("\(sum) ÷ \(count) = \(a)")],
                        value: a)
                    .withTraps([Double(sum) / Double(count - 1), Double(sum) / Double(count + 1), Double(a + 1)])
                }),
            Formula(
                id: "ratio_split", topic: .ratios, title: "تقسيم كمية بنسبة معيّنة",
                expression: "قيمة الجزء الواحد = الكمية ÷ مجموع أجزاء النسبة",
                explanation: "اجمع أجزاء النسبة، اقسم الكمية عليها لتحصل على قيمة الجزء الواحد، ثم اضرب في نصيب كل طرف.",
                trap: "القسمة على أحد حدّي النسبة بدل مجموعهما.",
                gen: { d in
                    if d == .hard {
                        let parts = pick([[2, 3, 5], [1, 2, 3], [3, 4, 5], [2, 3, 4], [1, 3, 4]])
                        let k = rnd(5...12)
                        let sumParts = parts.reduce(0, +)
                        let total = sumParts * k
                        let which = rnd(0...2)
                        let names = ["الأول", "الثاني", "الثالث"]
                        let share = parts[which] * k
                        let ratio = m(parts.map { String($0) }.joined(separator: " : "))
                        return .int(
                            "وُزّع مبلغ \(total) دينار على ثلاثة أشخاص بنسبة \(ratio). كم نصيب \(names[which])؟",
                            steps: ["مجموع أجزاء النسبة: " + m(parts.map { String($0) }.joined(separator: " + ") + " = \(sumParts)"),
                                    "قيمة الجزء الواحد: " + m("\(total) ÷ \(sumParts) = \(k)"),
                                    "نصيب \(names[which]): " + m("\(parts[which]) × \(k) = \(share)")],
                            value: share, unit: " دينار",
                            traps: [parts[(which + 1) % 3] * k, k, total / 3])
                    }
                    let pr = d == .easy ? pick([(1, 2), (1, 3), (2, 3)]) : pick([(2, 3), (3, 5), (2, 5), (3, 7), (4, 5)])
                    let k = d == .easy ? rnd(4...10) : rnd(5...15)
                    let total = (pr.0 + pr.1) * k
                    let askBig = Bool.random()
                    let big = max(pr.0, pr.1)
                    let small = min(pr.0, pr.1)
                    let mult = askBig ? big : small
                    let other = askBig ? small : big
                    let part = mult * k
                    let word = askBig ? "الأكبر" : "الأصغر"
                    let sumParts = pr.0 + pr.1
                    return .int(
                        "قُسّم مبلغ \(total) دينار بين شخصين بنسبة \(m("\(pr.0) : \(pr.1)")). ما نصيب صاحب النصيب \(word)؟",
                        steps: ["مجموع أجزاء النسبة: " + m("\(pr.0) + \(pr.1) = \(sumParts)"),
                                "قيمة الجزء الواحد: " + m("\(total) ÷ \(sumParts) = \(k)"),
                                "النصيب = عدد أجزائه × قيمة الجزء: " + m("\(mult) × \(k) = \(part)")],
                        value: part, unit: " دينار")
                    .withTraps([Double(other * k), Double(k), Double(total) / Double(mult)])
                })
        ]
    }
}

extension Example {
    /// يضيف قيماً خاطئة (تُهمل القيم غير النظيفة أو المساوية للإجابة لاحقاً).
    func withTraps(_ values: [Double]) -> Example {
        var e = self
        e.trapValues += values
        return e
    }
}
