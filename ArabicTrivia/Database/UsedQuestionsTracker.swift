import Foundation

/// نظام منع تكرار الأسئلة عبر المباريات والجلسات
public final class UsedQuestionsTracker: ObservableObject {
    public static let shared = UsedQuestionsTracker()
    
    private let fileName = "sijal_used_questions.json"
    private var usedQuestionIDs: Set<String> = []
    private let queue = DispatchQueue(label: "com.sijal.usedQuestionsQueue", attributes: .concurrent)
    
    @Published public private(set) var totalUsedCount: Int = 0
    
    private init() {
        loadFromDisk()
    }
    
    private var fileURL: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent(fileName)
    }
    
    /// تحميل سجل الأسئلة المستخدمة من القرص
    private func loadFromDisk() {
        queue.sync(flags: .barrier) {
            do {
                if FileManager.default.fileExists(atPath: fileURL.path) {
                    let data = try Data(contentsOf: fileURL)
                    let array = try JSONDecoder().decode([String].self, from: data)
                    self.usedQuestionIDs = Set(array)
                    DispatchQueue.main.async {
                        self.totalUsedCount = self.usedQuestionIDs.count
                    }
                }
            } catch {
                print("Error loading used questions: \(error)")
                self.usedQuestionIDs = []
            }
        }
    }
    
    /// حفظ سجل الأسئلة المستخدمة إلى القرص
    private func saveToDisk() {
        queue.async(flags: .barrier) {
            do {
                let array = Array(self.usedQuestionIDs)
                let data = try JSONEncoder().encode(array)
                try data.write(to: self.fileURL, options: .atomic)
                DispatchQueue.main.async {
                    self.totalUsedCount = self.usedQuestionIDs.count
                }
            } catch {
                print("Error saving used questions: \(error)")
            }
        }
    }
    
    /// التحقق مما إذا كان السؤال قد استُخدم سابقاً
    public func isUsed(id: String) -> Bool {
        queue.sync {
            return usedQuestionIDs.contains(id)
        }
    }
    
    /// تسجيل السؤال كسؤال مستخدم
    public func markAsUsed(id: String) {
        queue.sync(flags: .barrier) {
            _ = usedQuestionIDs.insert(id)
        }
        saveToDisk()
    }
    
    /// تسجيل قائمة أسئلة مستخدمة دفعة واحدة
    public func markBatchAsUsed(ids: [String]) {
        queue.sync(flags: .barrier) {
            for id in ids {
                usedQuestionIDs.insert(id)
            }
        }
        saveToDisk()
    }
    
    /// إعادة ضبط سجل الأسئلة بالكامل (بعد تأكيد المستخدم)
    public func resetHistory() {
        queue.sync(flags: .barrier) {
            usedQuestionIDs.removeAll()
        }
        saveToDisk()
    }
    
    /// الحصول على جميع المعرّفات المستخدمة
    public func getAllUsedIDs() -> Set<String> {
        queue.sync {
            return usedQuestionIDs
        }
    }
}
