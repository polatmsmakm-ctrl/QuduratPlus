import Foundation

extension FormulaData {

    // MARK: - المتتابعات

    static func sequences() -> [Formula] {
        return [
            Formula(
                id: "arith_nth", topic: .sequences, title: "المتتابعة الحسابية (الحد النوني)",
                expression: "حن = ح١ + (ن − 1) × د",
                explanation: "المتتابعة الحسابية يزيد (أو ينقص) كل حد عن الذي قبله بمقدار ثابت د (الأساس). ح١ هو الحد الأول ون رقم الحد المطلوب. وإذا عرفت حدّين: د = فرق الحدّين ÷ فرق رتبتيهما.",
                trap: "استعمال ن بدل (ن − 1). الحد الأول لا يُضاف إليه شيء.",
                gen: { d in
                    switch d {
                    case .easy:
                        let a1 = rnd(2...10), dd = rnd(2...7), n = rnd(8...15)
                        let an = a1 + (n - 1) * dd
                        return .int(
                            "متتابعة حسابية حدها الأول \(a1) وأساسها \(dd). ما قيمة الحد رقم \(n)؟",
                            steps: ["نطبّق القانون: " + m("\(a1) + (\(n) − 1) × \(dd) = \(an)")],
                            value: an, traps: [a1 + n * dd, a1 + (n - 2) * dd, (n - 1) * dd])
                    case .medium:
                        var a1 = 0, dd = 0, n = 0
                        repeat {
                            a1 = rnd(50...100)
                            dd = rnd(2...6)
                            n = rnd(5...12)
                        } while a1 - (n - 1) * dd <= 0
                        let an = a1 - (n - 1) * dd
                        return .int(
                            "متتابعة حسابية تبدأ بـ \(a1) وتنقص \(dd) في كل حد: " + list([a1, a1 - dd, a1 - 2 * dd]) + " … ما الحد رقم \(n)؟",
                            steps: ["الأساس سالب: " + m("د = −\(dd)"),
                                    "نطبّق القانون: " + m("\(a1) + (\(n) − 1) × (−\(dd)) = \(a1) − \((n - 1) * dd) = \(an)")],
                            value: an, traps: [a1 - n * dd, a1 + (n - 1) * dd, (n - 1) * dd])
                    case .hard:
                        let a1 = rnd(2...20), dd = rnd(2...9)
                        let p = rnd(2...5)
                        let q = p + rnd(3...8)
                        let n = rnd(15...30)
                        let ap = a1 + (p - 1) * dd, aq = a1 + (q - 1) * dd
                        let an = a1 + (n - 1) * dd
                        return .int(
                            "متتابعة حسابية حدها رقم \(p) يساوي \(ap) وحدها رقم \(q) يساوي \(aq). ما الحد رقم \(n)؟",
                            steps: ["الأساس: " + m("د = (\(aq) − \(ap)) ÷ (\(q) − \(p)) = \(aq - ap) ÷ \(q - p) = \(dd)"),
                                    "الحد الأول: " + m("ح١ = \(ap) − (\(p) − 1) × \(dd) = \(a1)"),
                                    "الحد المطلوب: " + m("\(a1) + (\(n) − 1) × \(dd) = \(an)")],
                            value: an, traps: [a1 + n * dd, ap + (n - 1) * dd, an - dd])
                    }
                }),
            Formula(
                id: "arith_sum", topic: .sequences, title: "مجموع المتتابعة الحسابية",
                expression: "المجموع = (ن ÷ 2) × (ح١ + حن)",
                explanation: "مجموع الحد الأول والأخير = مجموع الثاني والذي قبل الأخير... فنضرب هذا المجموع في نصف عدد الحدود (طريقة غاوس). ومجموع الأعداد من 1 إلى ن = ن(ن + 1) ÷ 2.",
                trap: "نسيان حساب الحد الأخير أولاً، أو نسيان القسمة على 2، أو الخطأ في عدّ الحدود.",
                gen: { d in
                    switch d {
                    case .easy:
                        let n = pick([10, 20, 30, 40, 50, 100])
                        let sum = n * (n + 1) / 2
                        return .int(
                            "ما مجموع الأعداد الصحيحة من 1 إلى \(n)؟",
                            steps: ["نطبّق: " + m("\(n) × (\(n) + 1) ÷ 2 = \(n) × \(n + 1) ÷ 2 = \(sum)")],
                            value: sum, traps: [n * (n + 1), n * n / 2, n * (n - 1) / 2])
                    case .medium:
                        let a1 = rnd(1...8), dd = rnd(1...5)
                        let n = pick([12, 15, 20, 25, 30])
                        let an = a1 + (n - 1) * dd
                        let sum = n * (a1 + an) / 2
                        return .int(
                            "ما مجموع أول \(n) حداً من المتتابعة الحسابية التي حدها الأول \(a1) وأساسها \(dd)؟",
                            steps: ["الحد الأخير: " + m("\(a1) + (\(n) − 1) × \(dd) = \(an)"),
                                    "المجموع: " + m("\(n) ÷ 2 × (\(a1) + \(an)) = \(sum)")],
                            value: sum, traps: [n * (a1 + an), a1 + an, sum + an])
                    case .hard:
                        let k = pick([3, 4, 5, 6, 7])
                        let count = rnd(10...30)
                        let last = k * count
                        let sum = count * (k + last) / 2
                        return .int(
                            "ما مجموع مضاعفات العدد \(k) من \(k) إلى \(last)؟",
                            steps: ["عدد الحدود: " + m("\(last) ÷ \(k) = \(count)"),
                                    "المجموع: " + m("\(count) ÷ 2 × (\(k) + \(last)) = \(sum)")],
                            value: sum, traps: [count * (k + last), last * (last + 1) / 2, sum - last])
                    }
                }),
            Formula(
                id: "geo_nth", topic: .sequences, title: "المتتابعة الهندسية (الحد النوني)",
                expression: "حن = ح١ × ر^(ن − 1)",
                explanation: "في المتتابعة الهندسية يُضرب كل حد في عدد ثابت ر (الأساس) للحصول على الحد التالي. وإذا كان الأساس ½ فكل حد نصف الذي قبله.",
                trap: "الخلط بين الأساس في الحسابية (جمع) والهندسية (ضرب)، ونسيان أن الأس هو (ن − 1).",
                gen: { d in
                    if d == .hard {
                        let a1 = pick([64, 96, 128, 160, 192, 320])
                        let n = rnd(3...5)
                        let div = ipow(2, n - 1)
                        let an = a1 / div
                        return .int(
                            "متتابعة هندسية حدها الأول \(a1) وكل حد فيها نصف الحد الذي قبله. ما قيمة الحد رقم \(n)؟",
                            steps: ["الأساس " + m("ر = ½"),
                                    "نطبّق القانون: " + m("\(a1) × (½)^(\(n) − 1) = \(a1) ÷ \(div) = \(an)")],
                            value: an)
                        .withTraps([Double(a1) / Double(div * 2), Double(an * 2), Double(a1) / Double(2 * (n - 1))])
                    }
                    let a1 = lv(d, pick([1, 2, 3]), pick([1, 2, 3, 5]), 1)
                    let r = d == .easy ? 2 : pick([2, 3])
                    let n = d == .easy ? rnd(4...6) : rnd(4...7)
                    let an = a1 * ipow(r, n - 1)
                    return .int(
                        "متتابعة هندسية حدها الأول \(a1) وأساسها \(r). ما قيمة الحد رقم \(n)؟",
                        steps: ["نطبّق القانون: " + m("\(a1) × \(r)^(\(n) − 1) = \(a1) × \(ipow(r, n - 1)) = \(an)")],
                        value: an, traps: [a1 * ipow(r, n), a1 + (n - 1) * r, an / r])
                })
        ]
    }

