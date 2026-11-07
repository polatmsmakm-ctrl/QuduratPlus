import Foundation

extension FormulaData {

    // MARK: - الهندسة

    static func geometry() -> [Formula] {
        return [
            Formula(
                id: "rect", topic: .geometry, title: "مساحة المستطيل ومحيطه",
                expression: "المساحة = الطول × العرض   ،   المحيط = 2 × (الطول + العرض)",
                explanation: "المساحة تقيس السطح الداخلي (وحدتها مربعة)، والمحيط هو مجموع أطوال الأضلاع الأربعة. إذا عرفت المساحة وأحد البعدين فالبعد الآخر = المساحة ÷ البعد المعلوم.",
                trap: "الخلط بين المساحة والمحيط، أو نسيان الضرب في 2 في المحيط.",
                gen: { d in
                    switch d {
                    case .easy:
                        let l = rnd(6...20)
                        let w = rnd(3...(l - 1))
                        if Bool.random() {
                            return .int(
                                "مستطيل طوله \(l) سم وعرضه \(w) سم. ما مساحته؟",
                                steps: ["المساحة = الطول × العرض: " + m("\(l) × \(w) = \(l * w)")],
                                value: l * w, unit: " سم²", traps: [2 * (l + w), l + w, 2 * l * w])
                        }
                        return .int(
                            "مستطيل طوله \(l) سم وعرضه \(w) سم. ما محيطه؟",
                            steps: ["المحيط = 2 × (الطول + العرض): " + m("2 × (\(l) + \(w)) = \(2 * (l + w))")],
                            value: 2 * (l + w), unit: " سم", traps: [l * w, l + w, 2 * l + w])
                    case .medium:
                        let l = rnd(6...15)
                        let w = rnd(2...(l - 1))
                        let area = l * w
                        return .int(
                            "مستطيل مساحته \(area) سم² وطوله \(l) سم. ما محيطه؟",
                            steps: ["العرض = المساحة ÷ الطول: " + m("\(area) ÷ \(l) = \(w)"),
                                    "المحيط: " + m("2 × (\(l) + \(w)) = \(2 * (l + w))")],
                            value: 2 * (l + w), unit: " سم", traps: [l + w, area, 2 * l + w])
                    case .hard:
                        let w = 2 * rnd(1...6)
                        let l = 2 * w
                        let p = 2 * (l + w)
                        return .int(
                            "مستطيل طوله ضعف عرضه، ومحيطه \(p) سم. ما مساحته؟",
                            steps: ["نفرض العرض س، فالطول 2س والمحيط " + m("2 × (2س + س) = 6س"),
                                    "إذن " + m("6س = \(p)") + " ومنه " + m("س = \(w)") + "، والطول \(l)",
                                    "المساحة: " + m("\(l) × \(w) = \(l * w)")],
                            value: l * w, unit: " سم²", traps: [(3 * w / 2) * (3 * w / 2), w * w, 3 * w * w])
                    }
                }),
            Formula(
                id: "triangle", topic: .geometry, title: "مساحة المثلث",
                expression: "المساحة = ½ × القاعدة × الارتفاع",
                explanation: "الارتفاع هو البعد العمودي من القمة إلى القاعدة، وليس بالضرورة أحد الأضلاع. وفي المثلث القائم يكون الضلعان القائمان قاعدة وارتفاعاً.",
                trap: "استعمال طول الضلع المائل بدل الارتفاع العمودي، أو نسيان الضرب في ½.",
                gen: { d in
                    switch d {
                    case .easy:
                        let base = 2 * rnd(3...10)
                        let h = rnd(3...15)
                        let area = base * h / 2
                        return .int(
                            "مثلث قاعدته \(base) سم وارتفاعه \(h) سم. ما مساحته؟",
                            steps: ["نطبّق القانون: " + m("½ × \(base) × \(h) = \(area)")],
                            value: area, unit: " سم²", traps: [base * h, base + h, area / 2])
                    case .medium:
                        let base = rnd(4...16)
                        let h = 2 * rnd(2...9)
                        let area = base * h / 2
                        return .int(
                            "مثلث مساحته \(area) سم² وقاعدته \(base) سم. ما ارتفاعه؟",
                            steps: ["من القانون: " + m("الارتفاع = 2 × المساحة ÷ القاعدة"),
                                    "نعوّض: " + m("2 × \(area) ÷ \(base) = \(h)")],
                            value: h, unit: " سم")
                        .withTraps([Double(area) / Double(base), Double(area * base), Double(h + 2)])
                    case .hard:
                        let t = pick([(3, 4, 5), (6, 8, 10), (5, 12, 13), (8, 15, 17), (9, 12, 15)])
                        let area = t.0 * t.1 / 2
                        return .int(
                            "مثلث قائم الزاوية وتره \(t.2) سم وأحد ضلعيه القائمين \(t.0) سم. ما مساحته؟",
                            steps: ["الضلع الآخر بفيثاغورس: " + m("√(\(t.2)² − \(t.0)²) = √\(t.2 * t.2 - t.0 * t.0) = \(t.1)"),
                                    "الضلعان القائمان قاعدة وارتفاع: " + m("½ × \(t.0) × \(t.1) = \(area)")],
                            value: area, unit: " سم²")
                        .withTraps([Double(t.0 * t.2) / 2, Double(t.0 * t.1), Double(t.1 * t.2) / 2])
                    }
                }),
            Formula(
                id: "trapezoid", topic: .geometry, title: "مساحة شبه المنحرف",
                expression: "المساحة = ½ × (القاعدة الأولى + القاعدة الثانية) × الارتفاع",
                explanation: "القاعدتان هما الضلعان المتوازيان. اجمعهما أولاً، ثم اضرب في الارتفاع، ثم نصّف. ولإيجاد قاعدة مجهولة: مجموع القاعدتين = 2 × المساحة ÷ الارتفاع.",
                trap: "نسيان جمع القاعدتين، أو استعمال الضلع الجانبي بدل الارتفاع.",
                gen: { d in
                    let a = rnd(4...12)
                    let b = rnd(6...16)
                    let h = 2 * rnd(2...6)
                    let area = (a + b) * h / 2
                    switch d {
                    case .easy:
                        return .int(
                            "شبه منحرف قاعدتاه \(a) سم و\(b) سم وارتفاعه \(h) سم. ما مساحته؟",
                            steps: ["نجمع القاعدتين: " + m("\(a) + \(b) = \(a + b)"),
                                    "نضرب في الارتفاع وننصّف: " + m("½ × \(a + b) × \(h) = \(area)")],
                            value: area, unit: " سم²", traps: [(a + b) * h, a * b, area + h])
                    case .medium:
                        return .int(
                            "شبه منحرف مساحته \(area) سم² وقاعدتاه \(a) سم و\(b) سم. ما ارتفاعه؟",
                            steps: ["الارتفاع = 2 × المساحة ÷ مجموع القاعدتين",
                                    "نعوّض: " + m("2 × \(area) ÷ (\(a) + \(b)) = \(h)")],
                            value: h, unit: " سم")
                        .withTraps([Double(area) / Double(a + b), Double(area * 2) / Double(a), Double(h * 2)])
                    case .hard:
                        return .int(
                            "شبه منحرف مساحته \(area) سم² وارتفاعه \(h) سم وإحدى قاعدتيه \(a) سم. ما طول القاعدة الأخرى؟",
                            steps: ["مجموع القاعدتين: " + m("2 × \(area) ÷ \(h) = \(a + b)"),
                                    "القاعدة الأخرى: " + m("\(a + b) − \(a) = \(b)")],
                            value: b, unit: " سم")
                        .withTraps([Double(area) / Double(h) - Double(a), Double(a + b), Double(2 * area) / Double(h) + Double(a)])
                    }
                }),
            Formula(
                id: "circle", topic: .geometry, title: "مساحة الدائرة ومحيطها",
                expression: "المساحة = π × نق²   ،   المحيط = 2 × π × نق",
                explanation: "نق هو نصف القطر، والقطر = 2 × نق. في القدرات يكون الجواب غالباً بدلالة π (مثل 25π)، أو تُعطى π = 22/7 مع نصف قطر من مضاعفات 7.",
                trap: "استعمال القطر مكان نصف القطر، أو نسيان تربيع نق في المساحة.",
                gen: { d in
                    switch d {
                    case .easy:
                        let r = pick([7, 14, 21])
                        if Bool.random() {
                            let area = 22 * r * r / 7
                            return .int(
                                "دائرة نصف قطرها \(r) سم. ما مساحتها؟ " + m("(π = 22/7)"),
                                steps: ["نطبّق القانون: " + m("22/7 × \(r)² = 22/7 × \(r * r) = \(area)")],
                                value: area, unit: " سم²", traps: [2 * 22 * r / 7, 4 * area, 22 * r / 7])
                        }
                        let c = 2 * 22 * r / 7
                        return .int(
                            "دائرة نصف قطرها \(r) سم. ما محيطها؟ " + m("(π = 22/7)"),
                            steps: ["نطبّق القانون: " + m("2 × 22/7 × \(r) = \(c)")],
                            value: c, unit: " سم", traps: [22 * r * r / 7, 22 * r / 7, 2 * c])
                    case .medium:
                        let r = rnd(3...12)
                        let dia = 2 * r
                        if Bool.random() {
                            return .int(
                                "دائرة قطرها \(dia) سم. ما مساحتها بدلالة π؟",
                                steps: ["نصف القطر = القطر ÷ 2: " + m("\(dia) ÷ 2 = \(r)"),
                                        "المساحة: " + m("π × \(r)² = \(r * r)π")],
                                value: r * r, unit: "π", traps: [dia * dia, dia, 2 * r * r])
                        }
                        return .int(
                            "دائرة قطرها \(dia) سم. ما محيطها بدلالة π؟",
                            steps: ["المحيط = π × القطر: " + m("π × \(dia) = \(dia)π")],
                            value: dia, unit: "π", traps: [r, r * r, 2 * dia])
                    case .hard:
                        let r = rnd(3...12)
                        return .int(
                            "دائرة مساحتها \(r * r)π سم². ما محيطها بدلالة π؟",
                            steps: ["من المساحة: " + m("نق² = \(r * r)") + " إذن " + m("نق = \(r)"),
                                    "المحيط: " + m("2 × π × \(r) = \(2 * r)π")],
                            value: 2 * r, unit: "π", traps: [r, r * r / 2, 4 * r])
                    }
                }),
            Formula(
                id: "pythagoras", topic: .geometry, title: "نظرية فيثاغورس",
                expression: "الوتر² = الضلع الأول² + الضلع الثاني²",
                explanation: "تنطبق على المثلث القائم الزاوية فقط. الوتر هو أطول ضلع وهو المقابل للزاوية القائمة. تذكّر الثلاثيات: (3، 4، 5) و(5، 12، 13) و(8، 15، 17) ومضاعفاتها.",
                trap: "جمع الأضلاع بدل جمع مربعاتها، أو نسيان الجذر التربيعي في النهاية.",
                gen: { d in
                    switch d {
                    case .easy:
                        let t = pick([(3, 4, 5), (6, 8, 10), (5, 12, 13), (9, 12, 15)])
                        return .int(
                            "مثلث قائم الزاوية طولا ضلعيه القائمين \(t.0) سم و\(t.1) سم. ما طول الوتر؟",
                            steps: ["نجمع مربعي الضلعين: " + m("\(t.0)² + \(t.1)² = \(t.0 * t.0) + \(t.1 * t.1) = \(t.2 * t.2)"),
                                    "نأخذ الجذر التربيعي: " + m("√\(t.2 * t.2) = \(t.2)")],
                            value: t.2, unit: " سم", traps: [t.0 + t.1, t.2 * t.2, t.2 + 1])
                    case .medium:
                        let t = pick([(8, 15, 17), (7, 24, 25), (12, 16, 20), (20, 21, 29), (9, 40, 41), (5, 12, 13), (15, 20, 25)])
                        return .int(
                            "مثلث قائم الزاوية وتره \(t.2) سم وأحد ضلعيه القائمين \(t.0) سم. ما طول الضلع الآخر؟",
                            steps: ["نطرح مربع المعلوم من مربع الوتر: " + m("\(t.2)² − \(t.0)² = \(t.2 * t.2) − \(t.0 * t.0) = \(t.1 * t.1)"),
                                    "نأخذ الجذر التربيعي: " + m("√\(t.1 * t.1) = \(t.1)")],
                            value: t.1, unit: " سم", traps: [t.2 - t.0, t.1 * t.1, t.2 + t.0])
                    case .hard:
                        let shape = pick([(5, 12, 13), (3, 4, 5), (8, 15, 17)])
                        let k = shape.0 == 8 ? 1 : pick([1, 2])
                        let half = shape.0 * k
                        let h = shape.1 * k
                        let side = shape.2 * k
                        let base = 2 * half
                        let area = half * h
                        return .int(
                            "مثلث متطابق الضلعين، طول كل من ضلعيه المتطابقين \(side) سم وقاعدته \(base) سم. ما مساحته؟",
                            steps: ["الارتفاع ينصّف القاعدة: نصفها " + m("\(base) ÷ 2 = \(half)"),
                                    "الارتفاع بفيثاغورس: " + m("√(\(side)² − \(half)²) = √\(side * side - half * half) = \(h)"),
                                    "المساحة: " + m("½ × \(base) × \(h) = \(area)")],
                            value: area, unit: " سم²", traps: [base * side / 2, base * h, h * side / 2])
                    }
                }),
            Formula(
                id: "polygon", topic: .geometry, title: "زوايا المضلع",
                expression: "مجموع الزوايا الداخلية = (ن − 2) × 180°",
                explanation: "ن هو عدد الأضلاع. في المضلع المنتظم كل الزوايا متساوية، فقياس الزاوية الواحدة = المجموع ÷ ن. ومجموع الزوايا الخارجية لأي مضلع 360°، فالزاوية الخارجية للمنتظم = 360 ÷ ن.",
                trap: "استعمال (ن) بدل (ن − 2). ولا تنسَ أن القسمة على ن تكون للمضلع المنتظم فقط.",
                gen: { d in
                    switch d {
                    case .easy:
                        let n = pick([4, 5, 6, 8, 10])
                        let sum = (n - 2) * 180
                        return .int(
                            "ما مجموع الزوايا الداخلية لمضلع عدد أضلاعه \(n)؟",
                            steps: ["نطبّق القانون: " + m("(\(n) − 2) × 180 = \(sum)")],
                            value: sum, unit: "°", traps: [n * 180, (n - 1) * 180, (n - 2) * 90])
                    case .medium:
                        let n = pick([5, 6, 8, 9, 10, 12])
                        let sum = (n - 2) * 180
                        let each = sum / n
                        return .int(
                            "ما قياس كل زاوية داخلية في مضلع منتظم عدد أضلاعه \(n)؟",
                            steps: ["مجموع الزوايا: " + m("(\(n) − 2) × 180 = \(sum)"),
                                    "نقسم على عدد الأضلاع: " + m("\(sum) ÷ \(n) = \(each)")],
                            value: each, unit: "°", traps: [sum, 360 / n, 180 - each / 2])
                    case .hard:
                        let pair = pick([(108, 5), (120, 6), (135, 8), (140, 9), (144, 10), (150, 12), (160, 18)])
                        let inner = pair.0, n = pair.1
                        let outer = 180 - inner
                        return .int(
                            "مضلع منتظم قياس زاويته الداخلية \(inner)°. كم عدد أضلاعه؟",
                            steps: ["الزاوية الخارجية: " + m("180 − \(inner) = \(outer)"),
                                    "مجموع الزوايا الخارجية 360°، إذن " + m("ن = 360 ÷ \(outer) = \(n)")],
                            value: n, traps: [n + 2, n - 2, outer])
                    }
                }),
            Formula(
                id: "angles", topic: .geometry, title: "الزوايا المتتامة والمتكاملة",
                expression: "المتتامتان: أ + ب = 90°   ،   المتكاملتان: أ + ب = 180°",
                explanation: "المتتامتان مجموعهما زاوية قائمة (90°). المتكاملتان مجموعهما زاوية مستقيمة (180°). الزاويتان المتجاورتان على خط مستقيم متكاملتان.",
                trap: "الخلط بين «متتامة» (90°) و«متكاملة» (180°).",
                gen: { d in
                    switch d {
                    case .easy:
                        let a = rnd(10...80)
                        if Bool.random() {
                            return .int(
                                "ما قياس الزاوية المتتامة مع زاوية قياسها \(a)°؟",
                                steps: ["مجموعهما 90°: " + m("90 − \(a) = \(90 - a)")],
                                value: 90 - a, unit: "°", traps: [180 - a, a, 90 + a])
                        }
                        return .int(
                            "ما قياس الزاوية المتكاملة مع زاوية قياسها \(a)°؟",
                            steps: ["مجموعهما 180°: " + m("180 − \(a) = \(180 - a)")],
                            value: 180 - a, unit: "°", traps: [90 - a, a, 360 - a])
                    case .medium:
                        let supp = Bool.random()
                        let total = supp ? 180 : 90
                        let ratios = supp ? [(1, 2), (1, 3), (2, 3), (1, 5), (4, 5), (2, 7), (1, 8)] : [(1, 2), (1, 4), (2, 3), (1, 5), (4, 5), (1, 8)]
                        let pr = pick(ratios)
                        let unit = total / (pr.0 + pr.1)
                        let small = pr.0 * unit
                        let big = pr.1 * unit
                        let kind = supp ? "متكاملتان" : "متتامتان"
                        return .int(
                            "زاويتان \(kind) والنسبة بينهما \(m("\(pr.0) : \(pr.1)")). ما قياس الزاوية الصغرى؟",
                            steps: ["مجموع الأجزاء: " + m("\(pr.0) + \(pr.1) = \(pr.0 + pr.1)"),
                                    "قيمة الجزء: " + m("\(total) ÷ \(pr.0 + pr.1) = \(unit)"),
                                    "الصغرى: " + m("\(pr.0) × \(unit) = \(small)")],
                            value: small, unit: "°", traps: [big, unit, (supp ? 90 : 180) / (pr.0 + pr.1) * pr.0])
                    case .hard:
                        let pair = pick([(3, 45), (4, 60), (6, 72), (7, 75), (10, 80)])
                        let k = pair.0, x = pair.1
                        return .int(
                            "زاوية حادة مكمّلتها تساوي \(k) أمثال متمّمتها. ما قياسها؟",
                            steps: ["نفرض الزاوية س: " + m("180 − س = \(k)(90 − س)"),
                                    "نفك القوس: " + m("180 − س = \(90 * k) − \(k)س"),
                                    "نجمع حدود س: " + m("\(k - 1)س = \(90 * k - 180)") + " إذن " + m("س = \(x)")],
                            value: x, unit: "°", traps: [90 - x, 180 - x, x / 2])
                    }
                }),
            Formula(
                id: "volume_box", topic: .geometry, title: "حجم متوازي المستطيلات والمكعب",
                expression: "الحجم = الطول × العرض × الارتفاع   ،   حجم المكعب = الضلع³",
                explanation: "الحجم وحدته مكعبة (سم³). المكعب حالة خاصة أبعاده الثلاثة متساوية، ومساحته الكلية = 6 × الضلع². عدد المكعبات الصغيرة التي تملأ صندوقاً = حجم الصندوق ÷ حجم المكعب الصغير.",
                trap: "الخلط مع المساحة الجانبية، أو كتابة الوحدة بدون تكعيب.",
                gen: { d in
                    switch d {
                    case .easy:
                        if Bool.random() {
                            let l = rnd(2...10), w = rnd(2...10), h = rnd(2...10)
                            let v = l * w * h
                            return .int(
                                "متوازي مستطيلات أبعاده \(l) سم و\(w) سم و\(h) سم. ما حجمه؟",
                                steps: ["نضرب الأبعاد الثلاثة: " + m("\(l) × \(w) × \(h) = \(v)")],
                                value: v, unit: " سم³", traps: [l * w + w * h + l * h, l + w + h, 2 * (l * w + w * h + l * h)])
                        }
                        let s = rnd(2...9)
                        return .int(
                            "مكعب طول ضلعه \(s) سم. ما حجمه؟",
                            steps: ["الحجم = الضلع³: " + m("\(s)³ = \(s) × \(s) × \(s) = \(s * s * s)")],
                            value: s * s * s, unit: " سم³", traps: [s * s, 3 * s, 6 * s * s])
                    case .medium:
                        let s = rnd(2...9)
                        let total = 6 * s * s
                        return .int(
                            "مكعب مساحته الكلية \(total) سم². ما حجمه؟",
                            steps: ["مساحة الوجه الواحد: " + m("\(total) ÷ 6 = \(s * s)"),
                                    "طول الضلع: " + m("√\(s * s) = \(s)"),
                                    "الحجم: " + m("\(s)³ = \(s * s * s)")],
                            value: s * s * s, unit: " سم³", traps: [s * s, total, total / 2])
                    case .hard:
                        let s = pick([2, 3])
                        let l = s * rnd(2...5), w = s * rnd(2...5), h = s * rnd(2...4)
                        let count = (l / s) * (w / s) * (h / s)
                        return .int(
                            "صندوق أبعاده الداخلية \(l) سم و\(w) سم و\(h) سم. كم مكعباً طول ضلعه \(s) سم يملؤه تماماً؟",
                            steps: ["على الطول: " + m("\(l) ÷ \(s) = \(l / s)") + "، وعلى العرض: " + m("\(w) ÷ \(s) = \(w / s)") + "، وعلى الارتفاع: " + m("\(h) ÷ \(s) = \(h / s)"),
                                    "عدد المكعبات: " + m("\(l / s) × \(w / s) × \(h / s) = \(count)")],
                            value: count, traps: [l * w * h / s, l * w * h / (s * s), (l + w + h) / s])
                    }
                }),
            Formula(
                id: "cylinder", topic: .geometry, title: "حجم الأسطوانة",
                expression: "الحجم = π × نق² × الارتفاع",
                explanation: "مساحة القاعدة الدائرية (π × نق²) مضروبة في الارتفاع. والجواب غالباً بدلالة π.",
                trap: "نسيان تربيع نق، أو استعمال القطر بدل نصف القطر.",
                gen: { d in
                    let r = rnd(2...6)
                    let h = rnd(2...10)
                    let v = r * r * h
                    switch d {
                    case .easy:
                        return .int(
                            "أسطوانة نصف قطر قاعدتها \(r) سم وارتفاعها \(h) سم. ما حجمها بدلالة π؟",
                            steps: ["نطبّق القانون: " + m("π × \(r)² × \(h) = π × \(r * r) × \(h) = \(v)π")],
                            value: v, unit: "π", traps: [2 * r * h, r * h, 2 * r * r * h])
                    case .medium:
                        let dia = 2 * r
                        return .int(
                            "أسطوانة قطر قاعدتها \(dia) سم وارتفاعها \(h) سم. ما حجمها بدلالة π؟",
                            steps: ["نصف القطر: " + m("\(dia) ÷ 2 = \(r)"),
                                    "الحجم: " + m("π × \(r)² × \(h) = \(v)π")],
                            value: v, unit: "π", traps: [dia * dia * h, dia * h, r * h])
                    case .hard:
                        return .int(
                            "أسطوانة حجمها \(v)π سم³ ونصف قطر قاعدتها \(r) سم. ما ارتفاعها؟",
                            steps: ["من القانون: " + m("π × \(r)² × ع = \(v)π"),
                                    "إذن " + m("ع = \(v) ÷ \(r * r) = \(h)")],
                            value: h, unit: " سم")
                        .withTraps([Double(v) / Double(r), Double(v) / Double(2 * r), Double(2 * h)])
                    }
                })
        ]
    }
}
