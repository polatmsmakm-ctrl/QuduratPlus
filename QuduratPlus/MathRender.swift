import SwiftUI
import UIKit

// MARK: - عرض الرياضيات بدون مكتبات خارجية
//
// يقرأ نفس النصوص الموجودة في القوانين والأمثلة ويعرضها بشكل رياضي:
// - الأس: أ^م أو 2^(ن − 1) يظهر مرفوعاً وصغيراً.
// - الكسر: 3/8 أو أ/ب يظهر ككسر (مكدّس في العرض الكبير، ومائل صغير داخل الفقرات).
// - القسمة ÷ في بطاقة القانون تتحول لكسر مكدّس: (الجزء ÷ الكل) ← الجزء فوق الكل.
// - الجذر: √(أ × ب) أو √50 يظهر بعلامة جذر وخط فوق ما تحته.
// النص الأصلي لا يتغير، فالتصحيح والبحث والنسخ الاحتياطي تبقى كما هي.

indirect enum MathNode: Equatable {
    case text(String)
    case group([MathNode])
    case frac([MathNode], [MathNode])
    case sup([MathNode])
    case root([MathNode])
}

enum MathParser {
    static let lri = "\u{2066}"
    static let rli = "\u{2067}"
    static let pdi = "\u{2069}"

    /// الفاصل بين أكثر من قانون في سطر واحد.
    static let lineSeparator = "   ،   "

    static func stripIsolates(_ s: String) -> String {
        s.replacingOccurrences(of: lri, with: "")
            .replacingOccurrences(of: rli, with: "")
            .replacingOccurrences(of: pdi, with: "")
    }

    /// يحلل النص. `stackDivision` يحوّل ÷ إلى كسر مكدّس (للعرض الكبير فقط).
    static func parse(_ s: String, stackDivision: Bool) -> [MathNode] {
        var scanner = Scanner(chars: Array(s))
        var nodes = scanner.sequence(closing: false).nodes
        nodes = slashFractions(nodes)
        if stackDivision { nodes = divisions(nodes) }
        return merge(nodes)
    }

    // MARK: المسح

    private struct Scanner {
        let chars: [Character]
        var i = 0

        static func flush(_ out: inout [MathNode], _ buf: inout String) {
            if !buf.isEmpty {
                out.append(.text(buf))
                buf = ""
            }
        }

        mutating func sequence(closing: Bool) -> (nodes: [MathNode], closed: Bool) {
            var out: [MathNode] = []
            var buf = ""
            while i < chars.count {
                let c = chars[i]
                if c == ")" && closing {
                    i += 1
                    Scanner.flush(&out, &buf)
                    return (out, true)
                }
                if c == "(" {
                    let save = i
                    i += 1
                    let g = sequence(closing: true)
                    if g.closed {
                        Scanner.flush(&out, &buf)
                        out.append(.group(g.nodes))
                    } else {
                        // قوس بدون إغلاق: يبقى نصاً عادياً.
                        i = save + 1
                        buf.append(c)
                    }
                    continue
                }
                if c == "√" || c == "^" {
                    i += 1
                    var inner: [MathNode]? = nil
                    if i < chars.count && chars[i] == "(" {
                        let save = i
                        i += 1
                        let g = sequence(closing: true)
                        if g.closed { inner = g.nodes } else { i = save }
                    } else {
                        var run = ""
                        while i < chars.count {
                            let ch = chars[i]
                            let decimal = ch == "." && !run.isEmpty && i + 1 < chars.count && chars[i + 1].isASCIIDigit
                            guard ch.isLetter || ch.isASCIIDigit || decimal else { break }
                            run.append(ch)
                            i += 1
                        }
                        if !run.isEmpty { inner = [.text(run)] }
                    }
                    if let inner = inner {
                        Scanner.flush(&out, &buf)
                        out.append(c == "√" ? .root(inner) : .sup(inner))
                    } else {
                        buf.append(c)
                    }
                    continue
                }
                buf.append(c)
                i += 1
            }
            Scanner.flush(&out, &buf)
            return (out, false)
        }
    }

    // MARK: الكسور المائلة 3/8 و أ/ب

    private static func slashFractions(_ nodes: [MathNode]) -> [MathNode] {
        var out: [MathNode] = []
        for n in nodes {
            switch n {
            case .text(let t): out += splitSlash(t)
            case .group(let c): out.append(.group(slashFractions(c)))
            case .sup(let c): out.append(.sup(slashFractions(c)))
            case .root(let c): out.append(.root(slashFractions(c)))
            case .frac(let a, let b): out.append(.frac(slashFractions(a), slashFractions(b)))
            }
        }
        return out
    }

