import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store

    var body: some View {
        TabView(selection: $store.tab) {
            LibraryView()
                .tabItem { Label("القوانين", systemImage: "function") }
                .tag(AppTab.library)
            PracticeView()
                .tabItem { Label("تمرّن", systemImage: "pencil.circle") }
                .tag(AppTab.practice)
            ExamHomeView()
                .tabItem { Label("اختبار", systemImage: "timer") }
                .tag(AppTab.exam)
            ReviewView()
                .tabItem { Label("مراجعة", systemImage: "rectangle.stack") }
                .tag(AppTab.review)
                .badge(store.dueCount)
            MyView()
                .tabItem { Label("متابعتي", systemImage: "chart.bar.xaxis") }
                .tag(AppTab.progress)
        }
    }
}

// MARK: - مكتبة القوانين

struct LibraryView: View {
    @EnvironmentObject var store: Store
    @State private var query = ""
    @State private var selected: Topic? = nil
    @State private var selection: String? = nil
    @Environment(\.horizontalSizeClass) private var sizeClass

    private func matches(_ f: Formula, _ q: String) -> Bool {
        if let t = selected, t != f.topic { return false }
        if q.isEmpty { return true }
        let hay = norm("\(f.title) \(f.expression) \(f.explanation) \(f.topic.rawValue)")
        for tok in q.split(separator: " ") {
            if !hay.contains(String(tok)) { return false }
        }
        return true
    }

    private var results: [Formula] {
        let q = norm(query.trimmingCharacters(in: .whitespaces))
        return FormulaData.all.filter { matches($0, q) }
    }

    var body: some View {
        if sizeClass == .regular {
            // iPad: القائمة في الشريط الجانبي والقانون بجانبها.
            NavigationSplitView {
                List(selection: $selection) {
                    sections(split: true)
                }
                .navigationTitle("قدرات+")
                .searchable(text: $query, prompt: "ابحث عن قانون")
            } detail: {
                NavigationStack {
                    if let id = selection, let f = FormulaData.formula(id: id) {
                        FormulaDetailView(formula: f).id(f.id)
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "function")
                                .font(.system(size: 54))
                                .foregroundColor(Theme.accent)
                            Text("اختر قانوناً من القائمة").foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationSplitViewStyle(.balanced)
            .onAppear {
                if selection == nil { selection = FormulaData.formulaOfDay().id }
            }
        } else {
            NavigationStack {
                List {
                    sections(split: false)
                }
                .navigationTitle("قدرات+")
                .searchable(text: $query, prompt: "ابحث عن قانون")
            }
        }
    }

    @ViewBuilder
    private func sections(split: Bool) -> some View {
        Section {
            chips
        }
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)

        if query.isEmpty && selected == nil {
            Section {
                row(FormulaData.formulaOfDay(), split: split) {
                    DailyCard(formula: FormulaData.formulaOfDay())
                }
            }
        }

        ForEach(Topic.allCases) { topic in
            let items = results.filter { $0.topic == topic }
            if !items.isEmpty {
                Section(topic.rawValue) {
                    ForEach(items) { f in
                        row(f, split: split) { FormulaRow(formula: f) }
                    }
                }
            }
        }

        if results.isEmpty {
            Text("لا توجد نتائج. جرّب كلمة أخرى مثل: مساحة، نسبة، سرعة.")
                .foregroundColor(.secondary)
        }
    }

    /// صف قابل للاختيار في iPad، ورابط تنقّل في iPhone.
    @ViewBuilder
    private func row<Content: View>(_ f: Formula, split: Bool, @ViewBuilder content: () -> Content) -> some View {
        if split {
            content().tag(f.id)
        } else {
            NavigationLink(destination: FormulaDetailView(formula: f)) { content() }
        }
    }

    private var chips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chip("الكل", selected == nil) { selected = nil }
                ForEach(Topic.allCases) { t in
                    chip(t.rawValue, selected == t) { selected = t }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
        }
    }

    private func chip(_ title: String, _ on: Bool, _ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(on ? Theme.accent : Theme.card)
                .foregroundColor(on ? Color.white : Color.primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

struct DailyCard: View {
    let formula: Formula
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("قانون اليوم", systemImage: "sun.max")
                .font(.caption.bold())
                .foregroundColor(Theme.accent)
            Text(formula.title).font(.headline)
            MathText(formula.shown, style: .subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - صفحة القانون

struct FormulaDetailView: View {
    @EnvironmentObject var store: Store
    let formula: Formula
    @State private var example: Example?
    @State private var showSolution = false

    private var masteryText: String? {
        let r = store.right[formula.id] ?? 0, w = store.wrong[formula.id] ?? 0
        guard r + w > 0 else { return nil }
        return "أصبت \(r) من \(r + w) • الإتقان \(Int((store.formulaMastery(formula.id) * 100).rounded()))%"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Label(formula.topic.rawValue, systemImage: formula.topic.icon)
                    .font(.caption.bold())
                    .foregroundColor(Theme.accent)

                ExpressionCard(text: formula.shown)

                VStack(alignment: .leading, spacing: 6) {
                    Text("الشرح").font(.subheadline.bold())
                    MathText(formula.explanation)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .card()

                VStack(alignment: .leading, spacing: 6) {
                    Label("فخ شائع", systemImage: "exclamationmark.triangle")
                        .font(.subheadline.bold())
                        .foregroundColor(Theme.warn)
                    MathText(formula.trap)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .card(Theme.warn.opacity(0.12))

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("مثال").font(.subheadline.bold())
                        Spacer()
                        Picker("المستوى", selection: $store.difficulty) {
                            ForEach(Difficulty.allCases) { Text($0.title).tag($0) }
                        }
                        .pickerStyle(.segmented)
                        .frame(maxWidth: 220)
                    }
                    if let example {
                        MathText(example.problem, weight: .medium)
                            .fixedSize(horizontal: false, vertical: true)

                        if showSolution {
                            Divider()
                            SolutionView(example: example)
                        }
                    }

                    HStack(spacing: 10) {
                        Button {
                            withAnimation { showSolution.toggle() }
                        } label: {
                            Text(showSolution ? "أخفِ الحل" : "اعرض الحل")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)

                        Button {
                            example = formula.example(store.difficulty)
                            showSolution = false
                        } label: {
                            Label("مثال جديد", systemImage: "arrow.clockwise")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .card()

                NavigationLink(destination: FocusedPracticeView(formula: formula)) {
                    Label("تمرّن على هذا القانون", systemImage: "pencil.circle")
                        .frame(maxWidth: .infinity)
                        .font(.headline)
                }
                .buttonStyle(.borderedProminent)

                if let s = masteryText {
                    Text(s)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding()
            .frame(maxWidth: 700)
            .frame(maxWidth: .infinity)
        }
        .navigationTitle(formula.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if example == nil { example = formula.example(store.difficulty) }
        }
        .onChange(of: store.difficulty) { level in
            example = formula.example(level)
            showSolution = false
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    store.toggle(formula.id)
                } label: {
                    Image(systemName: store.isFavorite(formula.id) ? "star.fill" : "star")
                        .foregroundColor(.yellow)
                }
            }
        }
    }
}
