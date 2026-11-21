import Foundation
import SwiftUI

/// أنواع الأسئلة المسموح بها في اللعبة (ممنوع تماماً صح أو خطأ)
public enum QuestionType: String, Codable, CaseIterable {
    case multipleChoice = "multiple_choice"
    case directAnswer = "direct_answer"
    case fillInBlank = "fill_in_blank"
    
    public var titleArabic: String {
        switch self {
        case .multipleChoice: return "اختيار من متعدد"
        case .directAnswer: return "إجابة مباشرة"
        case .fillInBlank: return "أكمل الفراغ"
        }
    }
    
    public var iconName: String {
        switch self {
        case .multipleChoice: return "list.bullet.circle.fill"
        case .directAnswer: return "bolt.shield.fill"
        case .fillInBlank: return "character.cursor.ibeam"
        }
    }
}
