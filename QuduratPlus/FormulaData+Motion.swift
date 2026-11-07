import Foundation

extension FormulaData {

    // MARK: - السرعة والزمن والعمل

    static func motion() -> [Formula] {
        return [
            Formula(
                id: "speed", topic: .motion, title: "السرعة والمسافة والزمن",
                expression: "المسافة = السرعة × الزمن",
                explanation: "ومنها: السرعة = المسافة ÷ الزمن، والزمن = المسافة ÷ السرعة. وحّد الوحدات (كم مع ساعة، ومتر مع ثانية)، وحوّل الدقائق إلى ساعات بالقسمة على 60. متوسط السرعة = المسافة الكلية ÷ الزمن الكلي.",
                trap: "عدم توحيد الوحدات، مثل دقائق مع كم/ساعة. وأخذ متوسط السرعتين بدل قسمة المسافة الكلية على الزمن الكلي.",
                gen: { d in
                    switch d {
                    case .easy:
                        let s = pick([40, 50, 60, 80, 90, 100, 120])
                        let t = rnd(2...8)
                        let dist = s * t
                        let kind = rnd(0...2)
                        if kind == 0 {
                            return .int(
                                "سيارة تسير بسرعة \(s) كم/ساعة لمدة \(t) ساعات. ما المسافة التي تقطعها؟",
                                steps: ["المسافة = السرعة × الزمن: " + m("\(s) × \(t) = \(dist)")],
                                value: dist, unit: " كم", traps: [s + t, dist + s, dist / 2])
                        } else if kind == 1 {
                            return .int(
                                "قطعت سيارة \(dist) كم في \(t) ساعات. ما سرعتها بالكم/ساعة؟",
                                steps: ["السرعة = المسافة ÷ الزمن: " + m("\(dist) ÷ \(t) = \(s)")],
                                value: s, unit: " كم/ساعة", traps: [dist * t, dist - t, s + 10])
                        }
                        return .int(
                            "تسير سيارة بسرعة \(s) كم/ساعة. كم ساعة تحتاج لقطع \(dist) كم؟",
                            steps: ["الزمن = المسافة ÷ السرعة: " + m("\(dist) ÷ \(s) = \(t)")],
                            value: t, unit: " ساعات", traps: [t + 1, t * 2, t + 2])
                    case .medium:
                        var s = 0, mins = 0
                        repeat {
                            s = pick([40, 60, 80, 90, 100, 120])
                            mins = pick([15, 30, 45, 90])
                        } while (s * mins) % 60 != 0
                        let dist = s * mins / 60
                        return .int(
                            "سيارة تسير بسرعة \(s) كم/ساعة. كم كيلومتراً تقطع في \(mins) دقيقة؟",
                            steps: ["نحوّل الزمن إلى ساعات: " + m("\(mins) ÷ 60 = \(fmt(Double(mins) / 60))") + " ساعة",
                                    "المسافة: " + m("\(s) × \(fmt(Double(mins) / 60)) = \(dist)")],
                            value: dist, unit: " كم")
                        .withTraps([Double(s * mins), Double(s * mins) / 100, Double(dist * 2)])
                    case .hard:
                        var s1 = 0, t1 = 0, s2 = 0, t2 = 0
                        repeat {
                            s1 = pick([40, 50, 60, 80, 90])
                            s2 = pick([60, 80, 100, 120])
                            t1 = rnd(1...4)
                            t2 = rnd(1...4)
                        } while s1 == s2 || (s1 * t1 + s2 * t2) % (t1 + t2) != 0 || t1 == t2
                        let total = s1 * t1 + s2 * t2
                        let avg = total / (t1 + t2)
                        return .int(
                            "سار \(nm()) \(t1) ساعات بسرعة \(s1) كم/ساعة، ثم \(t2) ساعات بسرعة \(s2) كم/ساعة. ما متوسط سرعته في الرحلة كلها؟",
                            steps: ["المسافة الكلية: " + m("\(s1) × \(t1) + \(s2) × \(t2) = \(total)"),
                                    "الزمن الكلي: " + m("\(t1) + \(t2) = \(t1 + t2)"),
                                    "المتوسط: " + m("\(total) ÷ \(t1 + t2) = \(avg)")],
                            value: avg, unit: " كم/ساعة")
                        .withTraps([Double(s1 + s2) / 2, Double(s1 + s2), Double(total) / Double(max(t1, t2))])
                    }
                }),
            Formula(
                id: "avg_round", topic: .motion, title: "متوسط السرعة (ذهاب وإياب)",
                expression: "متوسط السرعة = (2 × أ × ب) ÷ (أ + ب)",
                explanation: "عندما تكون المسافة نفسها بسرعتين مختلفتين (ذهاب وإياب)، متوسط السرعة هو المتوسط التوافقي. ولا يساوي المتوسط الحسابي للسرعتين.",
                trap: "أخذ المتوسط الحسابي للسرعتين (أ + ب) ÷ 2. هذا خطأ لأن الزمن عند السرعة الأقل أطول.",
                gen: { d in
                    let pairs = lv(d, [(40, 60), (30, 60), (60, 120), (20, 30)],
                                   [(60, 90), (40, 120), (30, 90), (50, 75), (80, 120), (40, 60), (20, 30)],
                                   [(40, 60), (30, 60), (60, 90), (60, 120), (40, 120), (20, 30)])
                    let pr = pick(pairs)
                    let a = pr.0, b = pr.1
                    if d == .hard {
                        let dist = lcmInt(a, b) * rnd(1...3)
                        let total = dist / a + dist / b
                        return .int(
                            "المسافة بين مدينتين \(dist) كم. ذهب \(nm()) بسرعة \(a) كم/ساعة وعاد بسرعة \(b) كم/ساعة. كم ساعة استغرقت الرحلة كلها؟",
                            steps: ["زمن الذهاب: " + m("\(dist) ÷ \(a) = \(dist / a)"),
                                    "زمن العودة: " + m("\(dist) ÷ \(b) = \(dist / b)"),
                                    "الزمن الكلي: " + m("\(dist / a) + \(dist / b) = \(total)")],
                            value: total, unit: " ساعات")
                        .withTraps([Double(4 * dist) / Double(a + b), Double(2 * dist) / Double(a), Double(dist / a)])
                    }
                    let avg = 2 * a * b / (a + b)
                    return .int(
                        "قطع \(nm()) مسافة بين مدينتين ذهاباً بسرعة \(a) كم/ساعة وعاد بالطريق نفسه بسرعة \(b) كم/ساعة. ما متوسط سرعته في الرحلة كاملة؟",
                        steps: ["لا نأخذ متوسط السرعتين الحسابي، بل نستخدم القانون: " + m("2 × \(a) × \(b) ÷ (\(a) + \(b)) = \(avg)")],
                        value: avg, unit: " كم/ساعة")
                    .withTraps([Double(a + b) / 2, Double(a + b), Double(a * b) / Double(a + b)])
                }),
            Formula(
                id: "work_together", topic: .motion, title: "العمل المشترك",
                expression: "الزمن المشترك = (أ × ب) ÷ (أ + ب)",
                explanation: "إذا أنجز الأول العمل في أ والثاني في ب، فمعدل الأول 1/أ والثاني 1/ب. معاً: 1/أ + 1/ب، والزمن هو مقلوب المجموع. ومع ثلاثة عمال اجمع المعدلات الثلاثة.",
                trap: "جمع الزمنين أو أخذ متوسطهما. الزمن المشترك دائماً أقل من أقصر الزمنين.",
                gen: { d in
                    switch d {
                    case .easy:
                        let pr = pick([(6, 3), (12, 4), (10, 15), (20, 30), (12, 6), (8, 8), (12, 12), (24, 8), (9, 18), (20, 5), (40, 60), (30, 20)])
                        let r = pr.0 * pr.1 / (pr.0 + pr.1)
                        return .int(
                            "عاملان ينجزان العمل نفسه. زمن الأول وحده \(pr.0) ساعات، وزمن الثاني وحده \(pr.1) ساعات. كم ساعة يحتاجان إذا عملا معاً؟",
                            steps: ["نطبّق القانون: " + m("\(pr.0) × \(pr.1) ÷ (\(pr.0) + \(pr.1)) = \(r)")],
                            value: r, unit: " ساعات")
                        .withTraps([Double(pr.0 + pr.1) / 2, Double(pr.0 + pr.1), Double(abs(pr.0 - pr.1))])
                    case .medium:
                        let tr = pick([(6, 3, 2, 1), (12, 6, 4, 2), (20, 30, 60, 10), (10, 15, 30, 5), (8, 12, 24, 4), (4, 6, 12, 2), (6, 12, 12, 3), (18, 9, 6, 3)])
                        let a = tr.0, b = tr.1, c = tr.2, r = tr.3
                        let lc = lcm3(a, b, c)
                        let parts = lc / a + lc / b + lc / c
                        return .int(
                            "ثلاثة عمال؛ ينجز الأول العمل في \(a) ساعات، والثاني في \(b)، والثالث في \(c). كم ساعة يحتاجون إذا عملوا معاً؟",
                            steps: ["معدل العمل في الساعة: " + m("1/\(a) + 1/\(b) + 1/\(c)"),
                                    "بمقام مشترك \(lc): " + m("\(lc / a)/\(lc) + \(lc / b)/\(lc) + \(lc / c)/\(lc) = \(parts)/\(lc)"),
                                    "الزمن = مقلوب المعدل: " + m("\(lc) ÷ \(parts) = \(r)")],
                            value: r, unit: " ساعات")
                        .withTraps([Double(a + b + c), Double(a + b + c) / 3, Double(min(a, min(b, c)))])
                    case .hard:
                        let pr = pick([(6, 2, 3), (12, 4, 6), (10, 6, 15), (20, 12, 30), (12, 8, 24), (24, 6, 8), (9, 6, 18), (30, 12, 20), (60, 24, 40)])
                        let a = pr.0, t = pr.1, b = pr.2
                        return .int(
                            "ينجز عاملان معاً عملاً في \(t) ساعات، والأول وحده ينجزه في \(a) ساعات. كم ساعة يحتاج الثاني وحده؟",
                            steps: ["معدل الثاني = المعدل المشترك − معدل الأول: " + m("1/\(t) − 1/\(a)"),
                                    "نطبّق: " + m("ب = \(a) × \(t) ÷ (\(a) − \(t)) = \(a * t) ÷ \(a - t) = \(b)")],
                            value: b, unit: " ساعات")
                        .withTraps([Double(a - t), Double(a + t), Double(a * t) / Double(a + t)])
                    }
                }),
            Formula(
                id: "relative_speed", topic: .motion, title: "السرعة النسبية",
                expression: "اتجاهان متعاكسان: نجمع السرعتين   ،   الاتجاه نفسه: نطرح السرعتين",
                explanation: "المسافة بين جسمين متحركين = السرعة النسبية × الزمن. إذا اقتربا أو ابتعدا باتجاهين متعاكسين نجمع السرعتين، وإذا تحركا في الاتجاه نفسه نطرح. وزمن اللحاق = المسافة الفاصلة ÷ فرق السرعتين.",
                trap: "جمع السرعتين في حالة الاتجاه الواحد، أو طرحهما في حالة الاتجاهين المتعاكسين.",
                gen: { d in
                    switch d {
                    case .easy:
                        let a = pick([60, 70, 80, 90, 100])
                        let b = pick([30, 40, 50])
                        let t = rnd(2...6)
                        if Bool.random() {
                            let rel = a + b
                            return .int(
                                "تحرّكت سيارتان من النقطة نفسها في اتجاهين متعاكسين بسرعتي \(a) و\(b) كم/ساعة. كم تبعد إحداهما عن الأخرى بعد \(t) ساعات؟",
                                steps: ["السرعة النسبية (نجمع): " + m("\(a) + \(b) = \(rel)"),
                                        "المسافة: " + m("\(rel) × \(t) = \(rel * t)")],
                                value: rel * t, unit: " كم", traps: [(a - b) * t, a * t, rel])
                        }
                        let rel = a - b
                        return .int(
                            "تحرّكت سيارتان من النقطة نفسها في الاتجاه نفسه بسرعتي \(a) و\(b) كم/ساعة. كم تبعد إحداهما عن الأخرى بعد \(t) ساعات؟",
                            steps: ["السرعة النسبية (نطرح): " + m("\(a) − \(b) = \(rel)"),
                                    "المسافة: " + m("\(rel) × \(t) = \(rel * t)")],
                            value: rel * t, unit: " كم", traps: [(a + b) * t, a * t, rel])
                    case .medium:
                        var s1 = 0, gap = 0, lead = 0
                        repeat {
                            s1 = pick([40, 50, 60, 80])
                            gap = pick([10, 20, 30, 40])
                            lead = rnd(1...3)
                        } while (s1 * lead) % gap != 0
                        let s2 = s1 + gap
                        let ahead = s1 * lead
                        let t = ahead / gap
                        return .int(
                            "انطلقت سيارة بسرعة \(s1) كم/ساعة، وبعد \(lead) ساعات انطلقت خلفها سيارة من النقطة نفسها بسرعة \(s2) كم/ساعة. بعد كم ساعة من انطلاق الثانية تلحق بالأولى؟",
                            steps: ["المسافة التي سبقت بها الأولى: " + m("\(s1) × \(lead) = \(ahead)"),
                                    "فرق السرعتين: " + m("\(s2) − \(s1) = \(gap)"),
                                    "زمن اللحاق: " + m("\(ahead) ÷ \(gap) = \(t)")],
                            value: t, unit: " ساعات")
                        .withTraps([Double(ahead) / Double(s1 + s2), Double(t + lead), Double(ahead) / Double(s2)])
                    case .hard:
                        let a = pick([40, 50, 60, 70, 80])
                        let b = pick([30, 40, 50, 60])
                        let t = rnd(2...5)
                        let dist = (a + b) * t
                        return .int(
                            "المسافة بين مدينتين \(dist) كم. انطلقت سيارتان في الوقت نفسه من المدينتين نحو بعضهما بسرعتي \(a) و\(b) كم/ساعة. بعد كم ساعة تلتقيان؟",
                            steps: ["تقتربان بسرعة نسبية (نجمع): " + m("\(a) + \(b) = \(a + b)"),
                                    "زمن الالتقاء: " + m("\(dist) ÷ \(a + b) = \(t)")],
                            value: t, unit: " ساعات")
                        .withTraps([Double(dist) / Double(max(1, abs(a - b))), Double(dist) / Double(a), Double(t * 2)])
                    }
                })
        ]
    }
}

/// المضاعف المشترك الأصغر لعددين.
func lcmInt(_ a: Int, _ b: Int) -> Int { a / gcd(a, b) * b }

func lcm3(_ a: Int, _ b: Int, _ c: Int) -> Int { lcmInt(lcmInt(a, b), c) }
