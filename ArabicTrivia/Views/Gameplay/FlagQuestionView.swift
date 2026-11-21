import SwiftUI

/// واجهة فئة أعلام الدول التفاعلية
public struct FlagQuestionView: View {
    let question: Question
    let eliminatedOptions: [String]
    let selectedIndex: Int?
    let onSelectOption: (Int) -> Void
    
    public var body: some View {
        VStack(spacing: 20) {
            // عرض العلم (إذا توفر كود الدولة أو إيموجي أو صورة)
            if let code = question.flagCountryCode, !code.isEmpty {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(AppTheme.bgSecondary)
                        .frame(width: 180, height: 120)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(AppTheme.goldPrimary.opacity(0.4), lineWidth: 1.5)
                        )
                        .shadow(color: Color.black.opacity(0.4), radius: 10, x: 0, y: 5)
                    
                    Text(flagEmoji(from: code))
                        .font(.system(size: 80))
                }
                .padding(.top, 6)
            }
            
            // نص السؤال
            Text(question.text)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(AppTheme.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 10)
                .lineSpacing(6)
            
            // الخيارات الأربعة
            if let options = question.options {
                VStack(spacing: 12) {
                    ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                        let isEliminated = eliminatedOptions.contains(option)
                        let isSelected = selectedIndex == index
                        
                        Button(action: {
                            if !isEliminated {
                                onSelectOption(index)
                            }
                        }) {
                            HStack(spacing: 14) {
                                ZStack {
                                    Circle()
                                        .fill(isSelected ? AppTheme.goldPrimary : AppTheme.bgSecondary)
                                        .frame(width: 32, height: 32)
                                    
                                    Text("\(index + 1)")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundColor(isSelected ? .black : AppTheme.textSecondary)
                                }
                                
                                Text(option)
                                    .font(.headline)
                                    .foregroundColor(isEliminated ? AppTheme.textMuted : AppTheme.textPrimary)
                                    .strikethrough(isEliminated)
                                
                                Spacer()
                                
                                if isSelected {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(AppTheme.goldPrimary)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(isSelected ? AppTheme.goldPrimary.opacity(0.15) : AppTheme.bgCardElevated)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(isSelected ? AppTheme.goldPrimary : Color.white.opacity(0.08), lineWidth: 1.2)
                                    )
                            )
                        }
                        .disabled(isEliminated)
                        .opacity(isEliminated ? 0.35 : 1.0)
                    }
                }
            }
        }
        .padding(20)
        .premiumCard()
    }
    
    /// تحويل كود الدولة المكون من حرفين (ISO 3166-1 alpha-2) إلى رمز علم الدولة Emoji
    private func flagEmoji(from countryCode: String) -> String {
        let base: UInt32 = 127397
        var s = ""
        for v in countryCode.uppercased().unicodeScalars {
            s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
        }
        return s
    }
}
