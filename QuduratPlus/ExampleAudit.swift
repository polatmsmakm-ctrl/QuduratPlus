import SwiftUI

/// ملاحظة وجدها الفحص في أحد الأمثلة.
struct AuditIssue: Identifiable {
    let id = UUID()
    let formulaTitle: String
    let level: Difficulty
    let message: String
    let problem: String
}

/// يولّد كل قانون عدة مرات بكل مستوى ويتحقق من سلامة الأمثلة والخيارات.
enum ExampleAudit {
    static func run(samples: Int = 40) -> (checked: Int, issues: [AuditIssue]) {
        var issues: [AuditIssue] = []
        var checked = 0
        for f in FormulaData.all {
            for level in Difficulty.allCases {
                var seen = Set<String>()
                for _ in 0..<samples {
                    let e = f.example(level)
                    checked += 1
                    for msg in problems(in: e) where !seen.contains(msg) {
                        seen.insert(msg)
                        issues.append(AuditIssue(formulaTitle: f.title, level: level, message: msg, problem: e.problem))
                    }
                }
            }
        }
        return (checked, issues)
    }

    static func problems(in e: Example) -> [String] {
        var out: [String] = []
        if e.problem.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { out.append("نص السؤال فارغ") }
        if e.steps.isEmpty { out.append("لا توجد خطوات حل") }
        if e.answer.isEmpty { out.append("الإجابة فارغة") }
        if let v = e.numeric {
            if !v.isFinite {
                out.append("الإجابة ليست رقماً صالحاً")
            } else if !isClean(v) && e.traps.isEmpty {
                out.append("الإجابة فيها كسور عشرية طويلة")
            }
            if e.traps.isEmpty && e.fixedOptions == nil && !e.answer.contains(fmt(v).replacingOccurrences(of: "-", with: "−")) {
                out.append("نص الإجابة لا يطابق القيمة")
            }
        } else if e.traps.count < 3 && e.fixedOptions == nil {
            out.append("لا يمكن تصحيحه تلقائياً")
        }
        let text = (e.steps + [e.problem, e.answer]).joined(separator: " ")
        if text.contains("nan") || text.contains("inf") { out.append("قيمة غير صالحة في النص") }
        if let q = QuestionBuilder.choices(for: e) {
            if q.options.count != 4 { out.append("عدد الخيارات \(q.options.count) بدل 4") }
            if Set(q.options).count != q.options.count { out.append("خيارات مكررة") }
            if !(0..<q.options.count).contains(q.correctIndex) { out.append("موضع الإجابة الصحيحة خاطئ") }
        } else {
            out.append("تعذّر بناء أربعة خيارات")
        }
        return out
    }
}

/// شاشة الفحص الذاتي للأمثلة (للتأكد بعد أي تعديل على القوانين).
struct AuditView: View {
    @State private var running = false
    @State private var checked = 0
    @State private var issues: [AuditIssue] = []
    @State private var done = false

    var body: some View {
        List {
            Section {
                Button {
                    running = true
                    done = false
                    Task {
                        await Task.yield()
                        let result = ExampleAudit.run()
                        checked = result.checked
                        issues = result.issues
                        running = false
                        done = true
                    }
                } label: {
                    HStack {
                        Label("افحص كل الأمثلة", systemImage: "checkmark.seal")
                        Spacer()
                        if running { ProgressView() }
                    }
                }
                .disabled(running)
            } footer: {
                Text("يولّد كل قانون 40 مرة بكل مستوى صعوبة ويتأكد من: وجود خطوات الحل، نظافة الأرقام، تطابق الإجابة، وأربعة خيارات مختلفة فيها الإجابة الصحيحة.")
            }

            if done {
                Section {
                    Label("فُحص \(checked) مثال", systemImage: "number")
                    if issues.isEmpty {
                        Label("لا توجد ملاحظات", systemImage: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                }
                if !issues.isEmpty {
                    Section("الملاحظات (\(issues.count))") {
                        ForEach(issues) { issue in
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(issue.formulaTitle) — \(issue.level.title)").font(.subheadline.bold())
                                Text(issue.message).foregroundColor(.red)
                                Text(issue.problem).font(.caption).foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("فحص الأمثلة")
    }
}
