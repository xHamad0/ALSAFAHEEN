import SwiftUI

// MARK: - App Color Palette & Theme
public struct AppTheme {
    // الخلفيات الأساسية الفاخرة (Dark Mode Primary)
    public static let bgDark = Color(hex: "#080C14")
    public static let bgSecondary = Color(hex: "#0F172A")
    public static let bgCard = Color(hex: "#162032")
    public static let bgCardElevated = Color(hex: "#1E293B")
    
    // لمسات الذهب الملكي الأنيقة
    public static let goldPrimary = Color(hex: "#E5B94E")
    public static let goldGlow = Color(hex: "#F59E0B")
    public static let goldDark = Color(hex: "#B45309")
    
    // ألوان النصوص
    public static let textPrimary = Color(hex: "#F8FAFC")
    public static let textSecondary = Color(hex: "#94A3B8")
    public static let textMuted = Color(hex: "#64748B")
    
    // ألوان الحالة
    public static let success = Color(hex: "#10B981")
    public static let error = Color(hex: "#EF4444")
    public static let warning = Color(hex: "#F59E0B")
    public static let info = Color(hex: "#3B82F6")
    
    // باليتات ألوان الفرق الافتراضية
    public static let defaultTeam1Color = "#3B82F6" // أزرق صلب
    public static let defaultTeam2Color = "#EF4444" // أحمر قرمزي
    
    public static let teamColorOptions: [String] = [
        "#3B82F6", // أزرق
        "#EF4444", // أحمر
        "#10B981", // زمردي
        "#8B5CF6", // بنفسجي
        "#F59E0B", // ذهبي
        "#EC4899", // وردي
        "#06B6D4", // فيروزي
        "#F97316"  // برتقالي
    ]
    
    // تدرجات الألوان الفاخرة
    public static let goldGradient = LinearGradient(
        colors: [Color(hex: "#FCD34D"), Color(hex: "#D97706")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    public static let bgGradient = LinearGradient(
        colors: [Color(hex: "#080C14"), Color(hex: "#0D1322"), Color(hex: "#111827")],
        startPoint: .top,
        endPoint: .bottom
    )
    
    public static let cardGradient = LinearGradient(
        colors: [Color(hex: "#1A2338").opacity(0.85), Color(hex: "#121A2A").opacity(0.85)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Color Extension for Hex
extension Color {
    public init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 255, 255, 255)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    public func toHex() -> String {
        return "#FFFFFF"
    }
}

// MARK: - Card & Button Styles
public struct PremiumCardModifier: ViewModifier {
    var borderColor: Color = AppTheme.goldPrimary.opacity(0.2)
    var cornerRadius: CGFloat = 20
    
    public func body(content: Content) -> some View {
        content
            .background(AppTheme.cardGradient)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor, lineWidth: 1.2)
            )
            .shadow(color: Color.black.opacity(0.4), radius: 10, x: 0, y: 5)
    }
}

extension View {
    public func premiumCard(borderColor: Color = AppTheme.goldPrimary.opacity(0.2), cornerRadius: CGFloat = 20) -> some View {
        self.modifier(PremiumCardModifier(borderColor: borderColor, cornerRadius: cornerRadius))
    }
}
