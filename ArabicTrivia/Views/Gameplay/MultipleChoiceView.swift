import SwiftUI

/// واجهة أسئلة الاختيار من متعدد
public struct MultipleChoiceView: View {
    let options: [String]
    let eliminatedOptions: [String]
    let selectedIndex: Int?
    let onSelect: (Int) -> Void
    
    public var body: some View {
        VStack(spacing: 12) {
            ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                let isEliminated = eliminatedOptions.contains(option)
                let isSelected = selectedIndex == index
                
                Button(action: {
                    if !isEliminated {
                        onSelect(index)
                    }
                }) {
                    HStack(spacing: 14) {
                        // رقم الخيار
                        ZStack {
                            Circle()
                                .fill(isSelected ? AppTheme.goldPrimary : AppTheme.bgSecondary)
                                .frame(width: 32, height: 32)
                            
                            Text(letterForIndex(index))
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(isSelected ? .black : AppTheme.textSecondary)
                        }
                        
                        Text(option)
                            .font(.headline)
                            .foregroundColor(isEliminated ? AppTheme.textMuted : AppTheme.textPrimary)
                            .strikethrough(isEliminated)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(AppTheme.goldPrimary)
                                .font(.title3)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(isSelected ? AppTheme.goldPrimary.opacity(0.18) : AppTheme.bgCardElevated)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(isSelected ? AppTheme.goldPrimary : Color.white.opacity(0.08), lineWidth: 1.2)
                            )
                    )
                }
                .buttonStyle(ScaleButtonStyle())
                .disabled(isEliminated)
                .opacity(isEliminated ? 0.35 : 1.0)
            }
        }
    }
    
    private func letterForIndex(_ index: Int) -> String {
        let arabicLetters = ["أ", "ب", "ج", "د", "هـ", "و"]
        if index < arabicLetters.count {
            return arabicLetters[index]
        }
        return "\(index + 1)"
    }
}
