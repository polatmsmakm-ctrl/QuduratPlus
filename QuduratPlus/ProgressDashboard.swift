import SwiftUI
import Charts

// MARK: - متابعتي (لوحة التقدم)

struct MyView: View {
    @EnvironmentObject var store: Store
    @Environment(\.horizontalSizeClass) private var sizeClass

    private let tiles = [GridItem(.adaptive(minimum: 150), spacing: 12)]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    readinessCard
                    LazyVGrid(columns: tiles, spacing: 12) {
                        StatTile(title: "أيام متتالية", value: "\(store.streak)", icon: "flame.fill", tint: .orange)
                        StatTile(title: "اليوم من \(store.progress.dailyGoal)", value: "\(store.today.answered)",
                                 icon: "target", tint: Theme.accent)
                        StatTile(title: "بطاقات مستحقة", value: "\(store.dueCount)", icon: "rectangle.stack.fill", tint: .indigo)
                        if let d = store.daysToExam {
                            StatTile(title: "يوم على الاختبار", value: "\(d)", icon: "calendar", tint: .pink)
                        } else {
                            StatTile(title: "أخطاء محفوظة", value: "\(store.progress.mistakes.count)",
                                     icon: "bookmark.fill", tint: .red)
                        }
                    }
                    if sizeClass == .regular {
                        // iPad: عمودان.
                        HStack(alignment: .top, spacing: 16) {
                            VStack(spacing: 16) {
                                DailyPlanCard()
                                MasteryCard()
                            }
                            VStack(spacing: 16) {
                                ActivityChartCard()
                                linksCard
                            }
                        }
                    } else {
                        DailyPlanCard()
                        ActivityChartCard()
                        MasteryCard()
                        linksCard
                    }
                }
                .padding()
                .frame(maxWidth: sizeClass == .regular ? 1100 : 700)
                .frame(maxWidth: .infinity)
            }
            .navigationTitle("متابعتي")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel("الإعدادات")
                }
            }
        }
    }

    private var totals: (answered: Int, correct: Int) {
        let r = store.right.values.reduce(0, +)
        let w = store.wrong.values.reduce(0, +)
        return (r + w, r)
    }

    private var readinessCard: some View {
        let t = totals
        return HStack(spacing: 16) {
            ScoreRing(value: store.readiness, size: 86, lineWidth: 9)
            VStack(alignment: .leading, spacing: 5) {
                Text("جاهزيتك").font(.headline)
                Text(readinessText)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                if t.answered > 0 {
                    Text("حليت \(t.answered) سؤال • الدقة \(Int((Double(t.correct) / Double(t.answered) * 100).rounded()))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Spacer(minLength: 0)
        }
        .card()
    }

    private var readinessText: String {
        let r = store.readiness
        if totals.answered == 0 { return "ابدأ التمرين وتطلع لك نسبة إتقانك لكل الأبواب." }
        if r >= 0.8 { return "ممتاز، حافظ على المراجعة اليومية." }
        if r >= 0.5 { return "مستواك جيد، ركّز على الأبواب الضعيفة." }
        return "تحتاج تمرين أكثر في أغلب الأبواب."
    }

    private var linksCard: some View {
        VStack(spacing: 0) {
            linkRow("دفتر الأخطاء", "bookmark", "\(store.progress.mistakes.count)") { MistakesView() }
            Divider().padding(.leading, 44)
            linkRow("المفضلة", "star", "\(store.favorites.count)") { FavoritesListView() }
            Divider().padding(.leading, 44)
            linkRow("تحتاج مراجعة", "exclamationmark.triangle", "\(store.weakFormulas().count)") { WeakListView() }
            Divider().padding(.leading, 44)
            linkRow("الإعدادات والنسخ الاحتياطي", "gearshape", "") { SettingsView() }
        }
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func linkRow<D: View>(_ title: String, _ icon: String, _ badge: String,
                                  @ViewBuilder destination: () -> D) -> some View {
        NavigationLink(destination: destination()) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(Theme.accent)
                    .frame(width: 24)
                Text(title).foregroundColor(.primary)
                Spacer()
                if !badge.isEmpty {
                    Text(badge).foregroundColor(.secondary).monospacedDigit()
                }
                Image(systemName: "chevron.left")
                    .font(.caption.bold())
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 13)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - خطة اليوم

struct DailyPlanCard: View {
    @EnvironmentObject var store: Store

    var body: some View {
        let today = store.today
        let goal = store.progress.dailyGoal
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("خطة اليوم", systemImage: "list.bullet.clipboard")
                    .font(.headline)
                Spacer()
                if let d = store.daysToExam {
                    Text(d == 0 ? "الاختبار اليوم، بالتوفيق" : "باقي \(d) يوم")
                        .font(.caption.bold())
                        .foregroundColor(.pink)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("هدف اليوم")
                    Spacer()
                    Text("\(min(today.answered, goal)) / \(goal)").monospacedDigit()
                }
                .font(.subheadline)
                ProgressView(value: Double(min(today.answered, goal)), total: Double(max(1, goal)))
                    .tint(today.answered >= goal ? .green : Theme.accent)
            }

            planRow(done: store.dueCount == 0, icon: "rectangle.stack",
                    title: store.dueCount == 0 ? "ما فيه بطاقات مستحقة" : "راجع \(store.dueCount) بطاقة مستحقة") {
                store.tab = .review
            }
            if let weak = store.weakestTopic {
                planRow(done: false, icon: weak.icon, title: "تمرّن على «\(weak.rawValue)» (أضعف باب)") {
                    store.practiceRequest = weak
                    store.tab = .practice
                }
            }
            planRow(done: store.progress.exams.contains { Calendar.current.isDateInToday($0.date) },
                    icon: "timer", title: "اختبار محاكي قصير") {
                store.tab = .exam
            }
        }
        .card()
    }

    private func planRow(done: Bool, icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: done ? "checkmark.circle.fill" : icon)
                    .foregroundColor(done ? .green : Theme.accent)
                    .frame(width: 24)
                Text(title)
                    .foregroundColor(done ? .secondary : .primary)
                    .strikethrough(done)
                    .multilineTextAlignment(.leading)
                Spacer(minLength: 0)
                Image(systemName: "chevron.left").font(.caption).foregroundColor(.secondary)
            }
            .padding(10)
            .background(Theme.inset)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - الرسم البياني

struct ActivityChartCard: View {
    @EnvironmentObject var store: Store

    private struct Point: Identifiable {
        let id = UUID()
        let date: Date
        let count: Int
        let kind: String
    }

    private var points: [Point] {
        DayKey.lastDays(14).flatMap { key -> [Point] in
            let d = DayKey.date(key) ?? Date()
            let s = store.progress.days[key] ?? DayStat()
            return [Point(date: d, count: s.correct, kind: "صحيحة"),
                    Point(date: d, count: s.answered - s.correct, kind: "خاطئة")]
        }
    }

    var body: some View {
        let total = DayKey.lastDays(14).map { store.progress.days[$0]?.answered ?? 0 }.reduce(0, +)
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("آخر 14 يوم", systemImage: "chart.bar.fill").font(.headline)
                Spacer()
                Text("\(total) سؤال").font(.subheadline.monospacedDigit()).foregroundColor(.secondary)
            }
            if total == 0 {
                Text("نشاطك اليومي يظهر هنا كرسم بياني.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 80)
            } else {
                Chart(points) { p in
                    BarMark(x: .value("اليوم", p.date, unit: .day), y: .value("الأسئلة", p.count))
                        .foregroundStyle(by: .value("النوع", p.kind))
                        .cornerRadius(3)
                }
                .chartForegroundStyleScale(["صحيحة": Color.green, "خاطئة": Color.red.opacity(0.7)])
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: 2)) { _ in
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.day())
                    }
                }
                .frame(height: 180)
            }
        }
        .card()
    }
}

