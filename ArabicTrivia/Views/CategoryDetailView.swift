import SwiftUI

/// شاشة تفاصيل التصنيف وتوزيع مستويات الصعوبة والنقاط
public struct CategoryDetailView: View {
    let category: QuestionCategory
    let questionBank = QuestionBankService.shared
    
    public var body: some View {
        ZStack {
            AppTheme.bgGradient
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // ترويسة التصنيف
                    VStack(spacing: 12) {
                        Image(systemName: category.iconName)
                            .font(.system(size: 48))
                            .foregroundColor(category.themeColor)
                            .frame(width: 88, height: 88)
                            .background(category.themeColor.opacity(0.15))
                            .clipShape(Circle())
                            .overlay(
                                Circle().stroke(category.themeColor.opacity(0.4), lineWidth: 2)
                            )
                        
                        Text(category.titleArabic)
                            .font(.title2)
                            .fontWeight(.black)
                            .foregroundColor(AppTheme.textPrimary)
                        
                        let total = questionBank.count(for: category)
                        let available = questionBank.availableCount(for: category)
                        
                        HStack(spacing: 16) {
                            statBadge(title: "الأسئلة الكلية", value: "\(total)", color: AppTheme.info)
                            statBadge(title: "الأسئلة المتاحة", value: "\(available)", color: AppTheme.success)
                            statBadge(title: "المستخدمة", value: "\(total - available)", color: AppTheme.error)
                        }
                    }
                    .padding(20)
                    .premiumCard()
                    
                    // تفصيل مستويات الصعوبة والنقاط
                    VStack(alignment: .leading, spacing: 14) {
                        Text("توزيع الأسئلة على النقاط")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.goldPrimary)
                        
                        ForEach(DifficultyLevel.allCases, id: \.self) { diff in
                            let count = questionBank.availableCount(for: category, difficulty: diff)
                            
                            HStack {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(diff.gradient)
                                        .frame(width: 54, height: 36)
                                    Text("\(diff.points)")
                                        .font(.subheadline)
                                        .fontWeight(.black)
                                        .foregroundColor(.white)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(diff.titleArabic)
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundColor(AppTheme.textPrimary)
                                    Text(diff.subtitleArabic)
                                        .font(.caption2)
                                        .foregroundColor(AppTheme.textMuted)
                                }
                                
                                Spacer()
                                
                                Text("\(count) متاح")
                                    .font(.subheadline)
                                    .fontWeight(.heavy)
                                    .foregroundColor(count > 0 ? AppTheme.textPrimary : AppTheme.error)
                            }
                            .padding(12)
                            .background(AppTheme.bgSecondary)
                            .cornerRadius(14)
                        }
                    }
                    .padding(20)
                    .premiumCard()
                }
                .padding(16)
            }
        }
        .navigationTitle(category.titleArabic)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func statBadge(title: String, value: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.title3)
                .fontWeight(.black)
                .foregroundColor(color)
            Text(title)
                .font(.caption2)
                .foregroundColor(AppTheme.textSecondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(AppTheme.bgSecondary)
        .cornerRadius(12)
    }
}
