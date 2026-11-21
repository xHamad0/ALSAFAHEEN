import SwiftUI

/// واجهة أسئلة الإجابة المباشرة (كتابة أو تحقق شفهي جماعي)
public struct DirectAnswerView: View {
    @Binding var inputAnswer: String
    let onSubmitInput: () -> Void
    let onManualVerify: (Bool) -> Void
    
    @State private var isShowingManualDecision: Bool = false
    
    public var body: some View {
        VStack(spacing: 18) {
            // خيار الإدخال النصي
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "pencil.line")
                        .foregroundColor(AppTheme.goldPrimary)
                    
                    TextField("اكتب الإجابة هنا...", text: $inputAnswer)
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)
                        .multilineTextAlignment(.leading)
                        .submitLabel(.done)
                        .onSubmit {
                            if !inputAnswer.trimmingCharacters(in: .whitespaces).isEmpty {
                                onSubmitInput()
                            }
                        }
                    
                    if !inputAnswer.isEmpty {
                        Button(action: { inputAnswer = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(AppTheme.textMuted)
                        }
                    }
                }
                .padding()
                .background(AppTheme.bgSecondary)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppTheme.goldPrimary.opacity(0.3), lineWidth: 1)
                )
                
                Button(action: onSubmitInput) {
                    Text("إرسال الإجابة المكتوبة")
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(AppTheme.goldGradient)
                        .cornerRadius(14)
                }
                .disabled(inputAnswer.trimmingCharacters(in: .whitespaces).isEmpty)
                .opacity(inputAnswer.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1.0)
            }
            
            // فاصل
            HStack {
                Rectangle().fill(Color.white.opacity(0.1)).frame(height: 1)
                Text("أو التحكيم المباشر للجلسات")
                    .font(.caption2)
                    .foregroundColor(AppTheme.textMuted)
                Rectangle().fill(Color.white.opacity(0.1)).frame(height: 1)
            }
            .padding(.vertical, 4)
            
            // أزرار التحكيم المباشر (للإجابة الشفهية بين الفرق)
            HStack(spacing: 14) {
                Button(action: { onManualVerify(true) }) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("إجابة صحيحة")
                            .fontWeight(.bold)
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(AppTheme.success)
                    .cornerRadius(14)
                }
                
                Button(action: { onManualVerify(false) }) {
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                        Text("إجابة خاطئة")
                            .fontWeight(.bold)
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(AppTheme.error)
                    .cornerRadius(14)
                }
            }
        }
    }
}
