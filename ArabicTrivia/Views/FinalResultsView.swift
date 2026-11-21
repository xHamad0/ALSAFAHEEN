import SwiftUI

/// شاشة النتائج النهائية وتتويج الفائز
public struct FinalResultsView: View {
    let session: GameSession
    let onDismiss: () -> Void
    
    @State private var animateTrophy: Bool = false
    
    public var body: some View {
        VStack(spacing: 24) {
            let isTie = session.team1.score == session.team2.score
            let winner = session.team1.score > session.team2.score ? session.team1 : session.team2
            
            // أيقونة التتويج
            ZStack {
                Circle()
                    .fill(AppTheme.goldPrimary.opacity(0.15))
                    .frame(width: 130, height: 130)
                    .scaleEffect(animateTrophy ? 1.08 : 0.95)
                    .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: animateTrophy)
                
                Image(systemName: isTie ? "equal.circle.fill" : "trophy.fill")
                    .font(.system(size: 74))
                    .foregroundStyle(AppTheme.goldGradient)
                    .shadow(color: AppTheme.goldGlow.opacity(0.6), radius: 15, x: 0, y: 5)
            }
            .padding(.top, 10)
            
            // اسم الفائز أو إعلان التعادل
            VStack(spacing: 6) {
                if isTie {
                    Text("تعادل ملحمي!")
                        .font(.largeTitle)
                        .fontWeight(.black)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text("قدم كلا الفريقين أداءً رائعاً ومتكافئاً")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary)
                } else {
                    Text("مبروك الفوز!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.goldPrimary)
                    
                    Text(winner.name)
                        .font(.system(size: 36, weight: .black))
                        .foregroundColor(Color(hex: winner.colorHex))
                        .shadow(color: Color(hex: winner.colorHex).opacity(0.4), radius: 8, x: 0, y: 3)
                }
            }
            
            // بطاقة مقارنة نتائج الفريقين
            HStack(spacing: 16) {
                teamFinalCard(team: session.team1, isWinner: session.team1.score > session.team2.score)
                teamFinalCard(team: session.team2, isWinner: session.team2.score > session.team1.score)
            }
            .padding(.horizontal, 4)
            
            // أزرار العمليات
            VStack(spacing: 12) {
                Button(action: onDismiss) {
                    HStack(spacing: 8) {
                        Image(systemName: "house.fill")
                        Text("العودة إلى الشاشة الرئيسية")
                            .fontWeight(.bold)
                    }
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(AppTheme.goldGradient)
                    .cornerRadius(16)
                    .shadow(color: AppTheme.goldPrimary.opacity(0.3), radius: 8, x: 0, y: 4)
                }
            }
            .padding(.top, 10)
        }
        .padding(24)
        .premiumCard()
        .onAppear {
            animateTrophy = true
        }
    }
    
    private func teamFinalCard(team: Team, isWinner: Bool) -> some View {
        VStack(spacing: 12) {
            Circle()
                .fill(Color(hex: team.colorHex))
                .frame(width: 24, height: 24)
            
            Text(team.name)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(AppTheme.textPrimary)
                .lineLimit(1)
            
            Text("\(team.score)")
                .font(.system(size: 36, weight: .black))
                .foregroundColor(AppTheme.goldPrimary)
            
            Text("نقطة")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(AppTheme.textMuted)
            
            Divider().background(Color.white.opacity(0.1))
            
            VStack(spacing: 6) {
                HStack {
                    Text("الصحيحة:")
                        .font(.caption2)
                        .foregroundColor(AppTheme.textSecondary)
                    Spacer()
                    Text("\(team.correctAnswersCount)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.success)
                }
                
                HStack {
                    Text("الخاطئة:")
                        .font(.caption2)
                        .foregroundColor(AppTheme.textSecondary)
                    Spacer()
                    Text("\(team.wrongAnswersCount)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.error)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(AppTheme.bgSecondary)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(isWinner ? AppTheme.goldPrimary : Color.white.opacity(0.08), lineWidth: isWinner ? 2 : 1)
        )
    }
}