    private static func isWordChar(_ c: Character) -> Bool { c.isLetter || c.isNumber || c == "." }

    /// يقسم النص عند كل كسر بسيط: رقم/رقم، حرف/حرف، أو رقم/حرف.
    static func splitSlash(_ t: String) -> [MathNode] {
        let ch = Array(t)
        var out: [MathNode] = []
        var start = 0
        var k = 0
        while k < ch.count {
            guard ch[k] == "/", k > 0, k + 1 < ch.count else { k += 1; continue }
            // البسط
            var ls = k - 1
            if ch[ls].isASCIIDigit {
                while ls - 1 >= start && ch[ls - 1].isASCIIDigit { ls -= 1 }
            } else if !ch[ls].isLetter {
                k += 1; continue
            }
            if ls - 1 >= 0 && isWordChar(ch[ls - 1]) { k += 1; continue }
            // المقام
            var re = k + 1
            if ch[re].isASCIIDigit {
                while re + 1 < ch.count && ch[re + 1].isASCIIDigit { re += 1 }
                if re + 1 < ch.count && (ch[re + 1].isNumber || ch[re + 1] == ".") { k += 1; continue }
                if re + 1 < ch.count && ch[re + 1].isLetter && ch[re + 1] != "π" { k += 1; continue }
            } else if ch[re].isLetter {
                if re + 1 < ch.count && (ch[re + 1].isLetter || ch[re + 1].isNumber) { k += 1; continue }
            } else {
                k += 1; continue
            }
            if ls > start { out.append(.text(String(ch[start..<ls]))) }
            out.append(.frac([.text(String(ch[ls..<k]))], [.text(String(ch[(k + 1)...re]))]))
            start = re + 1
            k = re + 1
        }
        if start < ch.count { out.append(.text(String(ch[start...]))) }
        return out
    }

    // MARK: القسمة ÷ ككسر مكدّس

    private static let operators: Set<String> = ["=", "⇒", "⇔", "+", "−", "-", "×", "÷", "،", ",", "<", ">", "≤", "≥", "أو"]

    private static func isOperator(_ unit: [MathNode]) -> Bool {
        if unit.count == 1, case .text(let t) = unit[0] { return operators.contains(t) }
        return false
    }

    private static func isDivide(_ unit: [MathNode]) -> Bool {
        if unit.count == 1, case .text(let t) = unit[0] { return t == "÷" }
        return false
    }

    /// يقسم السلسلة إلى «كلمات»: عناصر متلاصقة بدون مسافة بينها.
    private static func units(_ nodes: [MathNode]) -> [[MathNode]] {
        var result: [[MathNode]] = []
        var current: [MathNode] = []
        for n in nodes {
            if case .text(let t) = n {
                var piece = ""
                for c in t {
                    if c == " " {
                        if !piece.isEmpty { current.append(.text(piece)); piece = "" }
                        if !current.isEmpty { result.append(current); current = [] }
                    } else {
                        piece.append(c)
                    }
                }
                if !piece.isEmpty { current.append(.text(piece)) }
            } else {
                current.append(n)
            }
        }
        if !current.isEmpty { result.append(current) }
        return result
    }

    private static func join(_ us: [[MathNode]]) -> [MathNode] {
        var out: [MathNode] = []
        for (i, u) in us.enumerated() {
            if i > 0 { out.append(.text(" ")) }
            out += u
        }
        return merge(out)
    }

    /// المعامل: إذا كان قوساً واحداً تُحذف أقواسه.
    private static func operand(_ us: [[MathNode]]) -> [MathNode] {
        if us.count == 1, us[0].count == 1, case .group(let c) = us[0][0] { return c }
        return join(us)
    }

