import SwiftUI

enum PracticeState {
    case pending, right, wrong, revealed
}

/// تبويب التمرين.
struct PracticeView: View {
    var body: some View {
        NavigationStack {
            PracticeSession(fixed: nil)
        }
    }
}

/// تمرين على قانون واحد (من دفتر الأخطاء أو صفحة القانون).
struct FocusedPracticeView: View {
    let formula: Formula

    var body: some View {
        PracticeSession(fixed: formula)
    }
}

struct PracticeSession: View {
    @EnvironmentObject var store: Store
    /// قانون ثابت للتمرين المركّز، أو nil لكل القوانين.
    let fixed: Formula?
    @State private var scope: Topic? = nil
    @State private var startedAt = Date()
    @State private var answeredSeconds: Double? = nil
    @State private var formula: Formula? = nil
    @State private var example = Example(problem: "", steps: [], answer: "")
    @State private var choice: ChoiceQuestion? = nil
    @State private var picked: Int? = nil
    @State private var input = ""
    @State private var state: PracticeState = .pending
    @State private var showSolution = false
    @State private var graded = false
    @State private var score = 0
    @State private var asked = 0
    @FocusState private var focused: Bool

    /// الاختيار من متعدد يُستعمل إذا اختاره المستخدم، أو إذا كانت الإجابة غير رقمية.
    private var usesChoices: Bool {
        guard choice != nil else { return false }
        return store.answerMode == .choices || example.numeric == nil || example.fixedOptions != nil
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                header
                controls

                if let f = formula {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Label(f.title, systemImage: f.topic.icon)
                                .font(.caption.bold())
                                .foregroundColor(Theme.accent)
                            Spacer()
                            Text(store.difficulty.title)
                                .font(.caption2.bold())
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Theme.accent.opacity(0.15))
                                .clipShape(Capsule())
                        }
                        MathText(example.problem, style: .title3, weight: .medium)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .card()

                    if usesChoices, let q = choice {
                        choicesView(q)
                    } else if example.numeric != nil && !showSolution {
                        answerBox
                    }

                    banner

                    if showSolution {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("الحل").font(.subheadline.bold())
                            SolutionView(example: example)
                            Divider()
                            Text("القانون").font(.subheadline.bold())
                            ExpressionCard(text: f.shown)
                            TrapLabel(text: f.trap)
                        }
                        .card()

