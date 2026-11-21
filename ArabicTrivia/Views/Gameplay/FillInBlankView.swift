import SwiftUI

/// واجهة أسئلة «أكمل العبارة / الفراغ»
public struct FillInBlankView: View {
    @Binding var inputAnswer: String
    let onSubmit: () -> Void
    
    public var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 6) {
                Image(systemName: "character.cursor.ibeam")
                    .foregroundColor(AppTheme.goldPrimary)
                Text("املأ الفراغ بالكلمة أو العبارة الناقصة")
                    .font(.footnote)
                    .foregroundColor(AppTheme.goldPrimary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(AppTheme.goldPrimary.opacity(0.12))
            .cornerRadius(12)
            
            HStack {
                TextField("اكتب الكلمة الناقصة...", text: $inputAnswer)
                    .font(.headline)
                    .foregroundColor(AppTheme.textPrimary)
                    .multilineTextAlignment(.leading)
                    .submitLabel(.done)
                    .onSubmit {
                        if !inputAnswer.trimmingCharacters(in: .whitespaces).isEmpty {
                            onSubmit()
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
            
            Button(action: onSubmit) {
                Text("تأكيد الكلمة الناقصة")
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
    }
}
