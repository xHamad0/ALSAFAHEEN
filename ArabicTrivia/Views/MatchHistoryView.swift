import SwiftUI

/// شاشة سجل المباريات السابقة
public struct MatchHistoryView: View {
    @ObservedObject var dataManager = DataManager.shared
    
    public var body: some View {
        ZStack {
            AppTheme.bgGradient
                .ignoresSafeArea()
            
            if dataManager.matchesHistory.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 60))
                        .foregroundColor(AppTheme.textMuted)
                    
                    Text("لا توجد مباريات مسجلة بعد")
                        .font(.headline)
                        .foregroundColor(AppTheme.textSecondary)
                    
                    Text("ابدأ مباراة جديدة بين فريقين لتسجيل النتائج والإحصائيات في السجل.")
                        .font(.caption)
                        .foregroundColor(AppTheme.textMuted)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 14) {
                        ForEach(dataManager.matchesHistory) { match in
                            matchCard(match: match)
                        }
                    }
                    .padding(16)
                }
            }
        }
        .navigationTitle("سجل المباريات")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func matchCard(match: MatchRecord) -> some View {
        VStack(spacing: 12) {
            // تاريخ المباراة وعدد الجولات
            HStack {
                Text(formatDate(match.date))
                    .font(.caption2)
                    .foregroundColor(AppTheme.textMuted)
                
                Spacer()
                
                Text("\(match.roundsCount) جولات")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.goldPrimary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(AppTheme.goldPrimary.opacity(0.12))
                    .cornerRadius(8)
            }
            
            // مقارنة نتائج الفريقين
            HStack(spacing: 16) {
                // الفريق الأول
                VStack(spacing: 4) {
                    HStack(spacing: 6) {
                        Circle().fill(Color(hex: match.team1ColorHex)).frame(width: 10, height: 10)
                        Text(match.team1Name)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.textPrimary)
                            .lineLimit(1)
                    }
                    Text("\(match.team1Score)")
                        .font(.title2)
                        .fontWeight(.black)
                        .foregroundColor(match.team1Score >= match.team2Score ? AppTheme.goldPrimary : AppTheme.textSecondary)
                    Text("صحيحة: \(match.team1Correct) | خاطئة: \(match.team1Wrong)")
                        .font(.system(size: 9))
                        .foregroundColor(AppTheme.textMuted)
                }
                .frame(maxWidth: .infinity)
                
                Text("VS")
                    .font(.caption)
                    .fontWeight(.black)
                    .foregroundColor(AppTheme.textMuted)
                
                // الفريق الثاني
                VStack(spacing: 4) {
                    HStack(spacing: 6) {
                        Circle().fill(Color(hex: match.team2ColorHex)).frame(width: 10, height: 10)
                        Text(match.team2Name)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.textPrimary)
                            .lineLimit(1)
                    }
                    Text("\(match.team2Score)")
                        .font(.title2)
                        .fontWeight(.black)
                        .foregroundColor(match.team2Score >= match.team1Score ? AppTheme.goldPrimary : AppTheme.textSecondary)
                    Text("صحيحة: \(match.team2Correct) | خاطئة: \(match.team2Wrong)")
                        .font(.system(size: 9))
                        .foregroundColor(AppTheme.textMuted)
                }
                .frame(maxWidth: .infinity)
            }
            
            Divider().background(Color.white.opacity(0.08))
            
            // الفائز
            HStack {
                Image(systemName: "crown.fill")
                    .font(.caption)
                    .foregroundColor(AppTheme.goldPrimary)
                
                if let winner = match.winnerName {
                    Text("الفائز: \(winner)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.goldPrimary)
                } else {
                    Text("النتيجة: تعادل")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                Spacer()
            }
        }
        .padding(14)
        .premiumCard()
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ar_SA")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
