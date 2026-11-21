import SwiftUI

@main
public struct ArabicTriviaApp: App {
    
    public init() {
        // تهيئة محرك الأسئلة والبيانات عند انطلاق التطبيق
        _ = QuestionBankService.shared
        _ = DataManager.shared
        _ = UsedQuestionsTracker.shared
    }
    
    public var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