                        if !usesChoices && example.numeric == nil && !graded {
                            selfGradeButtons
                        }
                    } else {
                        Button { reveal() } label: {
                            Text("اعرض الحل").frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }

                    Button { next() } label: {
                        Label("سؤال جديد", systemImage: "arrow.clockwise")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .keyboardShortcut(.return, modifiers: .command)
                }
            }
            .padding()
            .frame(maxWidth: 700)
            .frame(maxWidth: .infinity)
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle(fixed?.title ?? "تمرّن بنفسك")
        .navigationBarTitleDisplayMode(fixed == nil ? .large : .inline)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("تم") { focused = false }
            }
        }
        .onAppear {
            if fixed == nil, let t = store.practiceRequest {
                scope = t
                store.practiceRequest = nil
                next()
            } else if formula == nil {
                next()
            }
        }
        .onChange(of: store.difficulty) { _ in next() }
        .onChange(of: store.practiceRequest) { request in
            guard fixed == nil, let t = request else { return }
            scope = t
            store.practiceRequest = nil
            next()
        }
    }

    // MARK: الأجزاء

    private var header: some View {
        HStack(spacing: 12) {
            if fixed == nil { scopeMenu }
            Spacer()
            if store.timingEnabled && formula != nil { timerLabel }
            Text("النتيجة: \(score) / \(asked)")
                .font(.subheadline.monospacedDigit())
                .foregroundColor(.secondary)
        }
    }

    /// مؤقت السؤال الحالي (يظهر فقط إذا فُعّل من الإعدادات).
    @ViewBuilder
    private var timerLabel: some View {
        if let s = answeredSeconds {
            Label(mmss(s), systemImage: "timer")
                .font(.subheadline.monospacedDigit())
                .foregroundColor(Theme.accent)
        } else {
            TimelineView(.periodic(from: startedAt, by: 1)) { context in
                Label(mmss(context.date.timeIntervalSince(startedAt)), systemImage: "timer")
                    .font(.subheadline.monospacedDigit())
                    .foregroundColor(.secondary)
            }
        }
    }

    private var scopeMenu: some View {
        Menu {
            Button("كل الأبواب") { scope = nil; next() }
            ForEach(Topic.allCases) { t in
                Button(t.rawValue) { scope = t; next() }
            }
        } label: {
            Label(scope?.rawValue ?? "كل الأبواب", systemImage: "line.3.horizontal.decrease.circle")
                .font(.subheadline)
        }
    }

    private var controls: some View {
        VStack(spacing: 8) {
            Picker("المستوى", selection: $store.difficulty) {
                ForEach(Difficulty.allCases) { Text($0.title).tag($0) }
            }
            .pickerStyle(.segmented)
            Picker("طريقة الإجابة", selection: $store.answerMode) {
                ForEach(AnswerMode.allCases) { Text($0.title).tag($0) }
            }
            .pickerStyle(.segmented)
        }
    }

    private func choicesView(_ q: ChoiceQuestion) -> some View {
        VStack(spacing: 10) {
            ForEach(Array(q.options.enumerated()), id: \.offset) { pair in
                let index = pair.offset
                Button { pick(index, in: q) } label: {
                    HStack(spacing: 12) {
                        Text(index < ChoiceQuestion.letters.count ? ChoiceQuestion.letters[index] : "\(index + 1)")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(Circle().fill(letterColor(index, q)))
                        MathLine(pair.element, weight: .medium)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)
                        if let icon = resultIcon(index, q) {
                            Image(systemName: icon)
                                .foregroundColor(index == q.correctIndex ? .green : .red)
                        }
                    }
                    .padding(12)
                    .background(rowColor(index, q))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.accent.opacity(0.15), lineWidth: 1))
                }
                .buttonStyle(.plain)
                .disabled(state != .pending)
                .keyboardShortcut(KeyEquivalent(Character(String(min(index + 1, 9)))), modifiers: [])
                .accessibilityLabel("الخيار \(ChoiceQuestion.letters[min(index, 3)]): \(pair.element)")
            }
        }
    }

    private var answerBox: some View {
        VStack(spacing: 10) {
            TextField(example.unit == "π" ? "اكتب العدد الذي يسبق π" : "اكتب إجابتك (رقم أو كسر مثل 2/5)", text: $input)
                .keyboardType(.numbersAndPunctuation)
                .focused($focused)
                .submitLabel(.done)
                .onSubmit { check() }
                .padding(12)
                .background(Theme.card)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            Button { check() } label: {
                Text("تحقق").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(parseNumber(input) == nil)
        }
    }

    private var selfGradeButtons: some View {
        HStack(spacing: 10) {
            Button { selfGrade(true) } label: {
                Label("عرفتها", systemImage: "checkmark")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)

            Button { selfGrade(false) } label: {
                Label("ما عرفتها", systemImage: "xmark")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
        }
    }

    @ViewBuilder
    private var banner: some View {
        switch state {
        case .right:
            Label("إجابة صحيحة، أحسنت", systemImage: "checkmark.circle.fill")
                .foregroundColor(.green)
                .card(Color.green.opacity(0.12))
        case .wrong:
            VStack(alignment: .leading, spacing: 6) {
                Label("إجابة غير صحيحة", systemImage: "xmark.circle.fill")
                    .foregroundColor(.red)
                HStack(spacing: 6) {
                    Text("الإجابة الصحيحة:")
                    MathLine(example.answer, style: .subheadline, weight: .bold)
                }
                .font(.subheadline)
            }
            .card(Color.red.opacity(0.12))
        case .revealed:
            Label("تم عرض الحل، حاول مرة أخرى بسؤال جديد", systemImage: "eye")
                .foregroundColor(.secondary)
                .card()
        case .pending:
            EmptyView()
        }
    }

    private func letterColor(_ index: Int, _ q: ChoiceQuestion) -> Color {
        guard state != .pending else { return Theme.accent }
        if index == q.correctIndex { return .green }
        if index == picked { return .red }
        return Color.gray.opacity(0.5)
    }

    private func rowColor(_ index: Int, _ q: ChoiceQuestion) -> Color {
        guard state != .pending else { return Theme.card }
        if index == q.correctIndex { return Color.green.opacity(0.15) }
        if index == picked { return Color.red.opacity(0.15) }
        return Theme.card
    }

    private func resultIcon(_ index: Int, _ q: ChoiceQuestion) -> String? {
        guard state != .pending else { return nil }
        if index == q.correctIndex { return "checkmark.circle.fill" }
        if index == picked { return "xmark.circle.fill" }
        return nil
    }

    // MARK: المنطق

    private func next() {
        var pool = FormulaData.all
        if let s = scope {
            pool = pool.filter { $0.topic == s }
        }
        var f = pool.randomElement() ?? FormulaData.all[0]
        if scope == nil, Bool.random(), let w = store.weakFormulas().randomElement() {
            f = w
        }
        if let only = fixed { f = only }
        startedAt = Date()
        answeredSeconds = nil
        formula = f
        example = f.example(store.difficulty)
        choice = QuestionBuilder.choices(for: example)
        picked = nil
        input = ""
        state = .pending
        showSolution = false
        graded = false
        focused = false
    }

    private func pick(_ index: Int, in q: ChoiceQuestion) {
        guard let f = formula, state == .pending else { return }
        picked = index
        let ok = index == q.correctIndex
        finish(f, ok, given: q.options[index])
    }

    private func check() {
        guard let f = formula, state == .pending, let ok = QuestionBuilder.isCorrect(input, for: example) else { return }
        finish(f, ok, given: input.trimmingCharacters(in: .whitespaces))
    }

    /// يسجّل الإجابة في سجل التقدم (والوقت إذا كان المؤقت مفعّلاً).
    private func log(_ f: Formula, _ ok: Bool, given: String) {
        let seconds = Date().timeIntervalSince(startedAt)
        answeredSeconds = seconds
        store.logAnswer(formula: f, correct: ok, seconds: store.timingEnabled ? seconds : nil,
                        example: example, given: given, level: store.difficulty, source: "تمرين")
    }

    private func finish(_ f: Formula, _ ok: Bool, given: String) {
        state = ok ? .right : .wrong
        asked += 1
        if ok { score += 1 }
        log(f, ok, given: given)
        if ok { Haptics.success() } else { Haptics.error() }
        withAnimation { showSolution = true }
        focused = false
    }

    private func reveal() {
        guard let f = formula else { return }
        if state == .pending && (example.numeric != nil || usesChoices) {
            state = .revealed
            asked += 1
            log(f, false, given: "عرضت الحل")
        }
        withAnimation { showSolution = true }
        focused = false
    }

    private func selfGrade(_ ok: Bool) {
        guard let f = formula else { return }
        graded = true
        asked += 1
        if ok { score += 1 }
        log(f, ok, given: ok ? "عرفتها" : "ما عرفتها")
    }
}
