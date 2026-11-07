import Foundation
import SwiftUI
import UserNotifications

/// طريقة الإجابة في التمرين.
enum AnswerMode: String, CaseIterable, Identifiable {
    case choices, typing

    var id: String { rawValue }

    var title: String {
        switch self {
        case .choices: return "اختيار من متعدد"
        case .typing: return "كتابة الجواب"
        }
    }
}

/// مظهر التطبيق.
enum Appearance: String, CaseIterable, Identifiable {
    case system, light, dark

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: return "حسب الجهاز"
        case .light: return "فاتح"
        case .dark: return "داكن"
        }
    }

    var scheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

/// تبويبات التطبيق.
enum AppTab: Hashable {
    case library, practice, exam, review, progress
}

final class Store: ObservableObject {
    /// سجل التقدم المحفوظ في ملف (أيام، أبواب، بطاقات المراجعة، الأخطاء، الاختبارات).
    @Published var progress: ProgressData {
        didSet { if progress != oldValue { saveProgress() } }
    }
    /// مؤقت لكل سؤال في التمرين (اختياري من الإعدادات).
    @Published var timingEnabled: Bool {
        didSet { UserDefaults.standard.set(timingEnabled, forKey: "timingEnabled") }
    }
    /// التبويب الظاهر، وطلب تمرين على باب معيّن (من خطة اليوم).
    @Published var tab: AppTab = .library
    @Published var practiceRequest: Topic? = nil

    /// فاتح / داكن / حسب الجهاز.
    @Published var appearance: Appearance {
        didSet { UserDefaults.standard.set(appearance.rawValue, forKey: "appearance") }
    }
    /// مستوى الصعوبة المفضّل للأمثلة والتمرين.
    @Published var difficulty: Difficulty {
        didSet { UserDefaults.standard.set(difficulty.rawValue, forKey: "difficulty") }
    }
    /// طريقة الإجابة المفضّلة في التمرين.
    @Published var answerMode: AnswerMode {
        didSet { UserDefaults.standard.set(answerMode.rawValue, forKey: "answerMode") }
    }
    @Published var favorites: Set<String> {
        didSet { UserDefaults.standard.set(Array(favorites), forKey: "favorites") }
    }
    @Published var right: [String: Int]
    @Published var wrong: [String: Int]
    @Published var dailyOn: Bool {
        didSet {
            UserDefaults.standard.set(dailyOn, forKey: "dailyOn")
            reschedule()
        }
    }
    @Published var dailyTime: Date {
        didSet {
            UserDefaults.standard.set(dailyTime.timeIntervalSince1970, forKey: "dailyTimeTS")
            if dailyOn { reschedule() }
        }
    }

    init() {
        let d = UserDefaults.standard
        progress = Store.loadProgress()
        timingEnabled = d.bool(forKey: "timingEnabled")
        appearance = Appearance(rawValue: d.string(forKey: "appearance") ?? "") ?? .system
        difficulty = Difficulty(rawValue: d.string(forKey: "difficulty") ?? "") ?? .medium
        answerMode = AnswerMode(rawValue: d.string(forKey: "answerMode") ?? "") ?? .choices
        favorites = Set(d.stringArray(forKey: "favorites") ?? [])
        right = (d.dictionary(forKey: "right") as? [String: Int]) ?? [:]
        wrong = (d.dictionary(forKey: "wrong") as? [String: Int]) ?? [:]
        dailyOn = d.bool(forKey: "dailyOn")
        let ts = d.double(forKey: "dailyTimeTS")
        if ts > 0 {
            dailyTime = Date(timeIntervalSince1970: ts)
        } else {
            dailyTime = Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date()) ?? Date()
        }
    }

    // MARK: المفضلة

    func isFavorite(_ id: String) -> Bool { favorites.contains(id) }

    func toggle(_ id: String) {
        if favorites.contains(id) {
            favorites.remove(id)
        } else {
            favorites.insert(id)
        }
    }

    var favoriteFormulas: [Formula] {
        FormulaData.all.filter { favorites.contains($0.id) }
    }

    // MARK: الإحصائيات

    func record(_ id: String, correct: Bool) {
        if correct {
            right[id, default: 0] += 1
        } else {
            wrong[id, default: 0] += 1
        }
        UserDefaults.standard.set(right, forKey: "right")
        UserDefaults.standard.set(wrong, forKey: "wrong")
    }

    private func gap(_ id: String) -> Int {
        return (wrong[id] ?? 0) - (right[id] ?? 0)
    }

    /// القوانين التي أخطأت فيها أكثر مما أصبت.
    func weakFormulas() -> [Formula] {
        let list = FormulaData.all.filter { gap($0.id) > 0 }
        return list.sorted { gap($0.id) > gap($1.id) }
    }

    // MARK: التنبيه اليومي

    func refreshDaily() {
        if dailyOn { reschedule() }
    }

    private func reschedule() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        guard dailyOn else { return }
        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            guard granted else { return }
            DispatchQueue.main.async {
                self.scheduleNext()
            }
        }
    }

    private func scheduleNext() {
        let center = UNUserNotificationCenter.current()
        let cal = Calendar.current
        let tc = cal.dateComponents([.hour, .minute], from: dailyTime)
        let now = Date()
        for i in 0..<30 {
            guard let day = cal.date(byAdding: .day, value: i, to: now) else { continue }
            var dc = cal.dateComponents([.year, .month, .day], from: day)
            dc.hour = tc.hour
            dc.minute = tc.minute
            guard let fire = cal.date(from: dc), fire > now else { continue }
            let f = FormulaData.formula(forDay: day)
            let content = UNMutableNotificationContent()
            content.title = "قانون اليوم: \(f.title)"
            content.body = f.shown
            content.sound = .default
            let trigger = UNCalendarNotificationTrigger(dateMatching: dc, repeats: false)
            let req = UNNotificationRequest(identifier: "daily-\(i)", content: content, trigger: trigger)
            center.add(req)
        }
    }
}
