import SwiftUI
import Combine

// MARK: - إعداد الاختبار المحاكي

enum ExamLevel: String, CaseIterable, Identifiable {
    case mixed, easy, medium, hard

    var id: String { rawValue }

    var title: String {
        switch self {
        case .mixed: return "متنوّع"
        case .easy: return "سهل"
        case .medium: return "متوسط"
        case .hard: return "صعب"
        }
    }

    func pick() -> Difficulty {
        switch self {
        case .mixed: return [Difficulty.easy, .medium, .medium, .hard].randomElement() ?? .medium
        case .easy: return .easy
        case .medium: return .medium
        case .hard: return .hard
        }
    }
}

struct ExamConfig {
    var count = 24
    var minutes = 25
    var level: ExamLevel = .mixed
    var topics: Set<Topic> = Set(Topic.allCases)
}

struct ExamQuestion: Identifiable {
    let id = UUID()
    let formula: Formula
    let level: Difficulty
    let example: Example
    let choice: ChoiceQuestion
    var picked: Int? = nil
    var flagged = false
    var seconds: Double = 0
}

enum ExamFactory {
    /// يوزّع الأسئلة على الأبواب المختارة بدون تكرار القانون نفسه قدر الإمكان.
    static func build(_ config: ExamConfig) -> [ExamQuestion] {
        let pool = FormulaData.all.filter { config.topics.contains($0.topic) }
        guard !pool.isEmpty else { return [] }
        var order: [Formula] = []
        while order.count < config.count {
            order += pool.shuffled()
        }
        var out: [ExamQuestion] = []
        for f in order.prefix(config.count) {
            for _ in 0..<5 {
                let level = config.level.pick()
                let e = f.example(level)
                if let q = QuestionBuilder.choices(for: e) {
                    out.append(ExamQuestion(formula: f, level: level, example: e, choice: q))
                    break
                }
            }
        }
        return out
    }
}

// MARK: - تبويب الاختبار

struct ExamHomeView: View {
    @EnvironmentObject var store: Store
    @State private var config = ExamConfig()
    @State private var session: ExamSessionData?
    @State private var result: ExamRecord?

    private let counts = [10, 15, 20, 24, 30, 40]
    private let minuteOptions = [10, 15, 20, 25, 30, 45, 60]

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("عدد الأسئلة", selection: $config.count) {
                        ForEach(counts, id: \.self) { Text("\($0)").tag($0) }
                    }
                    Picker("الوقت (دقيقة)", selection: $config.minutes) {
                        ForEach(minuteOptions, id: \.self) { Text("\($0)").tag($0) }
                    }
                    Picker("المستوى", selection: $config.level) {
                        ForEach(ExamLevel.allCases) { Text($0.title).tag($0) }
                    }
                } header: {
                    Text("إعداد الاختبار")
                } footer: {
                    Text("مثل الاختبار الحقيقي: اختيار من متعدد، لا تظهر الإجابات إلا بعد الإنهاء، وينتهي تلقائياً عند انتهاء الوقت.")
                }

                Section {
                    ForEach(Topic.allCases) { t in
                        Button {
                            if config.topics.contains(t) {
                                if config.topics.count > 1 { config.topics.remove(t) }
                            } else {
                                config.topics.insert(t)
                            }
                            Haptics.tap()
                        } label: {
                            HStack {
                                Label(t.rawValue, systemImage: t.icon)
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: config.topics.contains(t) ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(config.topics.contains(t) ? Theme.accent : .secondary)
                            }
                        }
                        .accessibilityAddTraits(config.topics.contains(t) ? .isSelected : [])
                    }
                } header: {
                    HStack {
                        Text("الأبواب")
                        Spacer()
                        Button(config.topics.count == Topic.allCases.count ? "باب واحد" : "الكل") {
                            config.topics = config.topics.count == Topic.allCases.count ? [Topic.allCases[0]] : Set(Topic.allCases)
                        }
                        .font(.caption)
                    }
                }

                Section {
                    Button {
                        let questions = ExamFactory.build(config)
                        guard !questions.isEmpty else { return }
                        session = ExamSessionData(questions: questions, config: config)
                    } label: {
                        Label("ابدأ الاختبار", systemImage: "play.fill")
                            .frame(maxWidth: .infinity)
                            .font(.headline)
                    }
                    .buttonStyle(.borderedProminent)
                    .listRowBackground(Color.clear)
                }

                Section("الاختبارات السابقة") {
                    if store.progress.exams.isEmpty {
                        Text("نتائج اختباراتك تظهر هنا مع تحليل نقاط القوة والضعف.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(store.progress.exams) { r in
                            NavigationLink(destination: ExamResultView(record: r)) {
                                ExamHistoryRow(record: r)
                            }
                        }
                        .onDelete { offsets in
                            for i in offsets { store.deleteExam(store.progress.exams[i].id) }
                        }
                    }
                }
            }
            .navigationTitle("اختبار محاكي")
            .fullScreenCover(item: $session) { data in
                ExamSessionView(data: data) { record in
                    session = nil
                    result = record
                }
                .environmentObject(store)
                .environment(\.layoutDirection, .rightToLeft)
            }
            .onChange(of: store.tab) { _ in result = nil }
            .sheet(item: $result) { r in
                NavigationStack {
                    ExamResultView(record: r)
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) { Button("تم") { result = nil } }
                        }
                }
            }
        }
    }
}