    static func divisions(_ nodes: [MathNode]) -> [MathNode] {
        // داخل الأقواس والجذور أولاً.
        let inner: [MathNode] = nodes.map { (n: MathNode) -> MathNode in
            switch n {
            case .group(let c): return .group(divisions(c))
            case .root(let c): return .root(divisions(c))
            case .frac(let a, let b): return .frac(divisions(a), divisions(b))
            default: return n
            }
        }
        var us = units(inner)
        var i = 0
        while i < us.count {
            guard isDivide(us[i]) else { i += 1; continue }
            var l = i
            while l - 1 >= 0 && !isOperator(us[l - 1]) { l -= 1 }
            var r = i
            while r + 1 < us.count && !isOperator(us[r + 1]) { r += 1 }
            guard l < i && r > i else { i += 1; continue }
            let f = MathNode.frac(operand(Array(us[l..<i])), operand(Array(us[(i + 1)...r])))
            us.replaceSubrange(l...r, with: [[f]])
            i = l + 1
        }
        // قوس كل ما فيه كسر واحد: لا داعي للأقواس.
        us = us.map { (u: [MathNode]) -> [MathNode] in
            if u.count == 1, case .group(let c) = u[0] {
                let core = c.filter { if case .text(let t) = $0 { return !t.trimmingCharacters(in: .whitespaces).isEmpty }; return true }
                if core.count == 1, case .frac = core[0] { return core }
            }
            return u
        }
        return join(us)
    }

    // MARK: أدوات

    static func merge(_ nodes: [MathNode]) -> [MathNode] {
        var out: [MathNode] = []
        for n in nodes {
            if case .text(let t) = n {
                if t.isEmpty { continue }
                if let last = out.last, case .text(let p) = last {
                    out[out.count - 1] = .text(p + t)
                    continue
                }
            }
            out.append(n)
        }
        return out
    }

    static func hasStructure(_ nodes: [MathNode]) -> Bool {
        nodes.contains { if case .text = $0 { return false }; return true }
    }

    /// هل يحتاج عرضاً ثنائي الأبعاد (كسر مكدّس أو جذر)؟
    static func needsBlock(_ nodes: [MathNode]) -> Bool {
        nodes.contains { n in
            switch n {
            case .frac, .root: return true
            case .group(let c): return needsBlock(c)
            default: return false
            }
        }
    }

    /// هل في النص كلمة عربية من حرفين أو أكثر؟ (يحدد اتجاه السطر)
    static func hasArabicWord(_ s: String) -> Bool {
        var run = 0
        for u in s.unicodeScalars {
            if (0x0621...0x064A).contains(u.value) {
                run += 1
                if run >= 2 { return true }
            } else {
                run = 0
            }
        }
        return false
    }

    /// نص مقروء لقارئ الشاشة.
    static func spoken(_ nodes: [MathNode]) -> String {
        nodes.map { n -> String in
            switch n {
            case .text(let t): return t
            case .group(let c): return "(" + spoken(c) + ")"
            case .sup(let c): return " أس " + spoken(c) + " "
            case .frac(let a, let b): return " " + spoken(a) + " على " + spoken(b) + " "
            case .root(let c): return " الجذر التربيعي لـ " + spoken(c) + " "
            }
        }.joined()
    }
}

extension Character {
    var isASCIIDigit: Bool { ("0"..."9").contains(self) }
}

// MARK: - الخط

struct MathStyle {
    var size: CGFloat
    var weight: Font.Weight = .regular
    var design: Font.Design = .default

    var font: Font { .system(size: size, weight: weight, design: design) }

    func scaled(_ k: CGFloat) -> MathStyle {
        var s = self
        s.size = max(9, size * k)
        return s
    }

    /// حجم الخط حسب نمط النص وحجم الخط المختار في الجهاز.
    static func size(for style: Font.TextStyle) -> CGFloat {
        let ui: UIFont.TextStyle
        switch style {
        case .largeTitle: ui = .largeTitle
        case .title: ui = .title1
        case .title2: ui = .title2
        case .title3: ui = .title3
        case .headline: ui = .headline
        case .subheadline: ui = .subheadline
        case .callout: ui = .callout
        case .footnote: ui = .footnote
        case .caption: ui = .caption1
        case .caption2: ui = .caption2
        default: ui = .body
        }
        return UIFont.preferredFont(forTextStyle: ui).pointSize
    }
}

// MARK: - العرض داخل الفقرة (يلتف مع السطر)

enum MathInline {
    static func build(_ nodes: [MathNode], _ st: MathStyle) -> Text {
        nodes.reduce(Text(verbatim: "")) { $0 + piece($1, st) }
    }

