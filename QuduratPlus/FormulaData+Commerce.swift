import Foundation

extension FormulaData {

    // MARK: - الحساب التطبيقي (التناسب المركب، الربح، الفائدة، الخلط، المتوسط المرجّح)

    static func commerce() -> [Formula] {
        return [
            Formula(
                id: "compound_prop", topic: .ratios, title: "التناسب العكسي والمركّب",
                expression: "العمال × الأيام × الساعات ÷ كمية العمل = ثابت",
                explanation: "إذا زاد عدد العمال قلّت الأيام (تناسب عكسي)، وإذا زاد العمل المطلوب زادت الأيام (تناسب طردي). اضرب الكميات العكسية في بعضها، واحسب المجهول بحيث يبقى الثابت كما هو.",
                trap: "معاملة العلاقة العكسية كأنها طردية: عمال أكثر لا تعني أياماً أكثر.",
                gen: { d in
                    switch d {
                    case .easy:
                        var w1 = 0, d1 = 0, w2 = 0
                        repeat {
                            w1 = pick([4, 6, 8, 10, 12])
                            d1 = pick([5, 6, 8, 10, 12, 15])
                            w2 = pick([2, 3, 4, 5, 6, 8, 10, 12, 15, 20])
                        } while w2 == w1 || (w1 * d1) % w2 != 0
                        let d2 = w1 * d1 / w2
                        return .int(
                            "ينجز \(w1) عمال عملاً في \(d1) أيام. كم يوماً يحتاج \(w2) عمال لإنجاز العمل نفسه؟",
                            steps: ["العلاقة عكسية: العمال × الأيام ثابت = " + m("\(w1) × \(d1) = \(w1 * d1)"),
                                    "الأيام الجديدة: " + m("\(w1 * d1) ÷ \(w2) = \(d2)")],
                            value: d2, unit: " أيام")
                        .withTraps([Double(d1 * w2) / Double(w1), Double(w1 * d1), Double(d1 + w1 - w2)])
                    case .medium:
                        var w1 = 0, d1 = 0, h1 = 0, w2 = 0, h2 = 0
                        repeat {
                            w1 = pick([4, 5, 6, 8, 10])
                            d1 = pick([6, 8, 10, 12])
                            h1 = pick([6, 8, 10])
                            w2 = pick([2, 3, 4, 5, 6, 8, 10, 12])
                            h2 = pick([4, 5, 6, 8, 10, 12])
                        } while (w2 == w1 && h2 == h1) || (w1 * d1 * h1) % (w2 * h2) != 0
                        let total = w1 * d1 * h1
                        let d2 = total / (w2 * h2)
                        return .int(
                            "يعمل \(w1) عمال \(h1) ساعات يومياً فينجزون عملاً في \(d1) أيام. كم يوماً يحتاج \(w2) عمال يعملون \(h2) ساعات يومياً لإنجاز العمل نفسه؟",
                            steps: ["ساعات العمل الكلية ثابتة: " + m("\(w1) × \(d1) × \(h1) = \(total)"),
                                    "الأيام الجديدة: " + m("\(total) ÷ (\(w2) × \(h2)) = \(d2)")],
                            value: d2, unit: " أيام")
                        .withTraps([Double(d1 * w2 * h2) / Double(w1 * h1), Double(total) / Double(w2), Double(d2 + 2)])
                    case .hard:
                        var w1 = 0, j1 = 0, d1 = 0, w2 = 0, j2 = 0
                        repeat {
                            w1 = pick([3, 4, 5, 6, 8])
                            j1 = pick([2, 3, 4, 6])
                            d1 = pick([4, 6, 8, 9, 10, 12])
                            w2 = pick([2, 4, 6, 9, 10, 12])
                            j2 = pick([3, 4, 5, 6, 8, 9])
                        } while w2 == w1 || j2 == j1 || (d1 * w1 * j2) % (w2 * j1) != 0
                        let d2 = d1 * w1 * j2 / (w2 * j1)
                        return .int(
                            "يبني \(w1) عمال \(j1) جدران في \(d1) أيام. كم يوماً يحتاج \(w2) عمال لبناء \(j2) جدران بالمعدل نفسه؟",
                            steps: ["أيام عمل عامل واحد لجدار واحد: " + m("\(w1) × \(d1) ÷ \(j1)"),
                                    "العمال عكسي والجدران طردي: " + m("\(d1) × (\(w1) ÷ \(w2)) × (\(j2) ÷ \(j1))"),
                                    "الناتج: " + m("\(d1 * w1 * j2) ÷ \(w2 * j1) = \(d2)")],
                            value: d2, unit: " أيام")
                        .withTraps([Double(d1 * w2 * j2) / Double(w1 * j1), Double(d1 * w1 * j1) / Double(w2 * j2), Double(d1)])
                    }
                }),
            Formula(
                id: "profit_loss", topic: .ratios, title: "الربح والخسارة",
                expression: "نسبة الربح = (سعر البيع − التكلفة) ÷ التكلفة × 100",
                explanation: "الربح والخسارة يُحسبان دائماً من سعر التكلفة (الشراء). سعر البيع بربح ن% = التكلفة × (1 + ن%)، وبخسارة ن% = التكلفة × (1 − ن%).",
                trap: "حساب النسبة من سعر البيع بدل التكلفة.",
                gen: { d in
                    switch d {
                    case .easy:
                        var cost = 0, p = 0
                        repeat {
                            cost = pick([100, 200, 250, 400, 500, 800])
                            p = pick([10, 20, 25, 50])
                        } while (cost * p) % 100 != 0
                        let profit = cost * p / 100
                        let sale = cost + profit
                        return .int(
                            "اشترى تاجر سلعة بـ \(cost) دينار وباعها بربح \(p)%. بكم باعها؟",
                            steps: ["مقدار الربح: " + m("\(cost) × \(p)% = \(profit)"),
                                    "سعر البيع: " + m("\(cost) + \(profit) = \(sale)")],
                            value: sale, unit: " دينار", traps: [cost + p, profit, cost - profit])
                    case .medium:
                        var cost = 0, pc = 0
                        repeat {
                            cost = pick([80, 100, 120, 150, 200, 250, 400])
                            pc = pick([5, 10, 15, 20, 25, 30, 40])
                        } while (cost * pc) % 100 != 0
                        let gain = Bool.random()
                        let diff = cost * pc / 100
                        let sale = gain ? cost + diff : cost - diff
                        let word = gain ? "الربح" : "الخسارة"
                        return .int(
                            "اشترى \(nm()) جهازاً بـ \(cost) دينار وباعه بـ \(sale) دينار. ما نسبة \(word)؟",
                            steps: ["مقدار \(word): " + m("|\(sale) − \(cost)| = \(diff)"),
                                    "النسبة من التكلفة: " + m("\(diff) ÷ \(cost) × 100 = \(pc)%")],
                            value: pc, unit: "%")
                        .withTraps([Double(diff) * 100 / Double(sale), Double(diff), Double(100 - pc)])
                    case .hard:
                        var cost = 0, p = 0
                        let gain = Bool.random()
                        repeat {
                            cost = pick([80, 120, 160, 200, 240, 300, 400, 500])
                            p = pick([10, 20, 25, 50])
                        } while (cost * p) % 100 != 0
                        let sale = gain ? cost * (100 + p) / 100 : cost * (100 - p) / 100
                        let rate = gain ? 100 + p : 100 - p
                        return .int(
                            "باع تاجر سلعة بـ \(sale) دينار " + (gain ? "فربح" : "فخسر") + " \(p)% من التكلفة. كم كانت تكلفتها؟",
                            steps: ["سعر البيع يساوي " + m("\(rate)%") + " من التكلفة",
                                    "التكلفة: " + m("\(sale) × 100 ÷ \(rate) = \(cost)")],
                            value: cost, unit: " دينار")
                        .withTraps([Double(sale) * Double(gain ? 100 - p : 100 + p) / 100, Double(gain ? sale - p : sale + p), Double(sale)])
                    }
                }),
            Formula(
                id: "simple_interest", topic: .ratios, title: "الفائدة البسيطة",
                expression: "الفائدة = المبلغ × النسبة السنوية × عدد السنوات",
                explanation: "الفائدة البسيطة تُحسب كل سنة على المبلغ الأصلي فقط. والمبلغ الكلي في النهاية = المبلغ الأصلي + الفائدة.",
                trap: "نسيان الضرب في عدد السنوات، أو الخلط بين الفائدة والمبلغ الكلي.",
                gen: { d in
                    let principal = pick([1000, 2000, 4000, 5000, 10000])
                    let r = pick([2, 3, 4, 5, 10])
                    let t = rnd(2...5)
                    let interest = principal * r * t / 100
                    switch d {
                    case .easy:
                        return .int(
                            "أودع \(nm()) \(principal) دينار بفائدة بسيطة \(r)% سنوياً. كم الفائدة بعد \(t) سنوات؟",
                            steps: ["الفائدة السنوية: " + m("\(principal) × \(r)% = \(principal * r / 100)"),
                                    "لعدد السنوات: " + m("\(principal * r / 100) × \(t) = \(interest)")],
                            value: interest, unit: " دينار", traps: [principal * r / 100, principal + interest, interest * 10])
                    case .medium:
                        return .int(
                            "أودع \(nm()) \(principal) دينار بفائدة بسيطة \(r)% سنوياً. كم يصبح المبلغ كله بعد \(t) سنوات؟",
                            steps: ["الفائدة: " + m("\(principal) × \(r)% × \(t) = \(interest)"),
                                    "المبلغ الكلي: " + m("\(principal) + \(interest) = \(principal + interest)")],
                            value: principal + interest, unit: " دينار", traps: [interest, principal + principal * r / 100, principal + interest * 2])
                    case .hard:
                        return .int(
                            "أودع \(nm()) \(principal) دينار بفائدة بسيطة، فحصل على فائدة \(interest) دينار بعد \(t) سنوات. ما النسبة السنوية؟",
                            steps: ["الفائدة السنوية: " + m("\(interest) ÷ \(t) = \(interest / t)"),
                                    "النسبة: " + m("\(interest / t) ÷ \(principal) × 100 = \(r)%")],
                            value: r, unit: "%", traps: [r * t, interest * 100 / principal, r + 1])
                    }
                }),
            Formula(
                id: "mixtures", topic: .ratios, title: "الخلط والمحاليل",
                expression: "كمية المادة = الكمية الكلية × التركيز",
                explanation: "احسب كمية المادة النقية (ملح، سكر، عصير) في كل خليط، ثم اجمعها واقسمها على الكمية الكلية الجديدة. إضافة الماء تزيد الكمية الكلية ولا تغيّر كمية المادة.",
                trap: "أخذ متوسط التركيزين مباشرة رغم اختلاف الكميات، أو نسيان أن الماء المضاف يزيد الكمية الكلية.",
                gen: { d in
                    switch d {
                    case .easy:
                        var vol = 0, c = 0
                        repeat {
                            vol = pick([20, 40, 50, 60, 80, 100, 200])
                            c = pick([5, 10, 15, 20, 25, 30, 40])
                        } while (vol * c) % 100 != 0
                        let salt = vol * c / 100
                        return .int(
                            "محلول ملحي حجمه \(vol) لتراً وتركيز الملح فيه \(c)%. كم لتراً من الملح فيه؟",
                            steps: ["كمية الملح = الحجم × التركيز: " + m("\(vol) × \(c)% = \(salt)")],
                            value: salt, unit: " لتر", traps: [vol - salt, c, vol * c / 10])
                    case .medium:
                        var vol = 0, c = 0, water = 0
                        repeat {
                            vol = pick([20, 30, 40, 50, 60, 80])
                            c = pick([10, 20, 25, 30, 40, 50])
                            water = pick([10, 20, 30, 40])
                        } while (vol * c) % 100 != 0 || (vol * c) % (vol + water) != 0
                        let salt = vol * c / 100
                        let nc = vol * c / (vol + water)
                        return .int(
                            "محلول حجمه \(vol) لتراً تركيز السكر فيه \(c)%، أُضيف إليه \(water) لتراً من الماء. ما تركيز السكر الجديد؟",
                            steps: ["كمية السكر لا تتغير: " + m("\(vol) × \(c)% = \(salt)"),
                                    "الحجم الجديد: " + m("\(vol) + \(water) = \(vol + water)"),
                                    "التركيز الجديد: " + m("\(salt) ÷ \(vol + water) × 100 = \(nc)%")],
                            value: nc, unit: "%", traps: [c, c - water, c / 2])
                    case .hard:
                        var v1 = 0, c1 = 0, v2 = 0, c2 = 0
                        repeat {
                            v1 = pick([10, 20, 30, 40])
                            v2 = pick([10, 20, 30, 40, 60])
                            c1 = pick([10, 20, 30, 40, 50])
                            c2 = pick([20, 30, 50, 60, 80])
                        } while v1 == v2 || c1 == c2 || (v1 * c1 + v2 * c2) % (v1 + v2) != 0
                        let s1 = v1 * c1, s2 = v2 * c2
                        let mix = (s1 + s2) / (v1 + v2)
                        return .int(
                            "خُلط \(v1) لتراً من عصير تركيزه \(c1)% مع \(v2) لتراً من عصير تركيزه \(c2)%. ما تركيز الخليط؟",
                            steps: ["كمية العصير النقي: " + m("\(v1) × \(c1)% + \(v2) × \(c2)% = \(fmt(Double(s1) / 100)) + \(fmt(Double(s2) / 100)) = \(fmt(Double(s1 + s2) / 100))"),
                                    "الكمية الكلية: " + m("\(v1) + \(v2) = \(v1 + v2)"),
                                    "التركيز: " + m("\(fmt(Double(s1 + s2) / 100)) ÷ \(v1 + v2) × 100 = \(mix)%")],
                            value: mix, unit: "%")
                        .withTraps([Double(c1 + c2) / 2, Double(c1 + c2), Double(max(c1, c2))])
                    }
                }),
            Formula(
                id: "weighted_avg", topic: .ratios, title: "المتوسط المرجّح (متوسط مجموعتين)",
                expression: "المتوسط العام = (ن١ × م١ + ن٢ × م٢) ÷ (ن١ + ن٢)",
                explanation: "عند دمج مجموعتين مختلفتين في العدد، اضرب متوسط كل مجموعة في عددها لتحصل على مجموعها، ثم اقسم المجموع الكلي على العدد الكلي.",
                trap: "أخذ متوسط المتوسطين مباشرة (م١ + م٢) ÷ 2 رغم اختلاف عدد المجموعتين.",
                gen: { d in
                    switch d {
                    case .easy, .medium:
                        var n1 = 0, m1 = 0, n2 = 0, m2 = 0
                        repeat {
                            n1 = d == .easy ? pick([10, 20]) : pick([10, 15, 20, 25, 30])
                            n2 = d == .easy ? pick([10, 20, 30]) : pick([10, 15, 20, 30, 40])
                            m1 = pick([60, 70, 75, 80, 85, 90])
                            m2 = pick([60, 65, 70, 80, 90, 95])
                        } while n1 == n2 || m1 == m2 || (n1 * m1 + n2 * m2) % (n1 + n2) != 0
                        let total = n1 * m1 + n2 * m2
                        let avg = total / (n1 + n2)
                        return .int(
                            "فصل فيه \(n1) طالباً متوسط درجاتهم \(m1)، وفصل آخر فيه \(n2) طالباً متوسط درجاتهم \(m2). ما متوسط درجات الفصلين معاً؟",
                            steps: ["مجموع درجات الفصلين: " + m("\(n1) × \(m1) + \(n2) × \(m2) = \(total)"),
                                    "العدد الكلي: " + m("\(n1) + \(n2) = \(n1 + n2)"),
                                    "المتوسط العام: " + m("\(total) ÷ \(n1 + n2) = \(avg)")],
                            value: avg)
                        .withTraps([Double(m1 + m2) / 2, Double(avg + 2), Double(max(m1, m2))])
                    case .hard:
                        var n1 = 0, m1 = 0, n2 = 0, avg = 0
                        repeat {
                            n1 = pick([10, 15, 20, 30])
                            n2 = pick([10, 20, 25, 30])
                            m1 = pick([60, 70, 80, 90])
                            avg = pick([65, 70, 72, 75, 78, 80, 84])
                        } while (avg * (n1 + n2) - n1 * m1) % n2 != 0 || avg == m1
                            || (avg * (n1 + n2) - n1 * m1) / n2 < 40 || (avg * (n1 + n2) - n1 * m1) / n2 > 100
                        let m2 = (avg * (n1 + n2) - n1 * m1) / n2
                        return .int(
                            "متوسط درجات \(n1 + n2) طالباً هو \(avg). إذا كان متوسط \(n1) منهم \(m1)، فما متوسط الباقين؟",
                            steps: ["المجموع الكلي: " + m("\(avg) × \(n1 + n2) = \(avg * (n1 + n2))"),
                                    "مجموع المجموعة الأولى: " + m("\(m1) × \(n1) = \(m1 * n1)"),
                                    "مجموع الباقين: " + m("\(avg * (n1 + n2)) − \(m1 * n1) = \(m2 * n2)"),
                                    "متوسطهم: " + m("\(m2 * n2) ÷ \(n2) = \(m2)")],
                            value: m2, traps: [2 * avg - m1, avg, m2 + 5])
                    }
                })
        ]
    }
}
