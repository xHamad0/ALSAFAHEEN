import SwiftUI

/// كرت السؤال النشط بدون خيارات (نمط تحداني / سين جيم: عرض السؤال ثم كشف الإجابة والتحكيم)
public struct QuestionCardView: View {
    let question: Question
    let difficulty: DifficultyLevel
    let isDoublePoints: Bool
    let eliminatedOptions: [String]
    let selectedOptionIndex: Int?
    @Binding var answerInput: String
    let onSelectOption: (Int) -> Void
    let onSubmitDirectOrBlank: () -> Void
    let onManualVerify: (Bool) -> Void
    
    @State private var isAnswerRevealedLocally: Bool = false
    
    public var body: some View {
        VStack(spacing: 12) {
            // شريط المعلومات العلوي (التصنيف + مضاعفة النقاط + قيمة السؤال)
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: question.category.iconName)
                        .foregroundColor(question.category.themeColor)
                    Text(question.category.titleArabic)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.textPrimary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(question.category.themeColor.opacity(0.18))
                .cornerRadius(12)
                
                Spacer()
                
                if isDoublePoints {
                    HStack(spacing: 4) {
                        Image(systemName: "multiply.circle.fill")
                        Text("2X نقاط مضاعفة")
                    }
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(hex: "#EC4899"))
                    .cornerRadius(10)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: difficulty.iconName)
                        .font(.caption2)
                    Text("\(difficulty.points) نقطة")
                        .font(.caption)
                        .fontWeight(.heavy)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(difficulty.gradient)
                .cornerRadius(12)
            }
            
            // محتوى السؤال بدون خيارات
            VStack(spacing: 14) {
                // في حال سؤال الأعلام نعرض العلم
                if question.category == .flags, let code = question.flagCountryCode, !code.isEmpty {
                    Text(flagEmoji(from: code))
                        .font(.system(size: 56))
                }
                
                // في حال سؤال الحروف نعرض الحرف المطلوب
                if question.category == .letters, let letter = question.letter {
                    Text("حرف «\(letter)»")
                        .font(.subheadline)
                        .fontWeight(.black)
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 4)
                        .background(Color(hex: "#8B5CF6"))
                        .clipShape(Capsule())
                }
                
                // نص السؤال
                Text(question.text)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 10)
                    .lineSpacing(5)
                
                if !isAnswerRevealedLocally {
                    // زر كشف الإجابة
                    Button(action: {
                        withAnimation(.spring(response: 0.3)) {
                            isAnswerRevealedLocally = true
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "eye.fill")
                            Text("كشف الإجابة")
                                .fontWeight(.black)
                        }
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: 260)
                        .frame(height: 46)
                        .background(AppTheme.goldGradient)
                        .clipShape(Capsule())
                        .shadow(color: AppTheme.goldPrimary.opacity(0.35), radius: 6, x: 0, y: 3)
                    }
                } else {
                    // عرض الإجابة الصحيحة + أزرار التحكيم (صح / خطأ)
                    VStack(spacing: 10) {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(AppTheme.success)
                            Text("الإجابة: \(question.answer)")
                                .font(.headline)
                                .fontWeight(.black)
                                .foregroundColor(AppTheme.goldPrimary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(AppTheme.bgSecondary)
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(AppTheme.goldPrimary.opacity(0.4), lineWidth: 1)
                        )
                        
                        HStack(spacing: 12) {
                            Button(action: { onManualVerify(true) }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("إجابة صحيحة (+\(isDoublePoints ? difficulty.points * 2 : difficulty.points))")
                                        .fontWeight(.bold)
                                }
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(AppTheme.success)
                                .cornerRadius(12)
                            }
                            
                            Button(action: { onManualVerify(false) }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "xmark.circle.fill")
                                    Text("إجابة خاطئة")
                                        .fontWeight(.bold)
                                }
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(AppTheme.error)
                                .cornerRadius(12)
                            }
                        }
                    }
                }
            }
            .padding(16)
            .premiumCard()
        }
        .onChange(of: question.id) { _ in
            isAnswerRevealedLocally = false
        }
    }
    
    private func flagEmoji(from countryCode: String) -> String {
        let base: UInt32 = 127397
        var s = ""
        for v in countryCode.uppercased().unicodeScalars {
            if let scalar = UnicodeScalar(base + v.value) {
                s.unicodeScalars.append(scalar)
            }
        }
        return s.isEmpty ? "🏳️" : s
    }
}