    static func piece(_ n: MathNode, _ st: MathStyle) -> Text {
        switch n {
        case .text(let t):
            return Text(verbatim: t).font(st.font)
        case .group(let c):
            return Text(verbatim: "(").font(st.font) + build(c, st) + Text(verbatim: ")").font(st.font)
        case .sup(let c):
            return build(c, st.scaled(0.68)).baselineOffset(st.size * 0.42)
        case .frac(let a, let b):
            let small = st.scaled(0.75)
            return build(a, small).baselineOffset(st.size * 0.33)
                + Text(verbatim: "\u{2044}").font(st.font)
                + build(b, small)
        case .root(let c):
            let simple: Bool = {
                guard c.count == 1, case .text(let t) = c[0] else { return false }
                return !t.contains(" ")
            }()
            return Text(verbatim: "√").font(st.font) + (simple ? build(c, st) : piece(.group(c), st))
        }
    }

    /// نص كامل جاهز (يرجع النص كما هو إذا ما فيه رموز).
    static func text(_ s: String, _ st: MathStyle) -> Text {
        let nodes = MathParser.parse(s, stackDivision: false)
        guard MathParser.hasStructure(nodes) else { return Text(verbatim: s).font(st.font) }
        return build(nodes, st)
    }
}

// MARK: - العرض الكبير (كسور مكدّسة وجذور)

private enum MathPiece {
    case inline([MathNode])
    case frac([MathNode], [MathNode])
    case root([MathNode])
    case group([MathNode])
}

struct MathBlockView: View {
    let nodes: [MathNode]
    let style: MathStyle
    let rtl: Bool

    private var pieces: [MathPiece] {
        var out: [MathPiece] = []
        var buffer: [MathNode] = []
        func flush() {
            if !buffer.isEmpty { out.append(.inline(buffer)); buffer = [] }
        }
        for n in nodes {
            switch n {
            case .frac(let a, let b):
                flush(); out.append(.frac(a, b))
            case .root(let c):
                flush(); out.append(.root(c))
            case .group(let c) where MathParser.needsBlock(c):
                flush(); out.append(.group(c))
            default:
                buffer.append(n)
            }
        }
        flush()
        return out
    }

    private var iso: String { rtl ? MathParser.rli : MathParser.lri }

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            ForEach(Array(pieces.enumerated()), id: \.offset) { pair in
                view(for: pair.element)
            }
        }
    }

    private func view(for piece: MathPiece) -> AnyView {
        switch piece {
        case .inline(let ns):
            return AnyView(
                (Text(verbatim: iso) + MathInline.build(ns, style) + Text(verbatim: MathParser.pdi))
                    .fixedSize()
            )
        case .frac(let a, let b):
            let inner = style.scaled(0.86)
            let line = max(1, style.size * 0.065)
            return AnyView(
                Grid(alignment: .center, horizontalSpacing: 0, verticalSpacing: style.size * 0.1) {
                    GridRow { MathBlockView(nodes: trim(a), style: inner, rtl: rtl) }
                    GridRow {
                        Rectangle()
                            .frame(height: line)
                            .gridCellUnsizedAxes(.horizontal)
                    }
                    GridRow { MathBlockView(nodes: trim(b), style: inner, rtl: rtl) }
                }
                .padding(.horizontal, style.size * 0.18)
                .fixedSize()
            )
        case .root(let c):
            let sign = style.size * 0.62
            let line = max(1, style.size * 0.065)
            return AnyView(
                MathBlockView(nodes: trim(c), style: style, rtl: false)
                    .padding(.top, style.size * 0.2)
                    .padding(.leading, sign + 1)
                    .padding(.trailing, 2)
                    .overlay(RadicalShape(signWidth: sign).stroke(style: StrokeStyle(lineWidth: line, lineCap: .round, lineJoin: .round)))
                    .environment(\.layoutDirection, .leftToRight)
                    .fixedSize()
            )
        case .group(let c):
            let parenSize = style.scaled(1.6)
            return AnyView(
                HStack(alignment: .center, spacing: 1) {
                    Text(verbatim: iso + "(" + MathParser.pdi).font(.system(size: parenSize.size, weight: .light))
                    MathBlockView(nodes: c, style: style, rtl: rtl)
                    Text(verbatim: iso + ")" + MathParser.pdi).font(.system(size: parenSize.size, weight: .light))
                }
                .fixedSize()
            )
        }
    }

    private func trim(_ ns: [MathNode]) -> [MathNode] {
        var out = ns
        if let f = out.first, case .text(let t) = f {
            let s = String(t.drop(while: { $0 == " " }))
            if s.isEmpty { out.removeFirst() } else { out[0] = .text(s) }
        }
        if let l = out.last, case .text(let t) = l {
            var s = t
            while s.hasSuffix(" ") { s.removeLast() }
            if s.isEmpty { out.removeLast() } else { out[out.count - 1] = .text(s) }
        }
        return out
    }
}

