import SwiftUI

/// لوحة اختيار قيمة وصعوبة السؤال (100 | 200 | 300 | 400 | 500)
public struct PointsPickerCard: View {
    let category: QuestionCategory
    let onSelectPoints: (DifficultyLevel) -> Void
    let questionBank = QuestionBankService.shared
    
    private let difficulties: [DifficultyLevel] = DifficultyLevel.allCases
    
    public var body: some View {
        VStack(spacing: 20) {
            // ترويسة التصنيف المختار
            HStack(spacing: 12) {
                Image(systemName: category.iconName)
                    .font(.title2)
                    .foregroundColor(category.themeColor)
                    .frame(width: 44, height: 44)
                    .background(category.themeColor.opacity(0.15))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("التصنيف النشط")
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                    Text(category.titleArabic)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.textPrimary)
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(AppTheme.bgCardElevated)
            .cornerRadius(16)
            
            // عنوان التحدي
            VStack(spacing: 6) {
                Text("اختر قيمة ونقاط السؤال")
                    .font(.title3)
                    .fontWeight(.heavy)
                    .foregroundColor(AppTheme.goldPrimary)
                
                Text("كلما زادت النقاط، زاد التحدي ومستوى الصعوبة!")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 4)
            
            // شبكة القيم الخمس الاحترافية (100 | 200 | 300 | 400 | 500)
            VStack(spacing: 12) {
                ForEach(difficulties, id: \.self) { diff in
                    let available = questionBank.availableCount(for: category, difficulty: diff)
                    let isAvailable = available > 0
                    
                    Button(action: {
                        onSelectPoints(diff)
                    }) {
                        HStack(spacing: 16) {
                            // بادج النقاط
                            ZStack {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(diff.gradient)
                                    .frame(width: 80, height: 60)
                                    .shadow(color: diff.primaryColor.opacity(0.4), radius: 6, x: 0, y: 3)
                                
                                VStack(spacing: 2) {
                                    Text("\(diff.points)")
                                        .font(.title2)
                                        .fontWeight(.black)
                                        .foregroundColor(.white)
                                    Text("نقطة")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.white.opacity(0.9))
                                }
                            }
                            
                            // تفاصيل مستوى الصعوبة
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 6) {
                                    Text(diff.titleArabic)
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(AppTheme.textPrimary)
                                    
                                    Image(systemName: diff.iconName)
                                        .font(.subheadline)
                                        .foregroundColor(diff.primaryColor)
                                }
                                
                                Text(diff.subtitleArabic)
                                    .font(.caption)
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                            
                            Spacer()
                            
                            // عدد الأسئلة المتبقية
                            VStack(alignment: .trailing, spacing: 2) {
                                if isAvailable {
                                    HStack(spacing: 4) {
                                        Text("\(available)")
                                            .font(.subheadline)
                                            .fontWeight(.bold)
                                            .foregroundColor(AppTheme.textPrimary)
                                        Text("متاح")
                                            .font(.caption2)
                                            .foregroundColor(AppTheme.textMuted)
                                    }
                                    Image(systemName: "chevron.left")
                                        .font(.caption)
                                        .foregroundColor(AppTheme.goldPrimary)
                                } else {
                                    Text("مستهلك")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(AppTheme.error)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(AppTheme.error.opacity(0.15))
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(AppTheme.bgCard)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(diff == .expert ? AppTheme.goldPrimary.opacity(0.6) : Color.white.opacity(0.08), lineWidth: diff == .expert ? 2 : 1)
                                )
                        )
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .disabled(!isAvailable)
                    .opacity(isAvailable ? 1.0 : 0.5)
                }
            }
        }
        .padding(20)
        .premiumCard()
    }
}

public struct ScaleButtonStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}
