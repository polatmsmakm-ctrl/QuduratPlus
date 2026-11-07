import Foundation

/// يلفّ المقطع الرياضي ليظهر من اليسار لليمين داخل النص العربي.
func m(_ s: String) -> String { "\u{2066}\(s)\u{2069}" }

/// تنسيق الرقم: يحذف الأصفار الزائدة.
func fmt(_ d: Double) -> String {
    if abs(d - d.rounded()) < 0.000001 { return String(Int(d.rounded())) }
    var s = String(format: "%.2f", d)
    while s.hasSuffix("0") { s.removeLast() }
    if s.hasSuffix(".") { s.removeLast() }
    return s
}

func pick<T>(_ a: [T]) -> T { a[Int.random(in: 0..<a.count)] }

func ipow(_ b: Int, _ e: Int) -> Int {
    var r = 1
    if e > 0 { for _ in 0..<e { r *= b } }
    return r
}

func gcd(_ a: Int, _ b: Int) -> Int { b == 0 ? a : gcd(b, a % b) }

func comb(_ n: Int, _ r: Int) -> Int {
    var res = 1
    for i in 0..<r { res = res * (n - i) / (i + 1) }
    return res
}

/// يقرأ رقماً أو كسراً (3/5) بأرقام عربية أو إنجليزية.
func parseNumber(_ raw: String) -> Double? {
    let digits: [Character: Character] = [
        "٠": "0", "١": "1", "٢": "2", "٣": "3", "٤": "4",
        "٥": "5", "٦": "6", "٧": "7", "٨": "8", "٩": "9",
        "٫": ".", "،": "."
    ]
    var t = String(raw.map { digits[$0] ?? $0 })
    t = t.replacingOccurrences(of: ",", with: ".")
    t = t.replacingOccurrences(of: "−", with: "-")
    for junk in ["%", "٪", " ", "π", "°", "\u{2066}", "\u{2069}"] {
        t = t.replacingOccurrences(of: junk, with: "")
    }
    if t.isEmpty { return nil }
    if t.contains("/") {
        let parts = t.split(separator: "/", omittingEmptySubsequences: false)
        if parts.count == 2,
           let a = Double(String(parts[0])),
           let b = Double(String(parts[1])),
           b != 0 {
            return a / b
        }
        return nil
    }
    return Double(t)
}

/// توحيد النص العربي للبحث (همزات، تاء مربوطة، تشكيل).
func norm(_ s: String) -> String {
    var t = s.lowercased()
    let map: [(String, String)] = [("أ", "ا"), ("إ", "ا"), ("آ", "ا"), ("ة", "ه"), ("ى", "ي"), ("ـ", "")]
    for (a, b) in map {
        t = t.replacingOccurrences(of: a, with: b)
    }
    let kept = t.unicodeScalars.filter { !(0x064B...0x065F).contains($0.value) }
    var out = String.UnicodeScalarView()
    out.append(contentsOf: kept)
    return String(out)
}

// MARK: - مساعدات توليد الأمثلة

/// يختار قيمة حسب مستوى الصعوبة.
func lv<T>(_ d: Difficulty, _ easy: T, _ medium: T, _ hard: T) -> T {
    switch d {
    case .easy: return easy
    case .medium: return medium
    case .hard: return hard
    }
}

/// عدد صحيح عشوائي ضمن المدى.
func rnd(_ r: ClosedRange<Int>) -> Int { Int.random(in: r) }

/// هل الرقم «نظيف» (بحد أقصى منزلتين عشريتين)؟
func isClean(_ d: Double) -> Bool {
    d.isFinite && abs(d * 100 - (d * 100).rounded()) < 0.000001
}

/// كسر مبسّط كنص مثل 2/5 (أو عدد صحيح إذا كان المقام 1).
func frac(_ n: Int, _ d: Int) -> String {
    guard d != 0 else { return "—" }
    let g = max(1, gcd(abs(n), abs(d)))
    let a = n / g, b = d / g
    if b == 1 { return String(a) }
    return "\(a)/\(b)"
}

/// عدد بإشارته داخل تعبير: «+ 5» أو «− 5».
func signed(_ v: Int) -> String {
    v < 0 ? "− \(-v)" : "+ \(v)"
}

/// حدّ فيه س بمعامل (مع إخفاء المعامل 1).
func term(_ c: Int, _ v: String = "س") -> String {
    if c == 1 { return v }
    if c == -1 { return "−\(v)" }
    return "\(c)\(v)"
}

/// كثيرة حدود من الدرجة الثانية: أس² + بس + ج.
func quad(_ a: Int, _ b: Int, _ c: Int) -> String {
    var s = term(a, "س²").replacingOccurrences(of: "-", with: "−")
    if b != 0 { s += " " + (b < 0 ? "− " : "+ ") + term(abs(b)) }
    if c != 0 { s += " " + signed(c) }
    return s
}

/// عامل خطي مثل (2س + 3) أو (س − 4).
func factor(_ c: Int, _ k: Int) -> String {
    "(" + term(c) + " " + signed(k) + ")"
}

/// قائمة أعداد مفصولة بفواصل داخل نص عربي.
func list(_ nums: [Int]) -> String {
    m(nums.map { String($0).replacingOccurrences(of: "-", with: "−") }.joined(separator: " , "))
}

/// يعيد أول ثلاثة نصوص مختلفة عن الإجابة وعن بعضها.
func distinct(_ answer: String, _ candidates: [String], count: Int = 3) -> [String] {
    var out: [String] = []
    for c in candidates where c != answer && !out.contains(c) {
        out.append(c)
        if out.count == count { break }
    }
    return out
}