/// علامة الجذر مع الخط الذي فوق ما تحت الجذر.
struct RadicalShape: Shape {
    var signWidth: CGFloat

    func path(in r: CGRect) -> Path {
        var p = Path()
        let w = signWidth
        let h = r.height
        p.move(to: CGPoint(x: r.minX + w * 0.04, y: r.minY + h * 0.6))
        p.addLine(to: CGPoint(x: r.minX + w * 0.26, y: r.minY + h * 0.5))
        p.addLine(to: CGPoint(x: r.minX + w * 0.55, y: r.maxY - 1))
        p.addLine(to: CGPoint(x: r.minX + w * 0.9, y: r.minY + 1))
        p.addLine(to: CGPoint(x: r.maxX, y: r.minY + 1))
        return p
    }
}

// MARK: - واجهات الاستخدام

/// نص فيه رياضيات يلتف داخل الفقرة (المسائل وخطوات الحل).
struct MathText: View {
    let text: String
    var style: Font.TextStyle = .body
    var weight: Font.Weight = .regular
    var design: Font.Design = .default
    @Environment(\.dynamicTypeSize) private var dynamicType

    init(_ text: String, style: Font.TextStyle = .body, weight: Font.Weight = .regular, design: Font.Design = .default) {
        self.text = text
        self.style = style
        self.weight = weight
        self.design = design
    }

    var body: some View {
        let st = MathStyle(size: MathStyle.size(for: style), weight: weight, design: design)
        let nodes = MathParser.parse(text, stackDivision: false)
        if MathParser.hasStructure(nodes) {
            MathInline.build(nodes, st)
                .accessibilityLabel(Text(verbatim: MathParser.spoken(nodes)))
        } else {
            Text(verbatim: text).font(st.font)
        }
    }
}

/// سطر رياضي بعرض كبير (كسور مكدّسة وجذور)، ويرجع للعرض داخل الفقرة إذا ما كفّت المساحة.
struct MathLine: View {
    let text: String
    var style: Font.TextStyle = .body
    var weight: Font.Weight = .regular
    var design: Font.Design = .default
    /// يُجبر الاتجاه من اليسار لليمين (القوانين الرمزية).
    var forceLTR = false
    @Environment(\.dynamicTypeSize) private var dynamicType

    init(_ text: String, style: Font.TextStyle = .body, weight: Font.Weight = .regular,
         design: Font.Design = .default, forceLTR: Bool = false) {
        self.text = text
        self.style = style
        self.weight = weight
        self.design = design
        self.forceLTR = forceLTR
    }

    private var mathStyle: MathStyle {
        MathStyle(size: MathStyle.size(for: style), weight: weight, design: design)
    }

    var body: some View {
        let isolated = text.hasPrefix(MathParser.lri)
        let plain = MathParser.stripIsolates(text)
        let ltr = forceLTR || isolated || !MathParser.hasArabicWord(plain)
        let fallbackText = (forceLTR && !isolated) ? MathParser.lri + text + MathParser.pdi : text
        let nodes = MathParser.parse(plain, stackDivision: true)
        if MathParser.needsBlock(nodes) {
            ViewThatFits(in: .horizontal) {
                MathBlockView(nodes: nodes, style: mathStyle, rtl: !ltr)
                    .environment(\.layoutDirection, ltr ? .leftToRight : .rightToLeft)
                MathInline.text(fallbackText, mathStyle)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(MathParser.spoken(nodes))
        } else {
            MathInline.text(fallbackText, mathStyle)
        }
    }
}

/// نص القانون: كل جزء مفصول بـ «،» في سطر مستقل.
struct FormulaExpressionView: View {
    let text: String
    var style: Font.TextStyle = .title3
    var weight: Font.Weight = .semibold
    var design: Font.Design = .rounded

    var body: some View {
        let isolated = text.hasPrefix(MathParser.lri)
        let lines = MathParser.stripIsolates(text)
            .components(separatedBy: MathParser.lineSeparator)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        VStack(spacing: 10) {
            ForEach(Array(lines.enumerated()), id: \.offset) { pair in
                MathLine(pair.element, style: style, weight: weight, design: design, forceLTR: isolated)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