// MARK: - الإتقان لكل باب

struct MasteryCard: View {
    @EnvironmentObject var store: Store

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("الإتقان لكل باب", systemImage: "square.stack.3d.up.fill").font(.headline)
            ForEach(Topic.allCases) { t in
                let value = store.topicMastery(t)
                Button {
                    store.practiceRequest = t
                    store.tab = .practice
                } label: {
                    VStack(alignment: .leading, spacing: 5) {
                        HStack(spacing: 8) {
                            Image(systemName: t.icon).foregroundColor(Theme.accent).frame(width: 22)
                            Text(t.rawValue).foregroundColor(.primary)
                            Spacer()
                            if let avg = store.averageSeconds(t) {
                                Label(mmss(avg), systemImage: "timer")
                                    .font(.caption.monospacedDigit())
                                    .foregroundColor(avg > 75 ? .orange : .secondary)
                            }
                            Text("\(Int((value * 100).rounded()))%")
                                .font(.subheadline.bold().monospacedDigit())
                                .foregroundColor(color(value))
                        }
                        ProgressView(value: value).tint(color(value))
                    }
                }
                .buttonStyle(.plain)
                .accessibilityHint("اضغط للتمرين على هذا الباب")
            }
            Text("الإتقان يعتمد على دقتك في كل قانون (بعد 3 محاولات على الأقل) ومستواه في المراجعة. اضغط على باب لتتمرّن عليه.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .card()
    }

    private func color(_ v: Double) -> Color {
        v >= 0.75 ? .green : (v >= 0.5 ? .orange : (v > 0 ? .red : .gray))
    }
}
