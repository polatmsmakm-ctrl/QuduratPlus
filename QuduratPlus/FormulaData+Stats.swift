import Foundation

extension FormulaData {

    // MARK: - الإحصاء والاحتمالات

    static func stats() -> [Formula] {
        return [
            Formula(
                id: "median", topic: .stats, title: "الوسيط",
                expression: "الوسيط = القيمة الوسطى بعد ترتيب الأعداد",
                explanation: "رتّب الأعداد تصاعدياً. إذا كان عددها فردياً فالوسيط هو الأوسط، وإذا كان زوجياً فهو متوسط العددين الأوسطين.",
                trap: "نسيان الترتيب قبل اختيار الوسط. الوسيط يؤخذ من القائمة المرتبة فقط.",
                gen: { d in
                    let count = lv(d, 5, 6, 8)
                    let nums = Array((1...lv(d, 30, 40, 60)).shuffled().prefix(count))
                    let sorted = nums.sorted()
                    let unsortedMiddle = nums[count / 2]
                    if count % 2 == 1 {
                        let med = sorted[count / 2]
                        return .int(
                            "ما وسيط الأعداد: \(list(nums))؟",
                            steps: ["نرتّب تصاعدياً: \(list(sorted))", "عددها فردي، فالوسيط هو الأوسط: \(med)"],
                            value: med, traps: [unsortedMiddle, sorted[count / 2 - 1], sorted[count / 2 + 1]])
                    }
                    let a = sorted[count / 2 - 1]
                    let b = sorted[count / 2]
                    let med = Double(a + b) / 2.0
                    return .num(
                        "ما وسيط الأعداد: \(list(nums))؟",
                        steps: ["نرتّب تصاعدياً: \(list(sorted))",
                                "عددها زوجي، نأخذ متوسط العددين الأوسطين: " + m("(\(a) + \(b)) ÷ 2 = \(fmt(med))")],
                        value: med, traps: [Double(unsortedMiddle), Double(a), Double(b)])
                }),
            Formula(
                id: "mode", topic: .stats, title: "المنوال",
                expression: "المنوال = القيمة الأكثر تكراراً",
                explanation: "هو العدد الذي يظهر أكثر من غيره. قد لا يوجد منوال، وقد يوجد أكثر من منوال.",
                trap: "الخلط بين المنوال (الأكثر تكراراً) والوسيط (الأوسط) والمتوسط. وكتابة عدد مرات التكرار بدل القيمة نفسها.",
                gen: { d in
                    let pool = Array((1...30).shuffled())
                    var nums: [Int] = []
                    var answer = 0
                    var freq = 0
                    var runnerUp = 0
                    switch d {
                    case .easy:
                        answer = pool[0]
                        freq = 3
                        runnerUp = pool[1]
                        nums = [answer, answer, answer, pool[1], pool[2], pool[3]]
                    case .medium:
                        answer = pool[0]
                        freq = 3
                        runnerUp = pool[1]
                        nums = [answer, answer, answer, runnerUp, runnerUp, pool[2], pool[3], pool[4]]
                    case .hard:
                        answer = pool[0]
                        freq = 4
                        runnerUp = pool[1]
                        nums = [answer, answer, answer, answer, runnerUp, runnerUp, runnerUp, pool[2], pool[3], pool[4]]
                    }
                    nums.shuffle()
                    return .int(
                        "ما منوال الأعداد: \(list(nums))؟",
                        steps: ["نعدّ تكرار كل عدد: العدد \(answer) تكرر \(freq) مرات، وهو الأكثر تكراراً",
                                "المنوال هو القيمة نفسها وليس عدد مرات التكرار"],
                        value: answer, traps: [runnerUp, freq, nums.max() ?? answer + 1])
                }),
            Formula(
                id: "range", topic: .stats, title: "المدى",
                expression: "المدى = أكبر قيمة − أصغر قيمة",
                explanation: "يقيس مدى تشتت البيانات. ابحث عن أكبر عدد وأصغر عدد ثم اطرح. انتبه للأعداد السالبة: طرح السالب يعني الجمع.",
                trap: "طرح العددين الأولين في القائمة بدل أكبر وأصغر قيمة، أو الخطأ في طرح عدد سالب.",
                gen: { d in
                    switch d {
                    case .easy:
                        let nums = Array((1...60).shuffled().prefix(5))
                        let mx = nums.max() ?? 0, mn = nums.min() ?? 0
                        return .int(
                            "ما مدى الأعداد: \(list(nums))؟",
                            steps: ["أكبر قيمة \(mx) وأصغر قيمة \(mn): " + m("\(mx) − \(mn) = \(mx - mn)")],
                            value: mx - mn, traps: [abs(nums[0] - nums[1]), mx, mx + mn])
                    case .medium:
                        var nums = Array((1...40).shuffled().prefix(4))
                        nums.append(-rnd(3...20))
                        nums.shuffle()
                        let mx = nums.max() ?? 0, mn = nums.min() ?? 0
                        return .int(
                            "ما مدى الأعداد: \(list(nums))؟",
                            steps: ["أكبر قيمة \(mx) وأصغر قيمة " + m("\(mn)".replacingOccurrences(of: "-", with: "−")),
                                    "نطرح: " + m("\(mx) − (−\(-mn)) = \(mx) + \(-mn) = \(mx - mn)")],
                            value: mx - mn, traps: [mx + mn, mx, -mn])
                    case .hard:
                        let mn = rnd(5...30)
                        let r = rnd(10...50)
                        return .int(
                            "مجموعة من الأعداد مداها \(r) وأصغر قيمة فيها \(mn). ما أكبر قيمة فيها؟",
                            steps: ["المدى = الأكبر − الأصغر، إذن الأكبر = المدى + الأصغر",
                                    "نعوّض: " + m("\(r) + \(mn) = \(r + mn)")],
                            value: r + mn, traps: [r - mn, r, mn * 2 + r])
                    }
                }),
            Formula(
                id: "probability", topic: .stats, title: "الاحتمال البسيط",
                expression: "الاحتمال = عدد الحالات المناسبة ÷ عدد الحالات الكلية",
                explanation: "الاحتمال دائماً بين 0 و1. مجموع احتمالات كل الحالات الممكنة = 1. احتمال عدم وقوع الحدث = 1 − احتمال وقوعه.",
                trap: "القسمة على عدد الحالات غير المناسبة بدل الكلية.",
                gen: { d in
                    let red = rnd(3...9)
                    let blue = rnd(3...9)
                    let green = rnd(3...9)
                    let total = red + blue + green
                    let bag = "كيس فيه \(red) كرات حمراء و\(blue) كرات زرقاء و\(green) كرات خضراء. سُحبت كرة واحدة عشوائياً، "
                    let s0 = "عدد الحالات الكلية: " + m("\(red) + \(blue) + \(green) = \(total)")
                    switch d {
                    case .easy:
                        let ans = frac(red, total)
                        return .text(
                            bag + "ما احتمال أن تكون حمراء؟",
                            steps: [s0, "الاحتمال: " + m("\(red) ÷ \(total) = \(ans)")],
                            answer: m(ans),
                            traps: distinct(m(ans), [m(frac(red, blue + green)), m(frac(blue + green, total)), m(frac(1, 3)), m(frac(red, total + 1)), m(frac(red + 1, total))]),
                            numeric: Double(red) / Double(total))
                    case .medium:
                        let ans = frac(red + blue, total)
                        return .text(
                            bag + "ما احتمال أن تكون حمراء أو زرقاء؟",
                            steps: [s0, "الحالات المناسبة: " + m("\(red) + \(blue) = \(red + blue)"),
                                    "الاحتمال: " + m("\(red + blue) ÷ \(total) = \(ans)")],
                            answer: m(ans),
                            traps: distinct(m(ans), [m(frac(red, total)), m(frac(red + blue, green)), m(frac(green, total)), m(frac(red * blue, total * total)), m(frac(red + blue, total + 1))]),
                            numeric: Double(red + blue) / Double(total))
                    case .hard:
                        let ans = frac(blue + green, total)
                        return .text(
                            bag + "ما احتمال ألّا تكون حمراء؟",
                            steps: [s0, "احتمال الحمراء: " + m("\(frac(red, total))"),
                                    "عدم الوقوع = 1 − الوقوع: " + m("1 − \(frac(red, total)) = \(ans)")],
                            answer: m(ans),
                            traps: distinct(m(ans), [m(frac(red, total)), m(frac(blue + green, red)), m(frac(1, 2)), m(frac(green, total)), m(frac(blue + green, total + 1))]),
                            numeric: Double(blue + green) / Double(total))
                    }
                }),
            Formula(
                id: "combinations", topic: .stats, title: "التوافيق (الاختيار)",
                expression: "ق(ن، ر) = ن! ÷ (ر! × (ن − ر)!)",
                explanation: "نستعمل التوافيق عندما لا يهم الترتيب (لجنة، فريق، مصافحة). اكتب البسط بعدد ر من العوامل المتتالية تنازلياً، والمقام ر!. وعند الاختيار من مجموعتين نضرب عدد الطرق.",
                trap: "استعمال التباديل (الترتيب مهم) في مسألة لا يهم فيها الترتيب، فتحصل على عدد أكبر من الصحيح.",
                gen: { d in
                    switch d {
                    case .easy:
                        let n = rnd(4...9)
                        let res = comb(n, 2)
                        return .int(
                            "في حفل \(n) أشخاص، صافح كل شخص الآخرين مرة واحدة. كم مصافحة حدثت؟",
                            steps: ["كل مصافحة اختيار شخصين والترتيب لا يهم: " + m("ق(\(n)، 2) = \(n) × \(n - 1) ÷ 2 = \(res)")],
                            value: res, traps: [n * (n - 1), n * 2, res + n])
                    case .medium:
                        let n = rnd(5...9)
                        let r = 3
                        let res = comb(n, r)
                        return .int(
                            "تريد تكوين لجنة من \(r) طلاب من بين \(n) طلاب. كم لجنة مختلفة يمكن تكوينها؟",
                            steps: ["الترتيب لا يهم، فنستعمل التوافيق: " + m("(\(n) × \(n - 1) × \(n - 2)) ÷ (3 × 2 × 1) = \(res)")],
                            value: res, traps: [n * (n - 1) * (n - 2), n * r, comb(n, 2)])
                    case .hard:
                        let men = rnd(4...6), women = rnd(3...5)
                        let a = pick([2, 3]), b = pick([1, 2])
                        let cm = comb(men, a), cw = comb(women, b)
                        return .int(
                            "يراد اختيار لجنة من \(a) رجال و\(b == 1 ? "امرأة واحدة" : "امرأتين") من بين \(men) رجال و\(women) نساء. كم لجنة ممكنة؟",
                            steps: ["اختيار الرجال: " + m("ق(\(men)، \(a)) = \(cm)"),
                                    "اختيار النساء: " + m("ق(\(women)، \(b)) = \(cw)"),
                                    "نضرب عدد الطرق: " + m("\(cm) × \(cw) = \(cm * cw)")],
                            value: cm * cw, traps: [cm + cw, comb(men + women, a + b), cm * cw * 2])
                    }
                }),
            Formula(
                id: "permutations", topic: .stats, title: "الترتيب (المضروب)",
                expression: "عدد طرق ترتيب ن عنصر = ن! = ن × (ن−1) × … × 1",
                explanation: "عند ترتيب عناصر مختلفة في صف: لأول مكان ن خيارات، وللثاني ن−1، وهكذا. ولاختيار ر عناصر مرتبة من ن: ن × (ن−1) × … (ر عوامل). وإذا ثُبّت عنصر في مكانه نرتّب الباقي فقط.",
                trap: "الخلط بين الترتيب (يهم) والاختيار (لا يهم).",
                gen: { d in
                    switch d {
                    case .easy:
                        let n = rnd(3...5)
                        let f = fact(n)
                        let parts = (1...n).reversed().map { String($0) }.joined(separator: " × ")
                        return .int(
                            "بكم طريقة يمكن ترتيب \(n) أشخاص في صف واحد؟",
                            steps: ["نستعمل المضروب: " + m("\(n)! = \(parts) = \(f)")],
                            value: f, traps: [n * n, n * (n - 1), n * (n + 1) / 2])
                    case .medium:
                        let n = rnd(5...10)
                        let res = n * (n - 1)
                        return .int(
                            "بكم طريقة يمكن اختيار رئيس ونائب له من بين \(n) أشخاص؟",
                            steps: ["الترتيب مهم (رئيس ثم نائب): للرئيس \(n) خيارات وللنائب \(n - 1)",
                                    "نضرب: " + m("\(n) × \(n - 1) = \(res)")],
                            value: res, traps: [comb(n, 2), n * 2, n * n])
                    case .hard:
                        let n = rnd(4...6)
                        let res = fact(n - 1)
                        return .int(
                            "بكم طريقة يمكن ترتيب \(n) كتب مختلفة على رف إذا كان كتاب معيّن يجب أن يكون أولاً؟",
                            steps: ["نثبّت الكتاب المعيّن في المكان الأول",
                                    "نرتّب الباقي: " + m("(\(n) − 1)! = \(n - 1)! = \(res)")],
                            value: res, traps: [fact(n), n - 1, fact(n) / 2])
                    }
                })
        ]
    }
}

/// المضروب.
func fact(_ n: Int) -> Int {
    n <= 1 ? 1 : (2...n).reduce(1, *)
}
