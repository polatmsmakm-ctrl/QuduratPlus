import SwiftUI

/// اهتزاز خفيف عند الإجابة.
enum Haptics {
    static func success() { UINotificationFeedbackGenerator().notificationOccurred(.success) }
    static func error() { UINotificationFeedbackGenerator().notificationOccurred(.error) }
    static func tap() { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
}

enum Theme {
    /// أخضر مزرق: أغمق في الوضع الفاتح، وأفتح في الداكن ليبقى واضحاً.
    static let accent = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.16, green: 0.62, blue: 0.55, alpha: 1)
            : UIColor(red: 0.05, green: 0.50, blue: 0.45, alpha: 1)
    })
    static let card = Color(UIColor.secondarySystemBackground)
    /// خلفية عنصر داخل بطاقة (أفتح من البطاقة في الداكن).
    static let inset = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark ? UIColor.tertiarySystemBackground : UIColor.systemBackground
    })
    static let warn = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark ? UIColor.systemOrange : UIColor(red: 0.82, green: 0.42, blue: 0.0, alpha: 1)
    })
}

extension View {
    func card(_ color: Color = Theme.card) -> some View {
        self
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

/// بطاقة القانون الكبيرة.
struct ExpressionCard: View {
    let text: String
    var body: some View {
        FormulaExpressionView(text: text)
            .frame(maxWidth: .infinity)
            .padding(18)
            .background(Theme.accent.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

/// خطوات الحل والناتج.
struct SolutionView: View {
    let example: Example

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(Array(example.steps.enumerated()), id: \.offset) { pair in
                HStack(alignment: .top, spacing: 8) {
                    Text("\(pair.offset + 1)")
                        .font(.caption.bold())
                        .foregroundColor(.white)
                        .frame(width: 22, height: 22)
                        .background(Theme.accent)
                        .clipShape(Circle())
                    MathText(pair.element)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 0)
                }
            }
            HStack(spacing: 6) {
                Text("الناتج:").bold()
                MathLine(example.answer, weight: .bold).foregroundColor(Theme.accent)
                Spacer(minLength: 0)
            }
            .padding(.top, 4)
        }
    }
}

struct FormulaRow: View {
    @EnvironmentObject var store: Store
    let formula: Formula

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: formula.topic.icon)
                .foregroundColor(Theme.accent)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 3) {
                Text(formula.title).font(.headline)
                MathText(formula.shown, style: .caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
            if store.isFavorite(formula.id) {
                Image(systemName: "star.fill").foregroundColor(.yellow)
            }
        }
        .padding(.vertical, 2)
    }
}

/// حلقة نسبة (للنتيجة والجاهزية).
struct ScoreRing: View {
    let value: Double
    var size: CGFloat = 60
    var lineWidth: CGFloat = 7
    var showsText = true

    private var color: Color {
        value >= 0.75 ? .green : (value >= 0.5 ? .orange : (value > 0 ? .red : .gray))
    }

    var body: some View {
        ZStack {
            Circle().stroke(Color.gray.opacity(0.2), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: max(0, min(1, value)))
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
            if showsText {
                Text("\(Int((value * 100).rounded()))%")
                    .font(.system(size: size * 0.26, weight: .bold, design: .rounded).monospacedDigit())
            }
        }
        .frame(width: size, height: size)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(Int((value * 100).rounded())) بالمئة")
    }
}

/// مربع إحصائية صغير في لوحة متابعتي.
struct StatTile: View {
    let title: String
    let value: String
    let icon: String
    var tint: Color = Theme.accent

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundColor(tint)
            Text(value)
                .font(.title2.bold().monospacedDigit())
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .accessibilityElement(children: .combine)
    }
}

/// سطر الفخ الشائع (يدعم الرموز الرياضية).
struct TrapLabel: View {
    let text: String
    var style: Font.TextStyle = .footnote

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Image(systemName: "exclamationmark.triangle")
            MathText(text, style: style)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .foregroundColor(Theme.warn)
        .accessibilityElement(children: .combine)
    }
}
