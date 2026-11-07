import SwiftUI
import UniformTypeIdentifiers

/// ملف النسخة الاحتياطية للتصدير عبر تطبيق الملفات.
struct BackupDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    var data: Data

    init(data: Data) { self.data = data }

    init(configuration: ReadConfiguration) throws {
        guard let d = configuration.file.regularFileContents else { throw CocoaError(.fileReadCorruptFile) }
        data = d
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}

// MARK: - الإعدادات

struct SettingsView: View {
    @EnvironmentObject var store: Store
    @State private var exporting = false
    @State private var importing = false
    @State private var exportDoc = BackupDocument(data: Data())
    @State private var pending: BackupFile?
    @State private var message: String?
    @State private var confirmReset = false

    private var hasExamDate: Binding<Bool> {
        Binding(
            get: { store.progress.examDate != nil },
            set: { on in
                store.progress.examDate = on ? Calendar.current.date(byAdding: .day, value: 30, to: Date()) : nil
            }
        )
    }

    private var examDate: Binding<Date> {
        Binding(
            get: { store.progress.examDate ?? Date() },
            set: { store.progress.examDate = $0 }
        )
    }

    private var dailyGoal: Binding<Int> {
        Binding(get: { store.progress.dailyGoal }, set: { store.progress.dailyGoal = $0 })
    }

    var body: some View {
        Form {
            Section {
                Picker("مستوى الصعوبة", selection: $store.difficulty) {
                    ForEach(Difficulty.allCases) { Text($0.title).tag($0) }
                }
                Picker("طريقة الإجابة", selection: $store.answerMode) {
                    ForEach(AnswerMode.allCases) { Text($0.title).tag($0) }
                }
                Toggle(isOn: $store.timingEnabled) {
                    Label("الوقت لكل سؤال", systemImage: "timer")
                }
            } header: {
                Text("التمرين")
            } footer: {
                Text("عند تفعيل الوقت يظهر مؤقت في التمرين، ويُحفظ متوسط وقتك لكل باب في متابعتي. القدرات فيها تقريباً دقيقة لكل سؤال.")
            }

            Section("المظهر") {
                Picker("المظهر", selection: $store.appearance) {
                    ForEach(Appearance.allCases) { Text($0.title).tag($0) }
                }
                .pickerStyle(.segmented)
            }

            Section {
                Toggle("عندي موعد اختبار", isOn: hasExamDate)
                if store.progress.examDate != nil {
                    DatePicker("موعد الاختبار", selection: examDate, in: Date()..., displayedComponents: .date)
                }
                Stepper(value: dailyGoal, in: 5...100, step: 5) {
                    HStack {
                        Text("هدف اليوم")
                        Spacer()
                        Text("\(store.progress.dailyGoal) سؤال").foregroundColor(.secondary).monospacedDigit()
                    }
                }
            } header: {
                Text("الخطة")
            } footer: {
                Text("يظهر عدّاد الأيام المتبقية وخطة اليوم في متابعتي.")
            }

            Section("التنبيه اليومي") {
                Toggle("قانون اليوم كل يوم", isOn: $store.dailyOn)
                if store.dailyOn {
                    DatePicker("وقت التنبيه", selection: $store.dailyTime, displayedComponents: .hourAndMinute)
                }
            }

            Section {
                Button {
                    if let d = store.backupData() {
                        exportDoc = BackupDocument(data: d)
                        exporting = true
                    } else {
                        message = "تعذّر تجهيز النسخة الاحتياطية."
                    }
                } label: {
                    Label("تصدير نسخة احتياطية", systemImage: "square.and.arrow.up")
                }
                Button {
                    importing = true
                } label: {
                    Label("استرجاع من ملف", systemImage: "square.and.arrow.down")
                }
            } header: {
                Text("النسخ الاحتياطي")
            } footer: {
                Text("يحفظ المفضلة والإحصائيات وبطاقات المراجعة ودفتر الأخطاء والاختبارات في ملف JSON تحفظه في تطبيق الملفات أو ترسله لنفسك.")
            }

            Section {
                NavigationLink(destination: AuditView()) {
                    Label("فحص الأمثلة", systemImage: "checkmark.seal")
                }
                Button(role: .destructive) { confirmReset = true } label: {
                    Label("مسح التقدم", systemImage: "arrow.counterclockwise")
                }
            } header: {
                Text("أدوات")
            } footer: {
                Text("مسح التقدم يحذف الإحصائيات والمراجعة والأخطاء والاختبارات، وتبقى المفضلة والإعدادات.")
            }

            Section {
                HStack {
                    Text("الإصدار")
                    Spacer()
                    Text(appVersion).foregroundColor(.secondary)
                }
                Text("كل شيء محفوظ على جهازك فقط، والتطبيق يشتغل بدون إنترنت وبدون حساب.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("الإعدادات")
        .fileExporter(isPresented: $exporting, document: exportDoc, contentType: .json,
                      defaultFilename: "QuduratPlus-" + DayKey.key(Date())) { result in
            switch result {
            case .success: message = "تم حفظ النسخة الاحتياطية."
            case .failure: message = "ما انحفظ الملف."
            }
        }
        .fileImporter(isPresented: $importing, allowedContentTypes: [.json]) { result in
            guard case .success(let url) = result else { return }
            let scoped = url.startAccessingSecurityScopedResource()
            defer { if scoped { url.stopAccessingSecurityScopedResource() } }
            if let data = try? Data(contentsOf: url), let b = Store.readBackup(data) {
                pending = b
            } else {
                message = "الملف غير صالح أو ليس نسخة من قدرات+."
            }
        }
        .confirmationDialog(pendingTitle, isPresented: Binding(get: { pending != nil }, set: { if !$0 { pending = nil } }),
                            titleVisibility: .visible) {
            Button("دمج مع الموجود") { apply(merge: true) }
            Button("استبدال الكل", role: .destructive) { apply(merge: false) }
            Button("إلغاء", role: .cancel) { pending = nil }
        }
        .confirmationDialog("مسح كل التقدم؟ ما تقدر تتراجع إلا من نسخة احتياطية.", isPresented: $confirmReset,
                            titleVisibility: .visible) {
            Button("مسح التقدم", role: .destructive) {
                store.resetProgress()
                Haptics.success()
            }
            Button("إلغاء", role: .cancel) {}
        }
        .alert(message ?? "", isPresented: Binding(get: { message != nil }, set: { if !$0 { message = nil } })) {
            Button("تم", role: .cancel) {}
        }
    }

    private var pendingTitle: String {
        guard let b = pending else { return "" }
        return "نسخة بتاريخ " + b.createdAt.formatted(date: .abbreviated, time: .shortened) + ". كيف تبي تسترجعها؟"
    }

    private func apply(merge: Bool) {
        guard let b = pending else { return }
        store.restore(b, merge: merge)
        pending = nil
        Haptics.success()
        message = merge ? "تم الدمج." : "تم الاسترجاع."
    }

    private var appVersion: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1"
        let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(v) (\(b))"
    }
}
