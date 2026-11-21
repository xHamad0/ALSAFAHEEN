import SwiftUI

/// كرت السؤال النشط بكافة تفاصيله وأنماطه المتخصصة
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
    
    public var body: some View {
        VStack(spacing: 16) {
            // شريط المعلومات العلوي (التصنيف + الصعوبة والنقاط)
            HStack {
                // شارة التصنيف
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
                .background(question.category.themeColor.opacity(0.15))
                .cornerRadius(12)
                
                Spacer()
                
                // مؤشر مضاعفة النقاط إذا كان مفعلاً
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
                
                // شارة قيمة السؤال
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
                .shadow(color: difficulty.primaryColor.opacity(0.4), radius: 4, x: 0, y: 2)
            }
            
            // تحديد الواجهة المناسبة حسب نوع وتصنيف السؤال
            if question.category == .letters, let letter = question.letter {
                // نمط الحروف الخاص
                LetterQuestionView(
                    letter: letter,
                    questionText: question.text,
                    answerInput: $answerInput,
                    onSubmit: onSubmitDirectOrBlank
                )
            } else if question.category == .flags {
                // نمط الأعلام
                FlagQuestionView(
                    question: question,
                    eliminatedOptions: eliminatedOptions,
                    selectedIndex: selectedOptionIndex,
                    onSelectOption: onSelectOption
                )
            } else {
                // الأنماط القياسية
                VStack(spacing: 18) {
                    // نص السؤال
                    Text(question.text)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.textPrimary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                        .lineSpacing(6)
                    
                    switch question.type {
                    case .multipleChoice:
                        if let options = question.options {
                            MultipleChoiceView(
                                options: options,
                                eliminatedOptions: eliminatedOptions,
                                selectedIndex: selectedOptionIndex,
                                onSelect: onSelectOption
                            )
                        }
                    case .directAnswer:
                        DirectAnswerView(
                            inputAnswer: $answerInput,
                            onSubmitInput: onSubmitDirectOrBlank,
                            onManualVerify: onManualVerify
                        )
                    case .fillInBlank:
                        FillInBlankView(
                            inputAnswer: $answerInput,
                            onSubmit: onSubmitDirectOrBlank
                        )
                    }
                }
                .padding(20)
                .premiumCard()
            }
        }
    }
}