struct ExamHistoryRow: View {
    let record: ExamRecord

    var body: some View {
        HStack(spacing: 12) {
            ScoreRing(value: Double(record.percent) / 100, size: 44, lineWidth: 5)
            VStack(alignment: .leading, spacing: 3) {
                Text("\(record.correct) من \(record.total) • \(record.level)").font(.subheadline.bold())
                Text(record.date.formatted(date: .abbreviated, time: .shortened) + " • " + mmss(record.timeUsed))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct ExamSessionData: Identifiable {
    let id = UUID()
    var questions: [ExamQuestion]
    let config: ExamConfig
}

// MARK: - جلسة الاختبار

struct ExamSessionView: View {
    @EnvironmentObject var store: Store
    let onFinish: (ExamRecord) -> Void
    @State private var questions: [ExamQuestion]
    private let config: ExamConfig
    @State private var startedAt = Date()
    @State private var index = 0
    @State private var now = Date()
    @State private var enteredAt = Date()
    @State private var showOverview = false
    @State private var confirmFinish = false
    @State private var finished = false

    private let ticker = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init(data: ExamSessionData, onFinish: @escaping (ExamRecord) -> Void) {
        _questions = State(initialValue: data.questions)
        config = data.config
        self.onFinish = onFinish
    }

    private var limit: Double { Double(config.minutes * 60) }
    private var remaining: Double { max(0, limit - now.timeIntervalSince(startedAt)) }
    private var answeredCount: Int { questions.filter { $0.picked != nil }.count }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                header
                ScrollView {
                    if questions.indices.contains(index) {
                        questionView(questions[index])
                            .padding()
                            .frame(maxWidth: 700)
                            .frame(maxWidth: .infinity)
                    }
                }
                footer
            }
            .navigationTitle("سؤال \(index + 1) من \(questions.count)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("إنهاء") { confirmFinish = true }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button { showOverview = true } label: { Image(systemName: "square.grid.3x3") }
                        .accessibilityLabel("كل الأسئلة")
                }
            }
            .confirmationDialog(confirmText, isPresented: $confirmFinish, titleVisibility: .visible) {
                Button("إنهاء وعرض النتيجة", role: .destructive) { finish() }
                Button("متابعة الاختبار", role: .cancel) {}
            }
            .sheet(isPresented: $showOverview) { overview }
            .onReceive(ticker) { value in
                now = value
                if remaining <= 0 && !finished { finish() }
            }
            .interactiveDismissDisabled()
        }
    }

    private var confirmText: String {
        let left = questions.count - answeredCount
        return left > 0 ? "باقي \(left) سؤال بدون إجابة. إنهاء الاختبار؟" : "إنهاء الاختبار؟"
    }

    private var header: some View {
        VStack(spacing: 6) {
            HStack {
                Label(mmss(remaining), systemImage: "timer")
                    .font(.headline.monospacedDigit())
                    .foregroundColor(remaining < 60 ? .red : .primary)
                Spacer()
                Text("أجبت \(answeredCount) / \(questions.count)")
                    .font(.subheadline.monospacedDigit())
                    .foregroundColor(.secondary)
            }
            ProgressView(value: Double(answeredCount), total: Double(max(1, questions.count)))
                .tint(Theme.accent)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Theme.card)
    }

