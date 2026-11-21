import SwiftUI

/// شريط وسائل المساعدة الأربع للفريق صاحب الدور
public struct LifelinesBarView: View {
    let team: Team
    let canUse: (LifelineType) -> Bool
    let onUse: (LifelineType) -> Void
    
    private let lifelines = LifelineType.allCases
    
    public var body: some View {
        HStack(spacing: 10) {
            ForEach(lifelines) { item in
                let count = team.lifelinesRemaining[item.rawValue] ?? 0
                let isUsable = count > 0 && canUse(item)
                
                Button(action: {
                    if isUsable {
                        onUse(item)
                    }
                }) {
                    VStack(spacing: 4) {
                        ZStack(alignment: .topTrailing) {
                            Circle()
                                .fill(isUsable ? AppTheme.bgCardElevated : AppTheme.bgSecondary.opacity(0.5))
                                .frame(width: 46, height: 46)
                                .overlay(
                                    Circle()
                                        .stroke(isUsable ? AppTheme.goldPrimary.opacity(0.6) : Color.white.opacity(0.08), lineWidth: 1.2)
                                )
                            
                            Image(systemName: item.iconName)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(isUsable ? AppTheme.goldPrimary : AppTheme.textMuted)
                                .frame(width: 46, height: 46)
                            
                            // عدد مرات الاستخدام المتبقية
                            Text("\(count)")
                                .font(.system(size: 10, weight: .black))
                                .foregroundColor(.black)
                                .frame(width: 16, height: 16)
                                .background(isUsable ? AppTheme.goldPrimary : Color.gray)
                                .clipShape(Circle())
                                .offset(x: 3, y: -3)
                        }
                        
                        Text(item.titleArabic)
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(isUsable ? AppTheme.textPrimary : AppTheme.textMuted)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                }
                .disabled(!isUsable)
                .opacity(count > 0 ? 1.0 : 0.4)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(AppTheme.bgCard.opacity(0.9))
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }
}
