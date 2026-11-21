import Foundation

/// نتيجة عملية استيراد بنك أسئلة من ملف JSON
public struct ImportResult {
    public let totalParsed: Int
    public let successfullyAdded: Int
    public let duplicatesSkipped: Int
    public let errors: [String]
    
    public var isSuccess: Bool {
        return successfullyAdded > 0 && errors.isEmpty
    }
}

/// خدمة استيراد وتحديث الأسئلة والتحقق من صحتها وجودتها
public final class JSONImporterService {
    public static let shared = JSONImporterService()
    
    private init() {}
    
    /// استيراد أسئلة من بيانات JSON
    public func importQuestions(from jsonData: Data) -> ImportResult {
        var errors: [String] = []
        var validQuestions: [Question] = []
        var duplicatesCount = 0
        
        let existingIDs = Set(QuestionBankService.shared.allQuestions.map { $0.id })
        var newIDsInBatch = Set<String>()
        
        // التحقق من بنية JSON
        guard let jsonArray = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [[String: Any]] else {
            return ImportResult(
                totalParsed: 0,
                successfullyAdded: 0,
                duplicatesSkipped: 0,
                errors: ["الملف ليس بصيغة مصفوفة JSON صالحة أو يحتوي على خطأ في بناء الجملة."]
            )
        }
        
        for (index, dict) in jsonArray.enumerated() {
            let rowNumber = index + 1
            
            // 1. التحقق من المعرف
            guard let id = dict["id"] as? String, !id.trimmingCharacters(in: .whitespaces).isEmpty else {
                errors.append("السؤال رقم \(rowNumber): لا يحتوي على معرّف (id) فريد.")
                continue
            }
            
            if existingIDs.contains(id) || newIDsInBatch.contains(id) {
                duplicatesCount += 1
                continue
            }
            
            // 2. التحقق من نص السؤال
            guard let text = dict["text"] as? String, !text.trimmingCharacters(in: .whitespaces).isEmpty else {
                errors.append("السؤال رقم \(rowNumber): نص السؤال فارغ.")
                continue
            }
            
            // 3. التحقق من الإجابة الصحيحة
            guard let answer = dict["answer"] as? String, !answer.trimmingCharacters(in: .whitespaces).isEmpty else {
                errors.append("السؤال رقم \(rowNumber): الإجابة الصحيحة مفقودة أو فارغة.")
                continue
            }
            
            // 4. التحقق من التصنيف
            guard let categoryRaw = dict["category"] as? String,
                  let category = QuestionCategory(rawValue: categoryRaw) else {
                errors.append("السؤال رقم \(rowNumber): التصنيف غير معتمد.")
                continue
            }
            
            // 5. التحقق من مستوى الصعوبة والنقاط (100, 200, 300, 400, 500)
            guard let diffRaw = dict["difficulty"] as? Int,
                  let difficulty = DifficultyLevel(rawValue: diffRaw) else {
                errors.append("السؤال رقم \(rowNumber): قيمة الصعوبة غير صالحة. يجب أن تكون 100 أو 200 أو 300 أو 400 أو 500.")
                continue
            }
            
            // 6. التحقق من نوع السؤال (ومنع صح أو خطأ بشكل صارم)
            guard let typeRaw = dict["type"] as? String else {
                errors.append("السؤال رقم \(rowNumber): نوع السؤال مفقود.")
                continue
            }
            
            if typeRaw == "true_false" || typeRaw == "boolean" || typeRaw == "صح_او_خطأ" {
                errors.append("السؤال رقم \(rowNumber): أسئلة صح أو خطأ ممنوعة تماماً في النظام.")
                continue
            }
            
            guard let questionType = QuestionType(rawValue: typeRaw) else {
                errors.append("السؤال رقم \(rowNumber): نوع السؤال غير معتمد (\(typeRaw)).")
                continue
            }
            
            // التحقق من وجود خيارات عند الاختيار من متعدد
            var optionsList: [String]? = nil
            if questionType == .multipleChoice {
                guard let opts = dict["options"] as? [String], opts.count >= 2 else {
                    errors.append("السؤال رقم \(rowNumber): أسئلة الاختيار من متعدد تتطلب خيارين على الأقل.")
                    continue
                }
                optionsList = opts
            }
            
            // 7. التحقق الصارم من فئة الحروف
            let letter = dict["letter"] as? String
            if category == .letters {
                guard let charStr = letter, !charStr.trimmingCharacters(in: .whitespaces).isEmpty else {
                    errors.append("السؤال رقم \(rowNumber): سؤال فئة الحروف لا يحتوي على الحرف المحدد.")
                    continue
                }
                
                if !ArabicNormalizer.startsWithLetter(answer, letter: charStr) {
                    errors.append("السؤال رقم \(rowNumber): إجابة سؤال الحروف (\(answer)) لا تبدأ بالحرف المحدد (\(charStr)).")
                    continue
                }
            }
            
            let explanation = dict["explanation"] as? String
            let flagImage = dict["flagImage"] as? String
            let flagCountryCode = dict["flagCountryCode"] as? String
            
            let question = Question(
                id: id,
                text: text,
                answer: answer,
                options: optionsList,
                category: category,
                difficulty: difficulty,
                type: questionType,
                explanation: explanation,
                letter: letter,
                flagImage: flagImage,
                flagCountryCode: flagCountryCode
            )
            
            newIDsInBatch.insert(id)
            validQuestions.append(question)
        }
        
        // حفظ الأسئلة الصالحة إلى قرص التخزين
        if !validQuestions.isEmpty {
            saveToImportedFolder(validQuestions: validQuestions)
            QuestionBankService.shared.appendImportedQuestions(validQuestions)
        }
        
        return ImportResult(
            totalParsed: jsonArray.count,
            successfullyAdded: validQuestions.count,
            duplicatesSkipped: duplicatesCount,
            errors: errors
        )
    }
    
    private func saveToImportedFolder(validQuestions: [Question]) {
        let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let folder = documentsDir.appendingPathComponent("ImportedQuestions")
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        
        let batchFile = folder.appendingPathComponent("batch_\(Int(Date().timeIntervalSince1970)).json")
        if let data = try? JSONEncoder().encode(validQuestions) {
            try? data.write(to: batchFile, options: .atomic)
        }
    }
}
