import Foundation

/// مستوى الصعوبة: يتحكم في حجم الأرقام وعدد خطوات الحل.
enum Difficulty: String, CaseIterable, Identifiable, Codable {
    case easy, medium, hard

    var id: String { rawValue }

    var title: String {
        switch self {
        case .easy: return "سهل"
        case .medium: return "متوسط"
        case .hard: return "صعب"
        }
    }
}

struct Example {
    var problem: String
    var steps: [String]
    var answer: String
    var numeric: Double? = nil
    /// إجابات خاطئة جاهزة بنفس شكل الإجابة (للأسئلة غير الرقمية أو الكسور).
    var traps: [String] = []
    /// قيم خاطئة تمثّل أخطاء شائعة (للأسئلة الرقمية).
    var trapValues: [Double] = []
    /// وحدة تُلحق بالرقم عند العرض (" سم²"، "%"، "π").
    var unit: String = ""
    /// بادئة رمزية قبل الرقم مثل "س = ".
    var prefix: String = ""
    /// خيارات ثابتة (تشمل الإجابة الصحيحة) عندما يكون السؤال نفسه «أيّ مما يلي».
    var fixedOptions: [String]? = nil

    /// عرض قيمة رقمية بنفس شكل الإجابة.
    func display(_ value: Double) -> String {
        let core = prefix + fmt(value)
        if prefix.isEmpty && value >= 0 { return core + unit }
        return m(core.replacingOccurrences(of: "-", with: "−")) + unit
    }

    /// مثال إجابته رقم (عشري أو صحيح).
    static func num(_ problem: String, steps: [String], value: Double, unit: String = "",
                    prefix: String = "", traps: [Double] = []) -> Example {
        var e = Example(problem: problem, steps: steps, answer: "", numeric: value)
        e.unit = unit
        e.prefix = prefix
        e.trapValues = traps
        e.answer = e.display(value)
        return e
    }

    /// مثال إجابته عدد صحيح.
    static func int(_ problem: String, steps: [String], value: Int, unit: String = "",
                    prefix: String = "", traps: [Int] = []) -> Example {
        num(problem, steps: steps, value: Double(value), unit: unit, prefix: prefix, traps: traps.map { Double($0) })
    }

    /// مثال إجابته نص (عبارة جبرية، متباينة، كسر...).
    static func text(_ problem: String, steps: [String], answer: String, traps: [String], numeric: Double? = nil) -> Example {
        var e = Example(problem: problem, steps: steps, answer: answer, numeric: numeric)
        e.traps = traps
        return e
    }
}

enum Topic: String, CaseIterable, Identifiable {
    case ratios = "الحساب والنسب"
    case algebra = "الجبر والمعادلات"
    case geometry = "الهندسة"
    case motion = "السرعة والزمن والعمل"
    case stats = "الإحصاء والاحتمالات"
    case sequences = "المتتابعات"
    case numbers = "الأعداد"
    case comparison = "المقارنات"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .ratios: return "percent"
        case .algebra: return "x.squareroot"
        case .geometry: return "triangle"
        case .motion: return "speedometer"
        case .stats: return "chart.bar"
        case .sequences: return "number"
        case .numbers: return "divide"
        case .comparison: return "arrow.left.arrow.right"
        }
    }
}

struct Formula: Identifiable {
    let id: String
    let topic: Topic
    let title: String
    let expression: String
    var symbolic: Bool = false
    let explanation: String
    let trap: String
    let gen: (Difficulty) -> Example

    /// نص القانون جاهز للعرض (الرمزي يُعرض من اليسار لليمين).
    var shown: String {
        symbolic ? "\u{2066}\(expression)\u{2069}" : expression
    }

    /// مثال جديد بمستوى الصعوبة المطلوب.
    func example(_ level: Difficulty = .medium) -> Example {
        gen(level)
    }
}
