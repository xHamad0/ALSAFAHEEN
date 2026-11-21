import Foundation
import Combine

/// الخدمة المركزية لإدارة بنك الأسئلة والتحميل والتوزيع
public final class QuestionBankService: ObservableObject {
    public static let shared = QuestionBankService()
    
    @Published public private(set) var allQuestions: [Question] = []
    @Published public private(set) var questionsByCategory: [QuestionCategory: [Question]] = [:]
    @Published public private(set) var isLoaded: Bool = false
    @Published public private(set) var totalQuestionsCount: Int = 0
    
    private let tracker = UsedQuestionsTracker.shared
    private let queue = DispatchQueue(label: "com.sijal.questionBankQueue", attributes: .concurrent)
    
    private init() {
        loadAllQuestions()
    }
    
    /// تحميل جميع الأسئلة من الحزم الأساسية والمستوردة
    public func loadAllQuestions() {
        queue.async(flags: .barrier) {
            var loadedList: [Question] = []
            var existingIDs: Set<String> = []
            
            // 1. تحميل الأسئلة من الحزمة المدمجة (Bundle)
            for category in QuestionCategory.allCases {
                if let url = Bundle.main.url(forResource: category.jsonFileName, withExtension: "json", subdirectory: "QuestionBank") ??
                             Bundle.main.url(forResource: category.jsonFileName, withExtension: "json") {
                    if let questions = self.decodeQuestions(from: url) {
                        for q in questions {
                            if !existingIDs.contains(q.id) {
                                existingIDs.insert(q.id)
                                loadedList.append(q)
                            }
                        }
                    }
                }
            }
            
            // 2. تحميل الأسئلة المستوردة من مجلد المستندات
            let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let importedFolder = documentsDir.appendingPathComponent("ImportedQuestions")
            if FileManager.default.fileExists(atPath: importedFolder.path) {
                if let files = try? FileManager.default.contentsOfDirectory(at: importedFolder, includingPropertiesForKeys: nil) {
                    for file in files where file.pathExtension == "json" {
                        if let questions = self.decodeQuestions(from: file) {
                            for q in questions {
                                if !existingIDs.contains(q.id) {
                                    existingIDs.insert(q.id)
                                    loadedList.append(q)
                                }
                            }
                        }
                    }
                }
            }
            
            // تصنيف الأسئلة
            var grouped: [QuestionCategory: [Question]] = [:]
            for cat in QuestionCategory.allCases {
                grouped[cat] = []
            }
            for q in loadedList {
                grouped[q.category, default: []].append(q)
            }
            
            DispatchQueue.main.async {
                self.allQuestions = loadedList
                self.questionsByCategory = grouped
                self.totalQuestionsCount = loadedList.count
                self.isLoaded = true
            }
        }
    }
    
    private func decodeQuestions(from url: URL) -> [Question]? {
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([Question].self, from: data)
        } catch {
            print("Error decoding questions from \(url.lastPathComponent): \(error)")
            return nil
        }
    }
    
    /// الحصول على سؤال غير مستخدم لتصنيف معين وقيمة صعوبة معينة (100, 200, 300, 400, 500)
    public func fetchQuestion(for category: QuestionCategory, difficulty: DifficultyLevel) -> Question? {
        queue.sync {
            let candidates = (questionsByCategory[category] ?? []).filter {
                $0.difficulty == difficulty && !tracker.isUsed(id: $0.id)
            }
            
            if let selected = candidates.shuffled().first {
                return selected
            }
            
            // إذا نفدت الأسئلة بالقيمة المطلوبة بالتحديد، نبحث عن أقرب قيمة غير مستخدمة لنفس التصنيف
            let fallbackCandidates = (questionsByCategory[category] ?? []).filter {
                !tracker.isUsed(id: $0.id)
            }
            return fallbackCandidates.shuffled().first
        }
    }
    
    /// عدد الأسئلة الكلية لتصنيف معين
    public func count(for category: QuestionCategory) -> Int {
        return questionsByCategory[category]?.count ?? 0
    }
    
    /// عدد الأسئلة المتاحة (التي لم تلعب بعد) لتصنيف معين
    public func availableCount(for category: QuestionCategory) -> Int {
        guard let list = questionsByCategory[category] else { return 0 }
        let usedIDs = tracker.getAllUsedIDs()
        return list.filter { !usedIDs.contains($0.id) }.count
    }
    
    /// عدد الأسئلة المتاحة لقيمة صعوبة معينة داخل تصنيف
    public func availableCount(for category: QuestionCategory, difficulty: DifficultyLevel) -> Int {
        guard let list = questionsByCategory[category] else { return 0 }
        let usedIDs = tracker.getAllUsedIDs()
        return list.filter { $0.difficulty == difficulty && !usedIDs.contains($0.id) }.count
    }
    
    /// إجمالي الأسئلة المتاحة في البنك بالكامل
    public var totalAvailableCount: Int {
        let usedIDs = tracker.getAllUsedIDs()
        return allQuestions.filter { !usedIDs.contains($0.id) }.count
    }
    
    /// إضافة أسئلة مستوردة مباشرة إلى الذاكرة
    public func appendImportedQuestions(_ newQuestions: [Question]) {
        queue.async(flags: .barrier) {
            var currentIDs = Set(self.allQuestions.map { $0.id })
            var added: [Question] = []
            
            for q in newQuestions {
                if !currentIDs.contains(q.id) {
                    currentIDs.insert(q.id)
                    added.append(q)
                }
            }
            
            var updatedList = self.allQuestions + added
            var grouped = self.questionsByCategory
            for q in added {
                grouped[q.category, default: []].append(q)
            }
            
            DispatchQueue.main.async {
                self.allQuestions = updatedList
                self.questionsByCategory = grouped
                self.totalQuestionsCount = updatedList.count
            }
        }
    }
}
