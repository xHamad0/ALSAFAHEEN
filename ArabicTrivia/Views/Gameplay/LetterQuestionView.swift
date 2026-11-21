import SwiftUI

/// واجهة مخصصة لعرض أسئلة فئة «الحروف» وفق الشروط الصارمة
public struct LetterQuestionView: View {
    let letter: String
    let questionText: String
    @Binding var answerInput: String
    let onSubmit: () -> Void
    
    public var body: some View {
        VStack(spacing: 20) {
            // كرت الحرف العربي البارز جداً
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#D946EF"), Color(hex: "#8B5CF6")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .shadow(color: Color(hex: "#D946EF").opacity(0.5), radius: 15, x: 0, y: 8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(AppTheme.goldPrimary.opacity(0.8), lineWidth: 2)
                    )
                
                VStack(spacing: 0) {
                    Text("حرف")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(letter)
                        .font(.system(size: 64, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                }
            }
            .padding(.top, 10)
            
            // تنبيه الحرف
            HStack(spacing: 6) {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(AppTheme.goldPrimary)
                Text("يجب أن تبدأ الإجابة بحرف «\(letter)»")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.goldPrimary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(AppTheme.goldPrimary.opacity(0.12))
            .cornerRadius(20)
            
            // نص السؤال العادي
            Text(questionText)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(AppTheme.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 10)
                .lineSpacing(6)
            
            // حقل إدخال الإجابة
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "character.cursor.ibeam")
                        .foregroundColor(AppTheme.textMuted)
                    
                    TextField("اكتب إجابتك هنا تبدأ بحرف \(letter)...", text: $answerInput)
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)
                        .multilineTextAlignment(.leading)
                        .submitLabel(.done)
                        .onSubmit {
                            if !answerInput.trimmingCharacters(in: .whitespaces).isEmpty {
                                onSubmit()
                            }
                        }
                    
                    if !answerInput.isEmpty {
                        Button(action: { answerInput = "" }) {
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
                
                Button(action: onSubmit) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("تأكيد الإجابة")
                            .fontWeight(.bold)
                    }
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(AppTheme.goldGradient)
                    .cornerRadius(16)
                    .shadow(color: AppTheme.goldPrimary.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .disabled(answerInput.trimmingCharacters(in: .whitespaces).isEmpty)
                .opacity(answerInput.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1.0)
            }
            .padding(.top, 8)
        }
        .padding(20)
        .premiumCard()
    }
}
