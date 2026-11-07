import Foundation

extension Store {

    // MARK: - الحفظ

    static var progressURL: URL {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return dir.appendingPathComponent("progress.json")
    }

    static func makeEncoder() -> JSONEncoder {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        e.outputFormatting = [.sortedKeys]
        return e
    }

    static func makeDecoder() -> JSONDecoder {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }

    static func loadProgress() -> ProgressData {
        guard let data = try? Data(contentsOf: progressURL),
              let p = try? makeDecoder().decode(ProgressData.self, from: data) else { return ProgressData() }
        return p
    }

    func saveProgress() {
        guard let data = try? Store.makeEncoder().encode(progress) else { return }
        try? data.write(to: Store.progressURL, options: .atomic)
    }

    // MARK: - تسجيل الإجابات

    /// يسجّل إجابة من التمرين أو الاختبار: الإحصائيات اليومية والباب والبطاقة ودفتر الأخطاء.
    func logAnswer(formula: Formula, correct: Bool, seconds: Double?, example: Example, given: String, level: Difficulty, source: String) {
        record(formula.id, correct: correct)
        var p = progress
        let key = DayKey.key(Date())
        var day = p.days[key] ?? DayStat()
        day.answered += 1
        if correct { day.correct += 1 }
        var topic = p.topics[formula.topic.rawValue] ?? TopicStat()
        topic.answered += 1
        if correct { topic.correct += 1 }
        if let s = seconds, s > 0 {
            day.seconds += s
            day.timed += 1
            topic.seconds += s
            topic.timed += 1
        }
        p.days[key] = day
        p.topics[formula.topic.rawValue] = topic
        if !correct {
            p.cards[formula.id] = Leitner.lapse(p.cards[formula.id] ?? CardState())
            let m = Mistake(formulaID: formula.id, level: level, problem: example.problem, yourAnswer: given,
                            correctAnswer: example.answer, steps: example.steps, source: source)
            p.mistakes.insert(m, at: 0)
            if p.mistakes.count > ProgressData.mistakeLimit {
                p.mistakes = Array(p.mistakes.prefix(ProgressData.mistakeLimit))
            }
        }
        progress = p
    }

    // MARK: - المراجعة المتباعدة

    /// البطاقات المستحقة الآن (الأضعف أولاً).
    func dueFormulas(now: Date = Date()) -> [Formula] {
        FormulaData.all
            .filter { f in progress.cards[f.id].map { $0.due <= now } ?? false }
            .sorted { a, b in
                let sa = progress.cards[a.id]!, sb = progress.cards[b.id]!
                return sa.box != sb.box ? sa.box < sb.box : sa.due < sb.due
            }
    }

    /// قوانين لم تُراجع بعد.
    func newFormulas() -> [Formula] {
        FormulaData.all.filter { progress.cards[$0.id] == nil }
    }

    var dueCount: Int { dueFormulas().count }

    func reviewCard(_ id: String, grade: ReviewGrade) {
        progress.cards[id] = Leitner.review(progress.cards[id] ?? CardState(), grade: grade)
    }

    // MARK: - الإتقان

    /// إتقان القانون من 0 إلى 1 (يحتاج 3 محاولات على الأقل للدرجة الكاملة).
    func formulaMastery(_ id: String) -> Double {
        let r = right[id] ?? 0, w = wrong[id] ?? 0
        guard r + w > 0 else { return 0 }
        let accuracy = Double(r) / Double(r + w)
        let confidence = min(1, Double(r + w) / 3)
        let box = Double(progress.cards[id]?.box ?? 0)
        let boxBonus = min(0.15, box * 0.03)
        return min(1, accuracy * confidence + boxBonus)
    }

    func topicMastery(_ topic: Topic) -> Double {
        let list = FormulaData.all.filter { $0.topic == topic }
        guard !list.isEmpty else { return 0 }
        return list.map { formulaMastery($0.id) }.reduce(0, +) / Double(list.count)
    }

    /// متوسط الإتقان في كل الأبواب.
    var readiness: Double {
        let all = Topic.allCases.map { topicMastery($0) }
        return all.reduce(0, +) / Double(max(1, all.count))
    }

    /// أضعف باب (الأقل إتقاناً).
    var weakestTopic: Topic? {
        Topic.allCases.min { topicMastery($0) < topicMastery($1) }
    }

    // MARK: - الأيام والخطة

    var today: DayStat { progress.days[DayKey.key(Date())] ?? DayStat() }

    var streak: Int { DayKey.streak(progress.days) }

    var daysToExam: Int? {
        guard let date = progress.examDate else { return nil }
        let cal = Calendar.current
        let days = cal.dateComponents([.day], from: cal.startOfDay(for: Date()), to: cal.startOfDay(for: date)).day ?? 0
        return days >= 0 ? days : nil
    }

    /// متوسط الثواني لكل سؤال في باب (إذا كان المؤقت مفعّلاً سابقاً).
    func averageSeconds(_ topic: Topic) -> Double? {
        progress.topics[topic.rawValue]?.averageSeconds
    }

    // MARK: - الاختبارات والأخطاء

    func saveExam(_ record: ExamRecord) {
        var p = progress
        p.exams.insert(record, at: 0)
        if p.exams.count > ProgressData.examLimit { p.exams = Array(p.exams.prefix(ProgressData.examLimit)) }
        progress = p
    }

    func deleteMistake(_ id: UUID) {
        progress.mistakes.removeAll { $0.id == id }
    }

    func clearMistakes() {
        progress.mistakes = []
    }

    func deleteExam(_ id: UUID) {
        progress.exams.removeAll { $0.id == id }
    }

    // MARK: - النسخ الاحتياطي

    func makeBackup() -> BackupFile {
        BackupFile(favorites: Array(favorites).sorted(), right: right, wrong: wrong, progress: progress,
                   difficulty: difficulty.rawValue, answerMode: answerMode.rawValue, timingEnabled: timingEnabled)
    }

    func backupData() -> Data? {
        let e = Store.makeEncoder()
        e.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try? e.encode(makeBackup())
    }

    static func readBackup(_ data: Data) -> BackupFile? {
        guard let b = try? makeDecoder().decode(BackupFile.self, from: data), b.app == "QuduratPlus" else { return nil }
        return b
    }

    /// استرجاع: دمج مع الموجود أو استبدال كامل.
    func restore(_ b: BackupFile, merge: Bool) {
        if merge {
            favorites = favorites.union(b.favorites)
            right = BackupMerge.mergeCounts(right, b.right)
            wrong = BackupMerge.mergeCounts(wrong, b.wrong)
            progress = BackupMerge.merge(progress, b.progress)
        } else {
            favorites = Set(b.favorites)
            right = b.right
            wrong = b.wrong
            progress = b.progress
            difficulty = Difficulty(rawValue: b.difficulty) ?? difficulty
            answerMode = AnswerMode(rawValue: b.answerMode) ?? answerMode
            timingEnabled = b.timingEnabled
        }
        UserDefaults.standard.set(right, forKey: "right")
        UserDefaults.standard.set(wrong, forKey: "wrong")
    }

    /// يمسح الإحصائيات والتقدم (المفضلة والإعدادات تبقى).
    func resetProgress() {
        right = [:]
        wrong = [:]
        UserDefaults.standard.set(right, forKey: "right")
        UserDefaults.standard.set(wrong, forKey: "wrong")
        let examDate = progress.examDate
        let goal = progress.dailyGoal
        progress = ProgressData()
        progress.examDate = examDate
        progress.dailyGoal = goal
    }
}
