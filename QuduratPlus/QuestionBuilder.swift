import Foundation

/// سؤال اختيار من متعدد بأسلوب القدرات (أ، ب، ج، د).
struct ChoiceQuestion {
    let options: [String]
    let correctIndex: Int

    static let letters = ["أ", "ب", "ج", "د"]
}

/// يبني خيارات ذكية من الأخطاء الشائعة لكل مثال.
enum QuestionBuilder {

    /// نص الخيار الأخير المعتاد في اختبارات القدرات.
    static let noneText = "ليس أيا مما سبق"

    /// نسبة الأسئلة التي يظهر فيها خيار «ليس أيا مما سبق» (كما في مذكرة الاختبار).
    static let noneRate = 0.22

    /// أربعة خيارات تشمل الإجابة الصحيحة، أو nil إذا تعذّر بناء خيارات كافية.
    /// أحياناً يُستبدل الخيار الأخير بـ «ليس أيا مما سبق»: إما كمشتّت، أو كإجابة صحيحة
    /// (وعندها تكون القيمة المحسوبة غير موجودة بين الخيارات الثلاثة الأخرى).
    static func choices(for example: Example) -> ChoiceQuestion? {
        guard let base = baseChoices(for: example) else { return nil }
        if example.fixedOptions != nil { return base }
        if Double.random(in: 0..<1) >= noneRate { return base }

        var options = base.options
        var correct = base.correctIndex
        if Bool.random() {
            options.remove(at: correct)
            options.append(noneText)
            correct = options.count - 1
        } else {
            let wrongIndexes = options.indices.filter { $0 != correct }
            guard let drop = wrongIndexes.randomElement() else { return base }
            options.remove(at: drop)
            if drop < correct { correct -= 1 }
            options.append(noneText)
        }
        return ChoiceQuestion(options: options, correctIndex: correct)
    }

    /// الخيارات الأساسية قبل إضافة «ليس أيا مما سبق».
    private static func baseChoices(for example: Example) -> ChoiceQuestion? {
        // 1) الخيارات ثابتة في نص السؤال («أيّ مما يلي»).
        if let fixed = example.fixedOptions {
            let options = Array(uniqued(fixed).prefix(4))
            guard options.count >= 2, let index = options.firstIndex(of: normalizedAnswer(example)) else { return nil }
            return ChoiceQuestion(options: options, correctIndex: index)
        }

        // 2) إجابة نصية (عبارة جبرية، متباينة، كسر) مع أخطاء جاهزة.
        let textTraps = distinct(example.answer, example.traps)
        if textTraps.count >= 3 {
            var options = [example.answer] + Array(textTraps.prefix(3))
            options.shuffle()
            guard let index = options.firstIndex(of: example.answer) else { return nil }
            return ChoiceQuestion(options: options, correctIndex: index)
        }

        // 3) إجابة رقمية: الأخطاء الشائعة أولاً، ثم مشتتات قريبة بنفس الشكل.
        guard let value = example.numeric, value.isFinite else { return nil }
        let wrong = numericDistractors(value: value, traps: example.trapValues)
        guard wrong.count == 3 else { return nil }
        let values = ([value] + wrong).sorted()
        let options = values.map { example.display($0) }
        guard Set(options).count == 4, let index = values.firstIndex(where: { abs($0 - value) < 0.000001 }) else { return nil }
        return ChoiceQuestion(options: options, correctIndex: index)
    }

    /// ثلاث قيم خاطئة: من الأخطاء الشائعة أولاً، ثم قيم قريبة.
    static func numericDistractors(value: Double, traps: [Double]) -> [Double] {
        var out: [Double] = []
        let isInt = abs(value - value.rounded()) < 0.000001

        func accept(_ x: Double) -> Bool {
            guard x.isFinite, isClean(x) else { return false }
            if abs(x - value) < 0.011 { return false }
            if value >= 0 && x < 0 { return false }
            if value > 0 && x == 0 && value >= 5 { return false }
            if out.contains(where: { abs($0 - x) < 0.011 }) { return false }
            // نتجنب خياراً بعيداً جداً حتى لا يكون استبعاده سهلاً.
            if abs(value) >= 1 && abs(x) > abs(value) * 60 + 50 { return false }
            return true
        }

        for t in traps.shuffled() where out.count < 3 {
            let x = isInt ? t : (t * 100).rounded() / 100
            if accept(x) { out.append(x) }
        }

        let step = niceStep(value)
        var candidates: [Double] = [value + step, value - step, value + 2 * step, value - 2 * step,
                                    value * 2, value + 3 * step, value - 3 * step]
        if isInt, Int(value.rounded()) % 2 == 0 { candidates.append(value / 2) }
        if !isInt {
            candidates += [value.rounded(), value + 0.5, value - 0.5]
        }
        for c in candidates.shuffled() where out.count < 3 {
            if accept(c) { out.append(c) }
        }
        var k = 4.0
        while out.count < 3 && k < 40 {
            let c = value + k * step
            if accept(c) { out.append(c) }
            k += 1
        }
        return out
    }

    /// خطوة «طبيعية» حسب حجم العدد (1، 2، 5، 10، 20، 50...).
    static func niceStep(_ value: Double) -> Double {
        let a = abs(value)
        if a < 1 { return 0.1 }
        if a < 12 { return 1 }
        if a < 40 { return 2 }
        if a < 120 { return 5 }
        if a < 400 { return 10 }
        if a < 1200 { return 50 }
        if a < 5000 { return 100 }
        return (a / 20).rounded()
    }

    /// يحذف التكرار مع الإبقاء على الترتيب (الخيارات الثابتة مرتبة كما في نص السؤال).
    private static func uniqued(_ items: [String]) -> [String] {
        var out: [String] = []
        for s in items where !out.contains(s) { out.append(s) }
        return out
    }

    /// شكل الإجابة كما يظهر في الخيارات الثابتة.
    private static func normalizedAnswer(_ example: Example) -> String {
        if let v = example.numeric { return fmt(v) }
        return example.answer
    }

    /// هل الإجابة المكتوبة صحيحة؟ (رقم أو كسر بأرقام عربية أو إنجليزية).
    static func isCorrect(_ input: String, for example: Example) -> Bool? {
        guard let target = example.numeric, let v = parseNumber(input) else { return nil }
        return abs(v - target) < 0.011
    }
}
