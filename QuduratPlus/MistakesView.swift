import SwiftUI

// MARK: - دفتر الأخطاء

struct MistakesView: View {
    @EnvironmentObject var store: Store
    @State private var query = ""
    @State private var topic: Topic? = nil
    @State private var confirmClear = false

    private var filtered: [Mistake] {
        let q = norm(query.trimmingCharacters(in: .whitespaces))
        return store.progress.mistakes.filter { m in
            let f = FormulaData.formula(id: m.formulaID)
            if let t = topic, f?.topic != t { return false }
            if q.isEmpty { return true }
            let hay = norm("\(f?.title ?? "") \(m.problem)")
            return q.split(separator: " ").allSatisfy { hay.contains(String($0)) }
        }
    }

    var body: some View {
        List {
            if store.progress.mistakes.isEmpty {
                Section {
                    VStack(spacing: 10) {
                        Image(systemName: "checkmark.seal")
                            .font(.system(size: 44))
                            .foregroundColor(Theme.accent)
                        Text("دفتر الأخطاء فاضي")
                            .font(.headline)
                        Text("أي سؤال تخطئ فيه في التمرين أو الاختبار ينحفظ هنا مع حله، عشان ترجع له وتتمرّن على مثله.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                }
            } else {
                Section {
                    Picker("الباب", selection: $topic) {
                        Text("كل الأبواب").tag(Topic?.none)
                        ForEach(Topic.allCases) { Text($0.rawValue).tag(Topic?.some($0)) }
                    }
                }
                Section {
                    if filtered.isEmpty {
                        Text("لا توجد نتائج.").foregroundColor(.secondary)
                    }
                    ForEach(filtered) { m in
                        NavigationLink(destination: MistakeDetailView(mistake: m)) {
                            MistakeRow(mistake: m)
                        }
                    }
                    .onDelete { offsets in
                        let list = filtered
                        for i in offsets { store.deleteMistake(list[i].id) }
                    }
                } header: {
                    Text("\(filtered.count) سؤال")
                }
            }
        }
        .navigationTitle("دفتر الأخطاء")
        .searchable(text: $query, prompt: "ابحث في الأخطاء")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(role: .destructive) { confirmClear = true } label: {
                    Image(systemName: "trash")
                }
                .disabled(store.progress.mistakes.isEmpty)
                .accessibilityLabel("مسح الدفتر")
            }
        }
        .confirmationDialog("مسح كل الأخطاء من الدفتر؟", isPresented: $confirmClear, titleVisibility: .visible) {
            Button("مسح الكل", role: .destructive) { store.clearMistakes() }
            Button("إلغاء", role: .cancel) {}
        }
    }
}

struct MistakeRow: View {
    let mistake: Mistake

    var body: some View {
        let f = FormulaData.formula(id: mistake.formulaID)
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: f?.topic.icon ?? "questionmark")
                    .foregroundColor(Theme.accent)
                Text(f?.title ?? "قانون").font(.subheadline.bold())
                Spacer(minLength: 0)
                Text(mistake.source + " • " + mistake.level.title)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            MathText(mistake.problem, style: .footnote)
                .lineLimit(2)
            Text(mistake.date.formatted(date: .abbreviated, time: .shortened))
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 2)
    }
}

struct MistakeDetailView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss
    let mistake: Mistake

    var body: some View {
        let f = FormulaData.formula(id: mistake.formulaID)
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                MathText(mistake.problem, style: .title3, weight: .medium)
                    .fixedSize(horizontal: false, vertical: true)
                    .card()

                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top) {
                        Label("إجابتك", systemImage: "xmark.circle.fill").foregroundColor(.red)
                        Spacer()
                        MathLine(mistake.yourAnswer, style: .subheadline).multilineTextAlignment(.trailing)
                    }
                    HStack(alignment: .top) {
                        Label("الصحيح", systemImage: "checkmark.circle.fill").foregroundColor(.green)
                        Spacer()
                        MathLine(mistake.correctAnswer, style: .subheadline, weight: .bold).multilineTextAlignment(.trailing)
                    }
                }
                .font(.subheadline)
                .card()

                VStack(alignment: .leading, spacing: 10) {
                    Text("الحل").font(.subheadline.bold())
                    ForEach(Array(mistake.steps.enumerated()), id: \.offset) { pair in
                        HStack(alignment: .top, spacing: 8) {
                            Text("\(pair.offset + 1)")
                                .font(.caption.bold())
                                .foregroundColor(.white)
                                .frame(width: 22, height: 22)
                                .background(Theme.accent)
                                .clipShape(Circle())
                            MathText(pair.element).fixedSize(horizontal: false, vertical: true)
                            Spacer(minLength: 0)
                        }
                    }
                }
                .card()

                if let f {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("القانون").font(.subheadline.bold())
                        ExpressionCard(text: f.shown)
                        TrapLabel(text: f.trap)
                    }
                    .card()

                    NavigationLink(destination: FocusedPracticeView(formula: f)) {
                        Label("تمرّن على سؤال مشابه", systemImage: "arrow.triangle.2.circlepath")
                            .frame(maxWidth: .infinity)
                            .font(.headline)
                    }
                    .buttonStyle(.borderedProminent)

                    NavigationLink(destination: FormulaDetailView(formula: f)) {
                        Label("افتح صفحة القانون", systemImage: "book")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }

                Button(role: .destructive) {
                    store.deleteMistake(mistake.id)
                    dismiss()
                } label: {
                    Label("فهمتها، احذفها من الدفتر", systemImage: "checkmark")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.green)
            }
            .padding()
            .frame(maxWidth: 700)
            .frame(maxWidth: .infinity)
        }
        .navigationTitle(f?.title ?? "الخطأ")
        .navigationBarTitleDisplayMode(.inline)
    }
}