    // MARK: - الأعداد

    static func numbers() -> [Formula] {
        return [
            Formula(
                id: "gcd_lcm", topic: .numbers, title: "ق.م.أ و م.م.أ",
                expression: "ق.م.أ × م.م.أ = حاصل ضرب العددين",
                explanation: "ق.م.أ هو أكبر عدد يقسم العددين، وم.م.أ هو أصغر عدد يقبل القسمة عليهما. العلاقة بينهما مفيدة لإيجاد أحدهما إذا عرفت الآخر.",
                trap: "الخلط بينهما: ق.م.أ لا يكون أكبر من أصغر العددين، وم.م.أ لا يكون أصغر من أكبرهما.",
                gen: { d in
                    switch d {
                    case .easy:
                        let pr = pick([(12, 18), (8, 12), (15, 25), (14, 21), (16, 24), (20, 30), (9, 12), (18, 24)])
                        let g = gcd(pr.0, pr.1)
                        return .int(
                            "ما القاسم المشترك الأكبر (ق.م.أ) للعددين \(pr.0) و\(pr.1)؟",
                            steps: ["قواسم \(pr.0) المشتركة مع قواسم \(pr.1)، وأكبرها \(g)",
                                    "تحقق: " + m("\(pr.0) ÷ \(g) = \(pr.0 / g)") + " و" + m("\(pr.1) ÷ \(g) = \(pr.1 / g)")],
                            value: g, traps: [pr.0 * pr.1 / g, pr.0, g / 2 > 1 ? g / 2 : g * 2])
                    case .medium:
                        let pr = pick([(4, 6), (6, 8), (9, 12), (10, 15), (8, 12), (12, 18), (6, 10), (15, 20)])
                        let g = gcd(pr.0, pr.1)
                        let l = pr.0 * pr.1 / g
                        return .int(
                            "ما المضاعف المشترك الأصغر (م.م.أ) للعددين \(pr.0) و\(pr.1)؟",
                            steps: ["ق.م.أ للعددين \(g)",
                                    "م.م.أ = حاصل الضرب ÷ ق.م.أ: " + m("\(pr.0) × \(pr.1) ÷ \(g) = \(l)")],
                            value: l, traps: [pr.0 * pr.1, g, pr.1])
                    case .hard:
                        let pr = pick([(12, 18), (8, 12), (6, 15), (20, 30), (9, 12), (14, 21), (16, 24), (10, 25)])
                        let g = gcd(pr.0, pr.1)
                        let prod = pr.0 * pr.1
                        let l = prod / g
                        return .int(
                            "عددان حاصل ضربهما \(prod) والقاسم المشترك الأكبر لهما \(g). ما المضاعف المشترك الأصغر لهما؟",
                            steps: ["نستعمل العلاقة: " + m("\(g) × م.م.أ = \(prod)"),
                                    "نقسم: " + m("م.م.أ = \(prod) ÷ \(g) = \(l)")],
                            value: l, traps: [prod, prod - g, prod / (g * g)])
                    }
                }),
            Formula(
                id: "divisibility", topic: .numbers, title: "قواعد القسمة",
                expression: "القسمة على 3 أو 9: مجموع الأرقام يقبل القسمة على 3 أو 9",
                explanation: "على 2: آخر رقم زوجي. على 5: ينتهي بـ 0 أو 5. على 10: ينتهي بـ 0. على 4: آخر رقمين يقبلان القسمة على 4. على 3 أو 9: مجموع الأرقام يقبل القسمة عليه. على 6: يقبل القسمة على 2 وعلى 3 معاً.",
                trap: "القول إن العدد يقبل القسمة على 9 لأن مجموع أرقامه يقبل القسمة على 3 فقط. لازم المجموع يقبل القسمة على 9.",
                gen: { d in
                    var divisor = 3
                    var n = 0
                    var others: [Int] = []
                    switch d {
                    case .easy:
                        divisor = 3
                        n = 3 * rnd(34...333)
                        others = [n + 1, n + 2, n + 4]
                    case .medium:
                        divisor = 9
                        n = 9 * rnd(112...1111)
                        others = [n + 3, n + 6, n - 3]
                    case .hard:
                        if Bool.random() {
                            divisor = 6
                            n = 6 * rnd(20...160)
                            others = [n + 3, n + 2, n + 4]
                        } else {
                            divisor = 4
                            let tail = 4 * rnd(3...22)
                            let head = rnd(10...99)
                            n = head * 100 + tail
                            others = [n + 2, n - 2, n + 1]
                        }
                    }
                    let all = ([n] + others).sorted()
                    var steps: [String] = []
                    switch divisor {
                    case 4:
                        steps.append("نختبر آخر رقمين من كل عدد: هل يقبلان القسمة على 4؟")
                        for x in all {
                            let t = x % 100
                            steps.append(m("\(x)") + ": آخر رقمين \(t) " + (t % 4 == 0 ? "← يقبل ✓" : "← لا يقبل"))
                        }
                    case 6:
                        steps.append("يقبل القسمة على 6 إذا كان زوجياً ومجموع أرقامه يقبل القسمة على 3")
                        for x in all {
                            let s = digitSum(x)
                            let ok = x % 2 == 0 && s % 3 == 0
                            let parity = x % 2 == 0 ? "زوجي" : "فردي"
                            steps.append(m("\(x)") + ": \(parity)، ومجموع أرقامه \(s) " + (ok ? "← يقبل ✓" : "← لا يقبل"))
                        }
                    default:
                        steps.append("نجمع أرقام كل عدد ونختبر المجموع على \(divisor)")
                        for x in all {
                            let s = digitSum(x)
                            steps.append(m("\(x)") + ": مجموع أرقامه \(s) " + (s % divisor == 0 ? "← يقبل ✓" : "← لا يقبل"))
                        }
                    }
                    var e = Example.int(
                        "أيّ الأعداد التالية يقبل القسمة على \(divisor)؟\n" + list(all),
                        steps: steps, value: n)
                    e.fixedOptions = all.map { String($0) }
                    return e
                })
        ]
    }
}

/// مجموع أرقام العدد.
func digitSum(_ n: Int) -> Int {
    String(abs(n)).compactMap { Int(String($0)) }.reduce(0, +)
}
