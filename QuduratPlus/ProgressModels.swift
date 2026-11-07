import Foundation

// MARK: - سجل التقدم المحفوظ (ملف JSON محلي)

/// إحصائية يوم واحد.
struct DayStat: Codable, Equatable {
    var answered = 0
    var correct = 0
    /// مجموع الثواني للأسئلة المؤقتة فقط.
    var seconds: Double = 0
    var timed = 0
}

/// إحصائية باب.
struct TopicStat: Codable, Equatable {
    var answered = 0
    var correct = 0
    var seconds: Double = 0
    var timed = 0

    var averageSeconds: Double? { timed > 0 ? seconds / Double(timed) : nil }
}

/// حالة بطاقة في المراجعة المتباعدة (نظام صناديق لايتنر).
struct CardState: Codable, Equatable {
    var box = 0
    var due = Date()
    var lastReview: Date?
    var reviews = 0
}

/// سؤال أخطأت فيه (دفتر الأخطاء).
struct Mistake: Codable, Identifiable, Equatable {
    var id = UUID()
    var date = Date()
    var formulaID: String
    var level: Difficulty
    var problem: String
    var yourAnswer: String
    var correctAnswer: String
    var steps: [String]
    var source: String
}

/// سؤال واحد داخل اختبار محفوظ.
struct ExamItemRecord: Codable, Equatable {
    var formulaID: String
    var problem: String
    var options: [String]
    var correctIndex: Int
    var picked: Int?
    var seconds: Double?
    var steps: [String]
}

/// نتيجة اختبار محاكي.
struct ExamRecord: Codable, Identifiable, Equatable {
    var id = UUID()
    var date = Date()
    var total: Int
    var correct: Int
    var timeLimit: Double
    var timeUsed: Double
    var level: String
    var items: [ExamItemRecord]

    var percent: Int { total > 0 ? Int((Double(correct) / Double(total) * 100).rounded()) : 0 }
}

struct ProgressData: Codable, Equatable {
    var version = 1
    var days: [String: DayStat] = [:]
    var topics: [String: TopicStat] = [:]
    var cards: [String: CardState] = [:]
    var mistakes: [Mistake] = []
    var exams: [ExamRecord] = []
    var examDate: Date?
    var dailyGoal = 20

    static let mistakeLimit = 200
    static let examLimit = 50
}

// MARK: - المراجعة المتباعدة

enum ReviewGrade {
    case again, good, easy
}

enum Leitner {
    /// الفاصل بالأيام لكل صندوق.
    static let intervals = [0, 1, 2, 4, 8, 16, 30]

    static var maxBox: Int { intervals.count - 1 }

    /// الحالة الجديدة بعد التقييم.
    static func review(_ state: CardState, grade: ReviewGrade, now: Date = Date()) -> CardState {
        var s = state
        switch grade {
        case .again: s.box = 0
        case .good: s.box = min(maxBox, s.box + 1)
        case .easy: s.box = min(maxBox, s.box + 2)
        }
        let days = intervals[s.box]
        if days == 0 {
            s.due = now.addingTimeInterval(10 * 60)
        } else {
            let start = Calendar.current.startOfDay(for: now)
            s.due = Calendar.current.date(byAdding: .day, value: days, to: start) ?? now
        }
        s.lastReview = now
        s.reviews += 1
        return s
    }

    /// خطأ في التمرين أو الاختبار يعيد البطاقة للصندوق الأول لتظهر قريباً.
    static func lapse(_ state: CardState, now: Date = Date()) -> CardState {
        var s = state
        s.box = 0
        s.due = now
        return s
    }
}

// MARK: - مساعدات التاريخ

enum DayKey {
    private static let formatter: DateFormatter = {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    static func key(_ date: Date) -> String { formatter.string(from: date) }

    static func date(_ key: String) -> Date? { formatter.date(from: key) }

    /// مفاتيح آخر n يوم (الأقدم أولاً).
    static func lastDays(_ n: Int, from now: Date = Date()) -> [String] {
        let cal = Calendar.current
        return (0..<n).reversed().compactMap { cal.date(byAdding: .day, value: -$0, to: now) }.map(key)
    }

    /// عدد الأيام المتتالية التي فيها نشاط (اليوم أو أمس كبداية).
    static func streak(_ days: [String: DayStat], now: Date = Date()) -> Int {
        let cal = Calendar.current
        var cursor = now
        if (days[key(cursor)]?.answered ?? 0) == 0 {
            guard let y = cal.date(byAdding: .day, value: -1, to: cursor), (days[key(y)]?.answered ?? 0) > 0 else { return 0 }
            cursor = y
        }
        var count = 0
        while (days[key(cursor)]?.answered ?? 0) > 0 {
            count += 1
            guard let prev = cal.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = prev
        }
        return count
    }
}

// MARK: - النسخة الاحتياطية

struct BackupFile: Codable {
    var app = "QuduratPlus"
    var version = 1
    var createdAt = Date()
    var favorites: [String]
    var right: [String: Int]
    var wrong: [String: Int]
    var progress: ProgressData
    var difficulty: String
    var answerMode: String
    var timingEnabled: Bool
}

enum BackupMerge {
    /// يدمج نسختين دون تكرار: يأخذ الأكبر في العدادات، ويوحّد القوائم بالمعرّف.
    static func merge(_ local: ProgressData, _ incoming: ProgressData) -> ProgressData {
        var out = local
        for (k, v) in incoming.days {
            let mine = out.days[k] ?? DayStat()
            out.days[k] = v.answered > mine.answered ? v : mine
        }
        for (k, v) in incoming.topics {
            let mine = out.topics[k] ?? TopicStat()
            out.topics[k] = v.answered > mine.answered ? v : mine
        }
        for (k, v) in incoming.cards {
            guard let mine = out.cards[k] else { out.cards[k] = v; continue }
            let a = mine.lastReview ?? .distantPast, b = v.lastReview ?? .distantPast
            if b > a { out.cards[k] = v }
        }
        let mistakeIDs = Set(out.mistakes.map(\.id))
        out.mistakes += incoming.mistakes.filter { !mistakeIDs.contains($0.id) }
        out.mistakes.sort { $0.date > $1.date }
        out.mistakes = Array(out.mistakes.prefix(ProgressData.mistakeLimit))
        let examIDs = Set(out.exams.map(\.id))
        out.exams += incoming.exams.filter { !examIDs.contains($0.id) }
        out.exams.sort { $0.date > $1.date }
        out.exams = Array(out.exams.prefix(ProgressData.examLimit))
        if out.examDate == nil { out.examDate = incoming.examDate }
        return out
    }

    static func mergeCounts(_ a: [String: Int], _ b: [String: Int]) -> [String: Int] {
        var out = a
        for (k, v) in b { out[k] = max(out[k] ?? 0, v) }
        return out
    }
}
