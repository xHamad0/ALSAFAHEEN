import Foundation
import SwiftUI

/// وسائل المساعدة المتاحة للفرق
public enum LifelineType: String, Codable, CaseIterable, Identifiable {
    case fiftyFifty = "fifty_fifty"
    case doublePoints = "double_points"
    case extraTime = "extra_time"
    case stealQuestion = "steal_question"
    
    public var id: String { rawValue }
    
    public var titleArabic: String {
        switch self {
        case .fiftyFifty: return "حذف إجابتين"
        case .doublePoints: return "مضاعفة النقاط"
        case .extraTime: return "تمديد الوقت"
        case .stealQuestion: return "سرقة السؤال"
        }
    }
    
    public var descriptionArabic: String {
        switch self {
        case .fiftyFifty: return "حذف خيارين خاطئين من الخيارات"
        case .doublePoints: return "مضاعفة نقاط هذا السؤال عند الإجابة الصحيحة"
        case .extraTime: return "إضافة 20 ثانية إضافية للمؤقت"
        case .stealQuestion: return "إتاحة الفرصة للمنافس للإجابة بعد خطأ الفريق الحالي"
        }
    }
    
    public var iconName: String {
        switch self {
        case .fiftyFifty: return "scissors"
        case .doublePoints: return "multiply.circle.fill"
        case .extraTime: return "clock.arrow.circlepath"
        case .stealQuestion: return "hand.raised.fill"
        }
    }
}
