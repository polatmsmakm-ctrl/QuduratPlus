import Foundation

extension FormulaData {

    // MARK: - الهندسة: التشابه، القطاع، زوايا المثلث، الإحداثيات، التكبير، الساعة

    static func geometryPlus() -> [Formula] {
        return [
            Formula(
                id: "similar_tri", topic: .geometry, title: "المثلثات المتشابهة",
                expression: "الأضلاع المتناظرة متناسبة   ،   نسبة المساحتين = (نسبة التشابه)²",
                explanation: "في المثلثين المتشابهين: نسبة أي ضلعين متناظرين ثابتة (نسبة التشابه). وإذا كانت نسبة الأضلاع ك فنسبة المحيطين ك ونسبة المساحتين ك².",
                trap: "جمع الفرق بدل الضرب في نسبة التشابه، أو استعمال نسبة الأضلاع للمساحة بدون تربيع.",
                gen: { d in
                    switch d {
                    case .easy, .medium:
                        let p = d == .easy ? pick([2, 3, 4]) : pick([3, 4, 5, 5, 7])
                        let q = d == .easy ? 1 : (p == 3 ? 2 : pick([2, 3]))
                        let u = rnd(2...6) * q
                        var v = 0
                        repeat { v = rnd(2...8) * q } while v == u
                        let a1 = u, b1 = v
                        let a2 = u / q * p, b2 = v / q * p
                        return .int(
                            "مثلثان متشابهان، ضلع في الأول طوله \(a1) سم ويناظره في الثاني ضلع طوله \(a2) سم. إذا كان ضلع آخر في الأول طوله \(b1) سم، فما طول الضلع المناظر له في الثاني؟",
                            steps: ["نسبة التشابه: " + m("\(a2) ÷ \(a1) = \(frac(a2, a1))"),
                                    "الضلع المطلوب: " + m("\(b1) × \(frac(a2, a1)) = \(b2)")],
                            value: b2, unit: " سم", traps: [b1 + (a2 - a1), a2, b2 + p])
                    case .hard:
                        let pr = pick([(1, 2), (2, 3), (1, 3), (3, 4), (2, 5)])
                        let t = rnd(2...6)
                        let small = pr.0 * pr.0 * t
                        let big = pr.1 * pr.1 * t
                        return .int(
                            "مثلثان متشابهان نسبة أضلاعهما \(m("\(pr.0) : \(pr.1)")). إذا كانت مساحة الأصغر \(small) سم²، فما مساحة الأكبر؟",
                            steps: ["نسبة المساحتين = مربع نسبة الأضلاع: " + m("\(pr.0)² : \(pr.1)² = \(pr.0 * pr.0) : \(pr.1 * pr.1)"),
                                    "مساحة الأكبر: " + m("\(small) × \(pr.1 * pr.1) ÷ \(pr.0 * pr.0) = \(big)")],
                            value: big, unit: " سم²")
                        .withTraps([Double(small * pr.1) / Double(pr.0), Double(small + big) / 2, Double(big * 2)])
                    }
                }),
            Formula(
                id: "sector", topic: .geometry, title: "القطاع الدائري وطول القوس",
                expression: "طول القوس = (الزاوية ÷ 360) × 2πنق   ،   مساحة القطاع = (الزاوية ÷ 360) × πنق²",
                explanation: "القطاع جزء من الدائرة نسبته (الزاوية المركزية ÷ 360). اضرب هذه النسبة في محيط الدائرة لطول القوس، وفي مساحتها لمساحة القطاع.",
                trap: "استعمال قانون المساحة لطول القوس أو العكس، أو نسيان القسمة على 360.",
                gen: { d in
                    switch d {
                    case .easy:
                        var theta = 0, r = 0
                        repeat {
                            theta = pick([60, 90, 120, 180])
                            r = rnd(3...12)
                        } while (theta * r) % 180 != 0
                        let arc = theta * r / 180
                        return .int(
                            "دائرة نصف قطرها \(r) سم. ما طول القوس المقابل لزاوية مركزية \(theta)° بدلالة π؟",
                            steps: ["نسبة القطاع: " + m("\(theta) ÷ 360 = \(frac(theta, 360))"),
                                    "طول القوس: " + m("\(frac(theta, 360)) × 2π × \(r) = \(arc)π")],
                            value: arc, unit: "π")
                        .withTraps([Double(theta * r * r) / 360, Double(2 * r), Double(theta * r) / 360])
                    case .medium:
                        var theta = 0, r = 0
                        repeat {
                            theta = pick([30, 45, 60, 90, 120, 150, 270])
                            r = rnd(2...12)
                        } while (theta * r * r) % 360 != 0
                        let area = theta * r * r / 360
                        return .int(
                            "دائرة نصف قطرها \(r) سم. ما مساحة القطاع الذي زاويته المركزية \(theta)° بدلالة π؟",
                            steps: ["نسبة القطاع: " + m("\(theta) ÷ 360 = \(frac(theta, 360))"),
                                    "المساحة: " + m("\(frac(theta, 360)) × π × \(r)² = \(area)π")],
                            value: area, unit: "π")
                        .withTraps([Double(theta * r) / 180, Double(r * r), Double(theta * r * r) / 180])
                    case .hard:
                        var theta = 0, r = 0
                        repeat {
                            theta = pick([30, 40, 45, 60, 72, 90, 120, 135, 150])
                            r = rnd(3...12)
                        } while (theta * r) % 180 != 0
                        let arc = theta * r / 180
                        return .int(
                            "في دائرة نصف قطرها \(r) سم، طول قوس \(arc)π سم. ما قياس الزاوية المركزية المقابلة له؟",
                            steps: ["المحيط كاملاً: " + m("2π × \(r) = \(2 * r)π"),
                                    "نسبة القوس من المحيط: " + m("\(arc) ÷ \(2 * r) = \(frac(arc, 2 * r))"),
                                    "الزاوية: " + m("\(frac(arc, 2 * r)) × 360 = \(theta)°")],
                            value: theta, unit: "°")
                        .withTraps([Double(theta) / 2, Double(theta * 2), Double(360 - theta)])
                    }
                }),
            Formula(
                id: "triangle_angles", topic: .geometry, title: "زوايا المثلث والزاوية الخارجية",
                expression: "مجموع زوايا المثلث = 180°   ،   الزاوية الخارجية = مجموع الداخليتين البعيدتين عنها",
                explanation: "مجموع زوايا أي مثلث 180°. الزاوية الخارجية (بين ضلع وامتداد ضلع آخر) تساوي مجموع الزاويتين الداخليتين غير المجاورتين لها.",
                trap: "اعتبار الزاوية الخارجية مساوية للداخلية المجاورة، أو نسيان أن مجموع زوايا المثلث 180° وليس 360°.",
                gen: { d in
                    switch d {
                    case .easy:
                        let a = rnd(30...80), b = rnd(30...80)
                        let c = 180 - a - b
                        return .int(
                            "في مثلث قياس زاويتين \(a)° و\(b)°. ما قياس الزاوية الثالثة؟",
                            steps: ["مجموع زوايا المثلث 180°: " + m("180 − \(a) − \(b) = \(c)")],
                            value: c, unit: "°", traps: [a + b, 360 - a - b, 90 - c])
                    case .medium:
                        let a = rnd(25...75), b = rnd(25...75)
                        return .int(
                            "في مثلث زاويتان داخليتان \(a)° و\(b)°. ما قياس الزاوية الخارجية عند الرأس الثالث؟",
                            steps: ["الزاوية الخارجية = مجموع الداخليتين البعيدتين: " + m("\(a) + \(b) = \(a + b)"),
                                    "تحقق: الداخلية الثالثة " + m("\(180 - a - b)") + " ومكملتها " + m("180 − \(180 - a - b) = \(a + b)")],
                            value: a + b, unit: "°", traps: [180 - a - b, 360 - a - b, 180 - a])
                    case .hard:
                        let ratio = pick([(1, 2, 3), (2, 3, 4), (1, 1, 2), (3, 4, 5), (2, 3, 5), (1, 2, 6), (4, 5, 9)])
                        let sum = ratio.0 + ratio.1 + ratio.2
                        let unit = 180 / sum
                        let largest = ratio.2 * unit
                        return .int(
                            "زوايا مثلث بنسبة \(m("\(ratio.0) : \(ratio.1) : \(ratio.2)")). ما قياس الزاوية الكبرى؟",
                            steps: ["مجموع الأجزاء: " + m("\(ratio.0) + \(ratio.1) + \(ratio.2) = \(sum)"),
                                    "قيمة الجزء: " + m("180 ÷ \(sum) = \(unit)"),
                                    "الكبرى: " + m("\(ratio.2) × \(unit) = \(largest)")],
                            value: largest, unit: "°", traps: [ratio.0 * unit, unit, 360 / sum * ratio.2])
                    }
                }),
            Formula(
                id: "coordinates", topic: .geometry, title: "الإحداثيات: الميل والمنتصف والمسافة",
                expression: "الميل = (ص٢ − ص١) ÷ (س٢ − س١)   ،   المنتصف = ((س١ + س٢) ÷ 2 ، (ص١ + ص٢) ÷ 2)   ،   المسافة = √((Δس)² + (Δص)²)",
                symbolic: true,
                explanation: "الميل يقيس انحدار المستقيم (التغير الرأسي ÷ التغير الأفقي). المنتصف متوسط الإحداثيات. والمسافة بين نقطتين تطبيق لنظرية فيثاغورس.",
                trap: "قلب الميل (Δس ÷ Δص)، أو جمع الإحداثيات بدون القسمة على 2 في المنتصف.",
                gen: { d in
                    switch d {
                    case .easy:
                        var k = 0
                        repeat { k = rnd(-4...4) } while k == 0
                        let x1 = rnd(-5...5), y1 = rnd(-5...5)
                        let dx = rnd(1...4)
                        let x2 = x1 + dx, y2 = y1 + k * dx
                        let p1 = m("(\(x1) ، \(y1))".replacingOccurrences(of: "-", with: "−"))
                        let p2 = m("(\(x2) ، \(y2))".replacingOccurrences(of: "-", with: "−"))
                        return .int(
                            "ما ميل المستقيم المار بالنقطتين \(p1) و\(p2)؟",
                            steps: ["التغير الرأسي: " + m("\(y2) − (\(y1)) = \(k * dx)".replacingOccurrences(of: "-", with: "−")),
                                    "التغير الأفقي: " + m("\(x2) − (\(x1)) = \(dx)".replacingOccurrences(of: "-", with: "−")),
                                    "الميل: " + m("\(k * dx) ÷ \(dx) = \(k)".replacingOccurrences(of: "-", with: "−"))],
                            value: k)
                        .withTraps([Double(dx) / Double(k * dx), Double(-k), Double(k * dx)])
                    case .medium:
                        let x1 = rnd(-6...8), y1 = rnd(-6...8)
                        let x2 = x1 + 2 * rnd(1...5), y2 = y1 + 2 * rnd(-4...5)
                        let mx = (x1 + x2) / 2, my = (y1 + y2) / 2
                        func pt(_ a: Int, _ b: Int) -> String { m("(\(a) ، \(b))".replacingOccurrences(of: "-", with: "−")) }
                        let answer = pt(mx, my)
                        return .text(
                            "ما منتصف القطعة المستقيمة الواصلة بين " + pt(x1, y1) + " و" + pt(x2, y2) + "؟",
                            steps: ["الإحداثي السيني: " + m("(\(x1) + \(x2)) ÷ 2 = \(mx)".replacingOccurrences(of: "-", with: "−")),
                                    "الإحداثي الصادي: " + m("(\(y1) + \(y2)) ÷ 2 = \(my)".replacingOccurrences(of: "-", with: "−")),
                                    "المنتصف: " + answer],
                            answer: answer,
                            traps: distinct(answer, [pt(x1 + x2, y1 + y2), pt((x2 - x1) / 2, (y2 - y1) / 2), pt(my, mx), pt(mx + 1, my - 1)]))
                    case .hard:
                        let t = pick([(3, 4, 5), (6, 8, 10), (5, 12, 13), (8, 15, 17), (9, 12, 15)])
                        let x1 = rnd(-5...5), y1 = rnd(-5...5)
                        let x2 = x1 + t.0, y2 = y1 + (Bool.random() ? t.1 : -t.1)
                        let p1 = m("(\(x1) ، \(y1))".replacingOccurrences(of: "-", with: "−"))
                        let p2 = m("(\(x2) ، \(y2))".replacingOccurrences(of: "-", with: "−"))
                        return .int(
                            "ما المسافة بين النقطتين \(p1) و\(p2)؟",
                            steps: ["الفرقان: " + m("Δس = \(t.0)") + " و" + m("Δص = \(t.1)"),
                                    "فيثاغورس: " + m("√(\(t.0)² + \(t.1)²) = √\(t.2 * t.2) = \(t.2)")],
                            value: t.2, traps: [t.0 + t.1, t.2 * t.2, abs(t.1 - t.0)])
                    }
                }),
            Formula(
                id: "scaling", topic: .geometry, title: "تكبير الأبعاد (المساحة والحجم)",
                expression: "إذا ضُربت الأبعاد في ك: المحيط × ك   ،   المساحة × ك²   ،   الحجم × ك³",
                explanation: "تكبير كل الأبعاد بنسبة ك يضرب الأطوال في ك والمساحات في ك² والأحجام في ك³. وزيادة الأبعاد ن% تعني ضربها في (1 + ن%).",
                trap: "الظن أن مضاعفة الضلع تضاعف المساحة؛ الصحيح أنها تضربها في 4.",
                gen: { d in
                    switch d {
                    case .easy:
                        let k = pick([2, 3])
                        let s = rnd(2...9)
                        let area = s * s
                        return .int(
                            "مربع مساحته \(area) سم². إذا ضُرب طول ضلعه في \(k)، فكم تصبح مساحته؟",
                            steps: ["المساحة تُضرب في " + m("\(k)² = \(k * k)"),
                                    "المساحة الجديدة: " + m("\(area) × \(k * k) = \(area * k * k)")],
                            value: area * k * k, unit: " سم²", traps: [area * k, area + k, area * 2 * k])
                    case .medium:
                        let k = pick([2, 3])
                        let s = rnd(2...5)
                        let v = s * s * s
                        return .int(
                            "مكعب حجمه \(v) سم³. إذا ضُرب طول ضلعه في \(k)، فكم يصبح حجمه؟",
                            steps: ["الحجم يُضرب في " + m("\(k)³ = \(k * k * k)"),
                                    "الحجم الجديد: " + m("\(v) × \(k * k * k) = \(v * k * k * k)")],
                            value: v * k * k * k, unit: " سم³", traps: [v * k, v * k * k, v + k * k * k])
                    case .hard:
                        let p = pick([10, 20, 30, 50])
                        let factorTimes100 = (100 + p) * (100 + p)
                        let increase = factorTimes100 / 100 - 100
                        return .int(
                            "زاد طول مستطيل وعرضه بنسبة \(p)% لكل منهما. بكم في المئة تزيد مساحته؟",
                            steps: ["كل بعد يُضرب في " + m(fmt(Double(100 + p) / 100)),
                                    "المساحة تُضرب في " + m("\(fmt(Double(100 + p) / 100)) × \(fmt(Double(100 + p) / 100)) = \(fmt(Double(factorTimes100) / 10000))"),
                                    "الزيادة: " + m("\(fmt(Double(factorTimes100) / 10000)) − 1 = \(increase)%")],
                            value: increase, unit: "%", traps: [p, 2 * p, p * p / 100])
                    }
                }),
            Formula(
                id: "clock_angle", topic: .geometry, title: "زاوية عقارب الساعة",
                expression: "الزاوية = |30 × الساعات − 5.5 × الدقائق|",
                explanation: "عقرب الساعات يتحرك 30° كل ساعة و0.5° كل دقيقة، وعقرب الدقائق 6° كل دقيقة. احسب الفرق، وإذا زاد على 180° فالزاوية الصغرى = 360 − الناتج.",
                trap: "نسيان أن عقرب الساعات يتحرك أيضاً خلال الدقائق (ليس ثابتاً على الرقم).",
                gen: { d in
                    let h = rnd(1...11)
                    let minutes = lv(d, 0, pick([20, 30, 40]), 2 * rnd(5...29))
                    let hourDeg = Double(h * 30) + Double(minutes) * 0.5
                    let minDeg = Double(minutes * 6)
                    var angle = abs(hourDeg - minDeg)
                    if angle > 180 { angle = 360 - angle }
                    let naive = Double(abs(h * 30 - minutes * 6))
                    let naiveSmall = naive > 180 ? 360 - naive : naive
                    let mm = minutes < 10 ? "0\(minutes)" : "\(minutes)"
                    var steps = ["عقرب الساعات: " + m("30 × \(h) + 0.5 × \(minutes) = \(fmt(hourDeg))°"),
                                 "عقرب الدقائق: " + m("6 × \(minutes) = \(fmt(minDeg))°"),
                                 "الفرق: " + m("|\(fmt(hourDeg)) − \(fmt(minDeg))| = \(fmt(abs(hourDeg - minDeg)))°")]
                    if abs(hourDeg - minDeg) > 180 {
                        steps.append("أكبر من 180°، فالزاوية الصغرى: " + m("360 − \(fmt(abs(hourDeg - minDeg))) = \(fmt(angle))°"))
                    }
                    return .num(
                        "ما قياس الزاوية الصغرى بين عقربي الساعة عند الساعة " + m("\(h):\(mm)") + "؟",
                        steps: steps, value: angle, unit: "°",
                        traps: [naiveSmall, 360 - angle, angle + 15])
                })
        ]
    }
}
