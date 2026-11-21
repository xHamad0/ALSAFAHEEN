import Foundation
import SwiftUI

/// مدير واجهة إدارة بنك الأسئلة والاستيراد
public final class QuestionBankViewModel: ObservableObject {
    @Published public var searchText: String = ""
    @Published public var importResult: ImportResult? = nil
    @Published public var showImportReport: Bool = false
    @Published public var isResetConfirmed: Bool = false
    @Published public var showResetSuccessAlert: Bool = false
    
    public let bankService = QuestionBankService.shared
    public let tracker = UsedQuestionsTracker.shared
    public let importer = JSONImporterService.shared
    
    public init() {}
    
    public var filteredCategories: [QuestionCategory] {
        if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            return QuestionCategory.allCases
        }
        return QuestionCategory.allCases.filter {
            $0.titleArabic.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    public func importJSON(from string: String) {
        guard let data = string.data(using: .utf8) else {
            self.importResult = ImportResult(
                totalParsed: 0,
                successfullyAdded: 0,
                duplicatesSkipped: 0,
                errors: ["تعذر قراءة بيانات النص بصيغة UTF-8."]
            )
            self.showImportReport = true
            return
        }
        
        let result = importer.importQuestions(from: data)
        self.importResult = result
        self.showImportReport = true
    }
    
    public func resetUsedHistory() {
        tracker.resetHistory()
        showResetSuccessAlert = true
    }
}