    private func questionView(_ q: ExamQuestion) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label(q.formula.topic.rawValue, systemImage: q.formula.topic.icon)
                    .font(.caption.bold())
                    .foregroundColor(Theme.accent)
                Spacer()
                if q.flagged {
                    Label("معلّم", systemImage: "flag.fill").font(.caption).foregroundColor(.orange)
                }
            }
            MathText(q.example.problem, style: .title3, weight: .medium)
                .fixedSize(horizontal: false, vertical: true)
                .card()
            ForEach(Array(q.choice.options.enumerated()), id: \.offset) { pair in
                let i = pair.offset
                Button {
                    questions[index].picked = i
                    Haptics.tap()
                } label: {
                    HStack(spacing: 12) {
                        Text(i < ChoiceQuestion.letters.count ? ChoiceQuestion.letters[i] : "\(i + 1)")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(Circle().fill(q.picked == i ? Theme.accent : Color.gray.opacity(0.5)))
                        MathLine(pair.element)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(12)
                    .background(q.picked == i ? Theme.accent.opacity(0.15) : Theme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(q.picked == i ? .isSelected : [])
                .keyboardShortcut(KeyEquivalent(Character(String(min(i + 1, 9)))), modifiers: [])
            }
        }
    }

    private var footer: some View {
        HStack(spacing: 12) {
            Button { go(index - 1) } label: {
                Label("السابق", systemImage: "chevron.right").frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(index == 0)
            .keyboardShortcut(.rightArrow, modifiers: [])

            Button {
                questions[index].flagged.toggle()
            } label: {
                Image(systemName: questions.indices.contains(index) && questions[index].flagged ? "flag.fill" : "flag")
            }
            .buttonStyle(.bordered)
            .tint(.orange)
            .accessibilityLabel("علّم للمراجعة")

            if index < questions.count - 1 {
                Button { go(index + 1) } label: {
                    Label("التالي", systemImage: "chevron.left").frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.leftArrow, modifiers: [])
            } else {
                Button { confirmFinish = true } label: {
                    Label("إنهاء", systemImage: "checkmark").frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .background(.bar)
    }

    private var overview: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 5), spacing: 10) {
                    ForEach(questions.indices, id: \.self) { i in
                        Button {
                            go(i)
                            showOverview = false
                        } label: {
                            ZStack(alignment: .topTrailing) {
                                Text("\(i + 1)")
                                    .font(.headline.monospacedDigit())
                                    .frame(maxWidth: .infinity, minHeight: 48)
                                    .background(questions[i].picked != nil ? Theme.accent.opacity(0.25) : Theme.card)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(i == index ? Theme.accent : .clear, lineWidth: 2))
                                if questions[i].flagged {
                                    Image(systemName: "flag.fill").font(.caption2).foregroundColor(.orange).padding(4)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
                HStack(spacing: 16) {
                    Label("مُجاب", systemImage: "square.fill").foregroundColor(Theme.accent.opacity(0.6))
                    Label("معلّم", systemImage: "flag.fill").foregroundColor(.orange)
                }
                .font(.caption)
            }
            .navigationTitle("الأسئلة")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("تم") { showOverview = false } }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func go(_ i: Int) {
        guard questions.indices.contains(i) else { return }
        trackTime()
        index = i
    }

    private func trackTime() {
        let t = Date()
        if questions.indices.contains(index) {
            questions[index].seconds += t.timeIntervalSince(enteredAt)
        }
        enteredAt = t
    }

    private func finish() {
        guard !finished else { return }
        finished = true
        trackTime()
        let used = min(limit, Date().timeIntervalSince(startedAt))
        var items: [ExamItemRecord] = []
        var correct = 0
        for q in questions {
            let ok = q.picked == q.choice.correctIndex
            if ok { correct += 1 }
            // الأسئلة المتروكة تُحسب خطأ في النتيجة فقط، ولا تُضاف لدفتر الأخطاء.
            if let p = q.picked {
                store.logAnswer(formula: q.formula, correct: ok, seconds: store.timingEnabled ? q.seconds : nil,
                                example: q.example, given: q.choice.options[p], level: q.level, source: "اختبار")
            }
            items.append(ExamItemRecord(formulaID: q.formula.id, problem: q.example.problem, options: q.choice.options,
                                        correctIndex: q.choice.correctIndex, picked: q.picked,
                                        seconds: store.timingEnabled ? q.seconds : nil, steps: q.example.steps))
        }
        let record = ExamRecord(total: questions.count, correct: correct, timeLimit: limit, timeUsed: used,
                                level: config.level.title, items: items)
        store.saveExam(record)
        if correct * 2 >= questions.count { Haptics.success() } else { Haptics.error() }
        onFinish(record)
    }
}

// MARK: - نتيجة الاختبار

struct ExamResultView: View {
    @EnvironmentObject var store: Store
    let record: ExamRecord
    @State private var expanded: Set<Int> = []

    private struct TopicResult: Identifiable {
        let topic: Topic
        let total: Int
        let correct: Int
        var id: String { topic.rawValue }
        var ratio: Double { total > 0 ? Double(correct) / Double(total) : 0 }
    }

    private var byTopic: [TopicResult] {
        var dict: [Topic: (Int, Int)] = [:]
        for item in record.items {
            guard let t = FormulaData.formula(id: item.formulaID)?.topic else { continue }
            var v = dict[t] ?? (0, 0)
            v.0 += 1
            if item.picked == item.correctIndex { v.1 += 1 }
            dict[t] = v
        }
        return dict.map { TopicResult(topic: $0.key, total: $0.value.0, correct: $0.value.1) }
            .sorted { $0.ratio > $1.ratio }
    }

    var body: some View {
        List {
            Section {
                HStack(spacing: 18) {
                    ScoreRing(value: Double(record.percent) / 100, size: 96, lineWidth: 10)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("\(record.percent)%").font(.largeTitle.bold())
                        Text("\(record.correct) صحيحة من \(record.total)").font(.subheadline)
                        Text("الوقت: " + mmss(record.timeUsed) + " من " + mmss(record.timeLimit))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        let timed = record.items.compactMap(\.seconds)
                        if !timed.isEmpty {
                            Text("متوسط السؤال: " + mmss(timed.reduce(0, +) / Double(timed.count)))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.vertical, 6)
            }

            Section {
                ForEach(byTopic) { r in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Label(r.topic.rawValue, systemImage: r.topic.icon)
                            Spacer()
                            Text("\(r.correct)/\(r.total)").font(.subheadline.monospacedDigit())
                        }
                        ProgressView(value: r.ratio).tint(color(r.ratio))
                        Text(verdict(r.ratio)).font(.caption).foregroundColor(color(r.ratio))
                    }
                    .padding(.vertical, 2)
                }
                if let weakest = byTopic.last, weakest.ratio < 0.75 {
                    Button {
                        store.practiceRequest = weakest.topic
                        store.tab = .practice
                    } label: {
                        Label("تمرّن على «\(weakest.topic.rawValue)»", systemImage: "pencil.circle")
                    }
                }
            } header: {
                Text("نقاط القوة والضعف")
            }

            Section("مراجعة الأسئلة") {
                ForEach(Array(record.items.enumerated()), id: \.offset) { pair in
                    reviewRow(pair.offset, pair.element)
                }
            }
        }
        .navigationTitle("نتيجة الاختبار")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func reviewRow(_ i: Int, _ item: ExamItemRecord) -> some View {
        let ok = item.picked == item.correctIndex
        return VStack(alignment: .leading, spacing: 8) {
            Button {
                if expanded.contains(i) { expanded.remove(i) } else { expanded.insert(i) }
            } label: {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: ok ? "checkmark.circle.fill" : (item.picked == nil ? "minus.circle.fill" : "xmark.circle.fill"))
                        .foregroundColor(ok ? .green : (item.picked == nil ? .gray : .red))
                    VStack(alignment: .leading, spacing: 3) {
                        MathText("\(i + 1). " + item.problem)
                            .foregroundColor(.primary)
                            .lineLimit(expanded.contains(i) ? nil : 2)
                        if let s = item.seconds {
                            Text("الوقت: " + mmss(s)).font(.caption2).foregroundColor(.secondary)
                        }
                    }
                    Spacer(minLength: 0)
                    Image(systemName: expanded.contains(i) ? "chevron.up" : "chevron.down").foregroundColor(.secondary)
                }
            }
            .buttonStyle(.plain)
            if expanded.contains(i) {
                ForEach(Array(item.options.enumerated()), id: \.offset) { opt in
                    HStack(spacing: 8) {
                        Text(opt.offset < ChoiceQuestion.letters.count ? ChoiceQuestion.letters[opt.offset] : "\(opt.offset + 1)")
                            .font(.caption.bold())
                        MathLine(opt.element, style: .subheadline)
                        Spacer(minLength: 0)
                        if opt.offset == item.correctIndex {
                            Image(systemName: "checkmark").foregroundColor(.green)
                        } else if opt.offset == item.picked {
                            Image(systemName: "xmark").foregroundColor(.red)
                        }
                    }
                    .font(.subheadline)
                }
                Divider()
                ForEach(Array(item.steps.enumerated()), id: \.offset) { step in
                    MathText("\(step.offset + 1). " + step.element, style: .footnote)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(.vertical, 2)
    }

    private func color(_ r: Double) -> Color {
        r >= 0.75 ? .green : (r >= 0.5 ? .orange : .red)
    }

    private func verdict(_ r: Double) -> String {
        r >= 0.75 ? "نقطة قوة" : (r >= 0.5 ? "يحتاج تثبيت" : "نقطة ضعف — راجع قوانين هذا الباب")
    }
}

/// دقائق:ثواني.
func mmss(_ seconds: Double) -> String {
    let s = max(0, Int(seconds.rounded()))
    return String(format: "%d:%02d", s / 60, s % 60)
}
