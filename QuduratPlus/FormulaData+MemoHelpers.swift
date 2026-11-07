import Foundation

// مساعدات مشتركة لأسئلة الفصول 1 إلى 3 من المذكرة (الأعداد، الحدوديات، المتباينات).

/// يحوّل الناقص العادي إلى إشارة الطرح الرياضية.
func mcNg(_ s: String) -> String { s.replacingOccurrences(of: "-", with: "−") }

/// عدد صحيح بإشارة رياضية.
func mcI(_ v: Int) -> String { mcNg(String(v)) }

/// عبارة خطية: ك·متغير + ثابت (إذا كان المعامل صفراً يظهر الثابت فقط).
func mcLin(_ c: Int, _ v: String, _ k: Int) -> String {
    if c == 0 { return mcNg(String(k)) }
    var s = term(c, v)
    if k != 0 { s += " " + signed(k) }
    return mcNg(s)
}

/// حدودية بمعاملات من الأعلى درجة إلى الثابت.
func mcPoly(_ cs: [Int], _ v: String = "س") -> String {
    let supers = [2: "²", 3: "³", 4: "⁴", 5: "⁵"]
    var parts: [String] = []
    for (i, c) in cs.enumerated() where c != 0 {
        let deg = cs.count - 1 - i
        let mag = abs(c)
        var body = ""
        if deg == 0 {
            body = String(mag)
        } else if deg == 1 {
            body = (mag == 1 ? "" : String(mag)) + v
        } else {
            body = (mag == 1 ? "" : String(mag)) + v + (supers[deg] ?? "")
        }
        if parts.isEmpty {
            parts.append(c < 0 ? "−" + body : body)
        } else {
            parts.append((c < 0 ? "− " : "+ ") + body)
        }
    }
    return parts.isEmpty ? "0" : parts.joined(separator: " ")
}

/// كسر جبري: (بسط)/(مقام).
func mcFrac(_ n: String, _ d: String) -> String { "(\(n))/(\(d))" }

/// مجموعة أعداد صحيحة مرتبة: {−1 , 7}.
func mcSetInts(_ xs: [Int]) -> String {
    let parts = xs.sorted().map { mcI($0) }
    return m("{" + parts.joined(separator: " , ") + "}")
}

/// مجموعة كسور (بسط، مقام) مرتبة بالقيمة.
func mcSetFr(_ xs: [(Int, Int)]) -> String {
    let sorted = xs.sorted { (a: (Int, Int), b: (Int, Int)) -> Bool in
        Double(a.0) / Double(a.1) < Double(b.0) / Double(b.1)
    }
    let parts = sorted.map { mcNg(frac($0.0, $0.1)) }
    return m("{" + parts.joined(separator: " , ") + "}")
}

/// فترة: (أ , ب) أو [أ , ب] أو مختلطة.
func mcIv(_ lo: String, _ hi: String, _ lc: Bool, _ hc: Bool) -> String {
    let l = lc ? "[" : "("
    let r = hc ? "]" : ")"
    return "\(l)\(lo) , \(hi)\(r)"
}

/// فترة بأعداد صحيحة.
struct McInterval {
    var lo: Int
    var hi: Int
    var loClosed: Bool
    var hiClosed: Bool

    var text: String {
        if lo == hi { return "{\(mcI(lo))}" }
        return mcIv(mcI(lo), mcI(hi), loClosed, hiClosed)
    }

    /// التقاطع، أو nil إذا كان فارغاً.
    func intersect(_ o: McInterval) -> McInterval? {
        let newLo = max(lo, o.lo)
        let newHi = min(hi, o.hi)
        let lc: Bool
        if lo == o.lo { lc = loClosed && o.loClosed } else if lo > o.lo { lc = loClosed } else { lc = o.loClosed }
        let hc: Bool
        if hi == o.hi { hc = hiClosed && o.hiClosed } else if hi < o.hi { hc = hiClosed } else { hc = o.hiClosed }
        if newLo < newHi || (newLo == newHi && lc && hc) {
            return McInterval(lo: newLo, hi: newHi, loClosed: lc, hiClosed: hc)
        }
        return nil
    }

    /// الاتحاد كنص (فترة واحدة إذا كانتا متصلتين، وإلا فترتان).
    func union(_ o: McInterval) -> String {
        let a = lo <= o.lo ? self : o
        let b = lo <= o.lo ? o : self
        let connected = b.lo < a.hi || (b.lo == a.hi && (a.hiClosed || b.loClosed))
        if !connected { return a.text + " ∪ " + b.text }
        let newLo = min(a.lo, b.lo)
        let lc: Bool = a.lo == b.lo ? (a.loClosed || b.loClosed) : a.loClosed
        let newHi = max(a.hi, b.hi)
        let hc: Bool
        if a.hi == b.hi { hc = a.hiClosed || b.hiClosed } else if a.hi > b.hi { hc = a.hiClosed } else { hc = b.hiClosed }
        return McInterval(lo: newLo, hi: newHi, loClosed: lc, hiClosed: hc).text
    }
}
