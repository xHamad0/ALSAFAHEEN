import SwiftUI

/// شاشة تفاصيل التصنيف مع إمكانية سحب وتصدير الأسئلة مقسمة في فئاتها (Requirement 1)
public struct CategoryDetailView: View {
    let category: QuestionCategory
    let questionBank = QuestionBankService.shared
    
    @State private var showShareSheet: Bool = false
    @State private var shareItems: [Any] = []
    @State private var showCopiedAlert: Bool = false
    @State private var copiedMessage: String = ""
    @State private var isShowingQuestionsList: Bool = true
    
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
                    
                    // قسم سحب وتصدير الأسئلة مقسمة (Requirement 1)
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "square.and.arrow.up.fill")
                                .foregroundColor(AppTheme.goldPrimary)
                            Text("سحب ومشاركة أسئلة هذا التصنيف:")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(AppTheme.goldPrimary)
                        }
                        
                        HStack(spacing: 10) {
                            // زر سحب ومشاركة JSON
                            Button(action: {
                                let jsonStr = questionBank.exportCategoryJSON(category: category)
                                shareItems = [jsonStr]
                                showShareSheet = true
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "doc.text.fill")
                                    Text("سحب ملف JSON")
                                }
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(AppTheme.goldGradient)
                                .cornerRadius(12)
                            }
                            
                            // زر نسخ النص المنسق
                            Button(action: {
                                let text = questionBank.exportCategoryFormattedText(category: category)
                                UIPasteboard.general.string = text
                                copiedMessage = "تم نسخ أسئلة «\(category.titleArabic)» إلى الحافظة بنجاح!"
                                showCopiedAlert = true
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "doc.on.doc.fill")
                                    Text("نسخ الأسئلة نصياً")
                                }
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(AppTheme.textPrimary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(AppTheme.bgSecondary)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                            }
                        }
                    }
                    .padding(16)
                    .premiumCard()
                    
                    // تفصيل مستويات الصعوبة والنقاط
                    VStack(alignment: .leading, spacing: 14) {
                        Text("توزيع الأسئلة على النقاط")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.goldPrimary)
                        
                        ForEach(DifficultyLevel.allCases, id: \.self) { diff in
                            let count = questionBank.availableCount(for: category, difficulty: diff)
                            let totalInDiff = (questionBank.questionsByCategory[category] ?? []).filter { $0.difficulty == diff }.count
                            
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
                                
                                Text("\(count) متاح من \(totalInDiff)")
                                    .font(.caption)
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
                    
                    // استعراض الأسئلة مقسمة داخل الشاشة
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("قائمة الأسئلة المفصلة للتصنيف")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(AppTheme.textPrimary)
                            Spacer()
                            Button(isShowingQuestionsList ? "إخفاء" : "عرض") {
                                withAnimation { isShowingQuestionsList.toggle() }
                            }
                            .font(.caption)
                            .foregroundColor(AppTheme.goldPrimary)
                        }
                        
                        if isShowingQuestionsList {
                            let catQuestions = questionBank.questionsByCategory[category] ?? []
                            ForEach(Array(catQuestions.enumerated()), id: \.element.id) { index, q in
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text("\(index + 1). \(q.text)")
                                            .font(.subheadline)
                                            .fontWeight(.bold)
                                            .foregroundColor(AppTheme.textPrimary)
                                        Spacer()
                                        Text("\(q.difficulty.points) ن")
                                            .font(.caption2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(q.difficulty.primaryColor)
                                            .cornerRadius(6)
                                    }
                                    
                                    if let opts = q.options, !opts.isEmpty {
                                        Text("الخيارات: " + opts.joined(separator: " • "))
                                            .font(.caption2)
                                            .foregroundColor(AppTheme.textSecondary)
                                    }
                                    
                                    HStack(spacing: 4) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.caption2)
                                            .foregroundColor(AppTheme.success)
                                        Text("الإجابة: \(q.answer)")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundColor(AppTheme.success)
                                    }
                                }
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(AppTheme.bgSecondary)
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding(16)
                    .premiumCard()
                }
                .padding(16)
            }
        }
        .navigationTitle(category.titleArabic)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: shareItems)
        }
        .alert("تم النسخ", isPresented: $showCopiedAlert) {
            Button("حسناً", role: .cancel) {}
        } message: {
            Text(copiedMessage)
        }
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
