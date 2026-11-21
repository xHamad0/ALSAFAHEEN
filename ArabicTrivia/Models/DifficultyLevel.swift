import Foundation
import SwiftUI

/// مستويات الصعوبة وقيم النقاط الخمس (100 - 500)
public enum DifficultyLevel: Int, Codable, CaseIterable, Comparable {
    case veryEasy = 100
    case easy = 200
    case medium = 300
    case hard = 400
    case expert = 500
    
    public var points: Int {
        return self.rawValue
    }
    
    public var titleArabic: String {
        switch self {
        case .veryEasy: return "سهل جداً"
        case .easy: return "سهل"
        case .medium: return "متوسط"
        case .hard: return "صعب"
        case .expert: return "خبير ومتقدم"
        }
    }
    
    public var subtitleArabic: String {
        switch self {
        case .veryEasy: return "بداية المشوار"
        case .easy: return "معلومات أساسية"
        case .medium: return "تحدٍ متوازن"
        case .hard: return "معلومات دقيقة"
        case .expert: return "تحدي العباقرة"
        }
    }
    
    public var iconName: String {
        switch self {
        case .veryEasy: return "sparkles"
        case .easy: return "flame"
        case .medium: return "flame.fill"
        case .hard: return "bolt.fill"
        case .expert: return "crown.fill"
        }
    }
    
    public var primaryColor: Color {
        switch self {
        case .veryEasy: return Color(hex: "#10B981") // زمردي هادئ
        case .easy: return Color(hex: "#3B82F6") // أزرق ساطع
        case .medium: return Color(hex: "#F59E0B") // برتقالي ذهبي
        case .hard: return Color(hex: "#EC4899") // وردي أرجواني
        case .expert: return Color(hex: "#8B5CF6") // بنفسجي ملكي فخم
        }
    }
    
    public var gradient: LinearGradient {
        switch self {
        case .veryEasy:
            return LinearGradient(colors: [Color(hex: "#10B981"), Color(hex: "#059669")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .easy:
            return LinearGradient(colors: [Color(hex: "#3B82F6"), Color(hex: "#2563EB")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .medium:
            return LinearGradient(colors: [Color(hex: "#F59E0B"), Color(hex: "#D97706")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .hard:
            return LinearGradient(colors: [Color(hex: "#EC4899"), Color(hex: "#DB2777")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .expert:
            return LinearGradient(colors: [Color(hex: "#8B5CF6"), Color(hex: "#7C3AED")], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
    
    public static func < (lhs: DifficultyLevel, rhs: DifficultyLevel) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}
