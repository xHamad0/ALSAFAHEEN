import SwiftUI

/// كرت السؤال النشط بدون خيارات: يعرض السؤال وزر "إظهار الإجابة" الذي يوقف الوقت وينتقل لتحديد الفائز
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
    var onRevealAnswer: (() -> Void)? = nil
    
    public var body: some View {
        VStack(spacing: 14) {
            // شريط المعلومات العلوي (التصنيف + مضاعفة النقاط + قيمة السؤال)
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: question.category.iconName)
                        .foregroundColor(question.category.themeColor)
                    Text(question.category.titleArabic)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "#1F2937"))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(question.category.themeColor.opacity(0.14))
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
                .background(
                    LinearGradient(
                        colors: [Color(hex: "#DC2626"), Color(hex: "#F97316")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
            
            // في حال سؤال الأعلام نعرض العلم
            if question.category == .flags, let code = question.flagCountryCode, !code.isEmpty {
                Text(flagEmoji(from: code))
                    .font(.system(size: 54))
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
                .foregroundColor(Color(hex: "#111827"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 12)
                .lineSpacing(5)
            
            // زر إظهار الإجابة (يوقف المؤقت وينتقل لصفحة الإجابة وتحديد من جاوب)
            Button(action: {
                onRevealAnswer?()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "eye.fill")
                    Text("إظهار الإجابة")
                        .fontWeight(.black)
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: 260)
                .frame(height: 46)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "#C8232C"), Color(hex: "#F97316")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(Capsule())
                .shadow(color: Color(hex: "#F97316").opacity(0.35), radius: 6, x: 0, y: 3)
            }
        }
        .padding(18)
        .background(Color.white)
        .cornerRadius(22)
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color(hex: "#F97316"), lineWidth: 2.2)
        )
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
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
