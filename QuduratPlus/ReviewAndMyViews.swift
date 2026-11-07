import SwiftUI

// MARK: - المراجعة المتباعدة (بطاقات)

enum ReviewMode: String, CaseIterable, Identifiable {
    case due, all, favorites

    var id: String { rawValue }

    var title: String {
        switch self {
        case .due: return "مراجعة اليوم"
        case .all: return "كل القوانين"
        case .favorites: return "المفضلة"
        }
    }
}

struct ReviewView: View {
    @EnvironmentObject var store: Store
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var mode: ReviewMode = .due
    @State private var deck: [Formula] = []
    @State private var index = 0
    @State private var flipped = false
    @State private var reviewedNow = 0

    /// عدد البطاقات الجديدة التي تدخل المراجعة يومياً.
    private let newPerSession = 8

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Picker("النوع", selection: $mode) {
                    ForEach(ReviewMode.allCases) { Text($0.title).tag($0) }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                if deck.isEmpty || index >= deck.count {
                    Spacer()
                    emptyState
                    Spacer()
                } else {
                    cardView(deck[index])
                    Spacer(minLength: 0)
                }
            }
            .padding(.top, 8)
            .frame(maxWidth: 700)
            .frame(maxWidth: .infinity)
            .navigationTitle("مراجعة")
            .onAppear { if deck.isEmpty { rebuild() } }
            .onChange(of: mode) { _ in rebuild() }
            .onChange(of: store.tab) { tab in
                // تحديث البطاقات المستحقة عند الرجوع للتبويب بعد انتهاء الجلسة.
                if tab == .review && (deck.isEmpty || index >= deck.count) { rebuild() }
            }
        }
    }

    // MARK: البطاقة

    private func cardView(_ f: Formula) -> some View {
        let state = store.progress.cards[f.id]
        return VStack(spacing: 16) {
            HStack {
                Text(mode == .due ? "باقي \(deck.count - index)" : "\(index + 1) / \(deck.count)")
                    .font(.footnote.monospacedDigit())
                    .foregroundColor(.secondary)
                Spacer()
                if let s = state {
                    Text("الصندوق \(s.box + 1) من \(Leitner.maxBox + 1)")
                        .font(.caption2.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Theme.accent.opacity(0.15))
                        .clipShape(Capsule())
                } else {
                    Text("جديدة")
                        .font(.caption2.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.orange.opacity(0.2))
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal)

            VStack(spacing: 14) {
                Label(f.topic.rawValue, systemImage: f.topic.icon)
                    .font(.caption)
                    .foregroundColor(.secondary)
                if flipped {
                    Text(f.title)
                        .font(.headline)
                        .foregroundColor(.secondary)
                    FormulaExpressionView(text: f.shown, style: .title2, weight: .bold)
                    MathText(f.explanation, style: .callout)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    Label {
                        MathText(f.trap, style: .footnote)
                    } icon: {
                        Image(systemName: "exclamationmark.triangle")
                    }
                    .foregroundColor(Theme.warn)
                    .multilineTextAlignment(.center)
                } else {
                    Text(f.title)
                        .font(.title.bold())
                        .multilineTextAlignment(.center)
                    Text("تذكّر القانون، ثم اضغط لتشوفه")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity, minHeight: sizeClass == .regular ? 380 : 280)
            .padding(20)
            .background(flipped ? Theme.accent.opacity(0.14) : Theme.card)
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .contentShape(Rectangle())
            .onTapGesture { flip() }
            .accessibilityAddTraits(.isButton)
            .padding(.horizontal)

            if flipped {
                HStack(spacing: 10) {
                    gradeButton("نسيتها", .again, f, .red, key: "1")
                    gradeButton("تذكرتها", .good, f, Theme.accent, key: "2")
                    gradeButton("سهلة", .easy, f, .green, key: "3")
                }
                .padding(.horizontal)
            } else {
                HStack(spacing: 20) {
                    Button { skip(-1) } label: { Image(systemName: "chevron.right") }
                        .disabled(mode == .due || index == 0)
                        .accessibilityLabel("السابق")
                    Button { store.toggle(f.id) } label: {
                        Image(systemName: store.isFavorite(f.id) ? "star.fill" : "star")
                            .foregroundColor(.yellow)
                    }
                    .accessibilityLabel("المفضلة")
                    Button { flip() } label: { Image(systemName: "arrow.2.squarepath") }
                        .keyboardShortcut(.space, modifiers: [])
                        .accessibilityLabel("اقلب البطاقة")
                    Button { skip(1) } label: { Image(systemName: "chevron.left") }
                        .accessibilityLabel("التالي")
                }
                .font(.title3)
                .buttonStyle(.bordered)
            }
        }
    }

    private func flip() {
        withAnimation(.easeInOut(duration: 0.2)) { flipped.toggle() }
        Haptics.tap()
    }

    private func gradeButton(_ title: String, _ grade: ReviewGrade, _ f: Formula, _ tint: Color,
                             key: Character) -> some View {
        Button {
            apply(f, grade)
        } label: {
            VStack(spacing: 2) {
                Text(title).font(.subheadline.bold())
                Text(nextText(f, grade)).font(.caption2)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .tint(tint)
        .keyboardShortcut(KeyEquivalent(key), modifiers: [])
    }

    /// متى ترجع البطاقة لو اخترت هذا التقييم.
    private func nextText(_ f: Formula, _ grade: ReviewGrade) -> String {
        let s = Leitner.review(store.progress.cards[f.id] ?? CardState(), grade: grade)
        let days = Leitner.intervals[s.box]
        switch days {
        case 0: return "بعد 10 د"
        case 1: return "بكرة"
        case 2: return "بعد يومين"
        default: return "بعد \(days) أيام"
        }
    }

    @ViewBuilder
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: mode == .due ? "checkmark.circle" : "rectangle.stack")
                .font(.system(size: 50))
                .foregroundColor(Theme.accent)
            switch mode {
            case .due:
                Text(reviewedNow > 0 ? "خلصت مراجعة اليوم" : "ما فيه بطاقات مستحقة الحين")
                    .font(.title3.bold())
                if reviewedNow > 0 {
                    Text("راجعت \(reviewedNow) بطاقة.").foregroundColor(.secondary)
                }
                if let next = nextDue {
                    Text("المراجعة الجاية: " + next.formatted(date: .abbreviated, time: .shortened))
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                Button("راجع بطاقات جديدة") { rebuild(extraNew: true) }
                    .buttonStyle(.bordered)
                    .disabled(store.newFormulas().isEmpty)
            case .favorites:
                Text("لا توجد قوانين في المفضلة بعد.\nاضغط على النجمة في صفحة أي قانون لإضافته.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
            case .all:
                Text("خلصت البطاقات.").foregroundColor(.secondary)
                Button("من البداية") { rebuild() }.buttonStyle(.bordered)
            }
        }
        .padding()
    }

    private var nextDue: Date? {
        store.progress.cards.values.map(\.due).filter { $0 > Date() }.min()
    }

    // MARK: المنطق

    private func rebuild(extraNew: Bool = false) {
        switch mode {
        case .due:
            let due = store.dueFormulas()
            let fresh = Array(store.newFormulas().shuffled().prefix(extraNew ? newPerSession : (due.isEmpty ? 0 : 3)))
            deck = due + fresh
            if deck.isEmpty && !extraNew && store.progress.cards.isEmpty {
                // أول مرة: ابدأ ببطاقات جديدة مباشرة.
                deck = Array(store.newFormulas().shuffled().prefix(newPerSession))
            }
        case .all:
            deck = FormulaData.all.shuffled()
        case .favorites:
            deck = store.favoriteFormulas.shuffled()
        }
        index = 0
        flipped = false
        reviewedNow = 0
    }

    private func apply(_ f: Formula, _ g: ReviewGrade) {
        store.reviewCard(f.id, grade: g)
        reviewedNow += 1
        if g == .again { Haptics.error() } else { Haptics.success() }
        withAnimation(.easeInOut(duration: 0.2)) {
            if mode == .due && g == .again {
                // تبقى في آخر الجلسة لتعيدها.
                deck.append(f)
            }
            index += 1
            flipped = false
        }
    }

    private func skip(_ step: Int) {
        let target = index + step
        guard target >= 0 else { return }
        if mode == .due {
            // تأجيل البطاقة لآخر الجلسة.
            let f = deck.remove(at: index)
            deck.append(f)
        } else {
            index = min(target, deck.count)
        }
        flipped = false
    }
}

// MARK: - قوائم مساعدة

struct FavoritesListView: View {
    @EnvironmentObject var store: Store

    var body: some View {
        List {
            if store.favoriteFormulas.isEmpty {
                Text("ما أضفت شيئاً بعد. اضغط على النجمة داخل أي قانون.")
                    .foregroundColor(.secondary)
            }
            ForEach(store.favoriteFormulas) { f in
                NavigationLink(destination: FormulaDetailView(formula: f)) {
                    FormulaRow(formula: f)
                }
            }
        }
        .navigationTitle("المفضلة")
    }
}

struct WeakListView: View {
    @EnvironmentObject var store: Store

    var body: some View {
        List {
            let weak = store.weakFormulas()
            if weak.isEmpty {
                Text("القوانين التي تخطئ فيها أكثر مما تصيب تظهر هنا.")
                    .foregroundColor(.secondary)
            }
            ForEach(weak) { f in
                NavigationLink(destination: FormulaDetailView(formula: f)) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(f.title).font(.headline)
                        Text("أخطأت \(store.wrong[f.id] ?? 0) وأصبت \(store.right[f.id] ?? 0)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .navigationTitle("تحتاج مراجعة")
    }
}
