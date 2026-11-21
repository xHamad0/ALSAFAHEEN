import SwiftUI

/// شاشة الإحصائيات الشاملة للمباريات والمواجهات
public struct StatisticsView: View {
    @ObservedObject var dataManager = DataManager.shared
    
    public var body: some View {
        ZStack {
            AppTheme.bgGradient
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    let stats = dataManager.statistics
                    
                    // ملخص الأرقام العامة
                    generalStatsOverview(stats: stats)
                    
                    // بطاقات الأداء والنسب
                    performanceCards(stats: stats)
                    
                    // سجل انتصارات الفرق
                    teamsLeaderboard(teamWins: stats.teamWins)
                    
                    // سجل المواجهات المباشرة (Head to Head)
                    headToHeadSection(records: stats.headToHeadRecords)
                }
                .padding(16)
            }
        }
        .navigationTitle("الإحصائيات العامة")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func generalStatsOverview(stats: OverallStatistics) -> some View {
        VStack(spacing: 16) {
            Text("نظرة عامة على المباريات")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(AppTheme.goldPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                statTile(title: "المباريات المكتملة", value: "\(stats.totalMatchesPlayed)", icon: "gamecontroller.fill", color: AppTheme.info)
                statTile(title: "مجموع النقاط", value: "\(stats.totalPointsScored)", icon: "star.fill", color: AppTheme.goldPrimary)
                statTile(title: "أعلى نتيجة مسجلة", value: "\(stats.highestScoreRecord)", icon: "trophy.fill", color: Color(hex: "#EC4899"))
                statTile(title: "أطول سلسلة صحيحة", value: "\(stats.longestStreakRecord)", icon: "flame.fill", color: AppTheme.warning)
            }
        }
        .padding(16)
        .premiumCard()
    }
    
    private func performanceCards(stats: OverallStatistics) -> some View {
        VStack(spacing: 14) {
            Text("دقة الإجابات")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(AppTheme.goldPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 14) {
                VStack(spacing: 4) {
                    Text("\(stats.totalCorrectAnswers)")
                        .font(.title2)
                        .fontWeight(.black)
                        .foregroundColor(AppTheme.success)
                    Text("إجابة صحيحة")
                        .font(.caption2)
                        .foregroundColor(AppTheme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                
                VStack(spacing: 4) {
                    Text("\(String(format: "%.1f", stats.accuracyPercentage))%")
                        .font(.title2)
                        .fontWeight(.black)
                        .foregroundColor(AppTheme.goldPrimary)
                    Text("نسبة الدقة")
                        .font(.caption2)
                        .foregroundColor(AppTheme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                
                VStack(spacing: 4) {
                    Text("\(stats.totalWrongAnswers)")
                        .font(.title2)
                        .fontWeight(.black)
                        .foregroundColor(AppTheme.error)
                    Text("إجابة خاطئة")
                        .font(.caption2)
                        .foregroundColor(AppTheme.textSecondary)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(14)
            .background(AppTheme.bgSecondary)
            .cornerRadius(14)
        }
        .padding(16)
        .premiumCard()
    }
    
    private func teamsLeaderboard(teamWins: [String: Int]) -> some View {
        VStack(spacing: 12) {
            Text("سجل انتصارات الفرق")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(AppTheme.goldPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if teamWins.isEmpty {
                Text("لا توجد انتصارات مسجلة حتى الآن.")
                    .font(.caption)
                    .foregroundColor(AppTheme.textMuted)
            } else {
                let sorted = teamWins.sorted { $0.value > $1.value }
                ForEach(sorted, id: \.key) { team, wins in
                    HStack {
                        Image(systemName: "crown.fill")
                            .foregroundColor(AppTheme.goldPrimary)
                        Text(team)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.textPrimary)
                        Spacer()
                        Text("\(wins) فوز")
                            .font(.subheadline)
                            .fontWeight(.heavy)
                            .foregroundColor(AppTheme.goldPrimary)
                    }
                    .padding(12)
                    .background(AppTheme.bgSecondary)
                    .cornerRadius(12)
                }
            }
        }
        .padding(16)
        .premiumCard()
    }
    
    private func headToHeadSection(records: [String: [String: Int]]) -> some View {
        VStack(spacing: 12) {
            Text("سجل المواجهات المباشرة")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(AppTheme.goldPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if records.isEmpty {
                Text("ستظهر هنا نتائج المواجهات بين الفرق عند تكرار التنافس بينهما.")
                    .font(.caption)
                    .foregroundColor(AppTheme.textMuted)
            } else {
                ForEach(Array(records.keys), id: \.self) { matchup in
                    if let dict = records[matchup] {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(matchup)
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(AppTheme.textPrimary)
                            
                            HStack(spacing: 12) {
                                ForEach(Array(dict.keys), id: \.self) { key in
                                    Text("\(key): \(dict[key] ?? 0)")
                                        .font(.caption2)
                                        .foregroundColor(AppTheme.textSecondary)
                                }
                            }
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppTheme.bgSecondary)
                        .cornerRadius(12)
                    }
                }
            }
        }
        .padding(16)
        .premiumCard()
    }
    
    private func statTile(title: String, value: String, icon: String, color: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.black)
                    .foregroundColor(AppTheme.textPrimary)
                Text(title)
                    .font(.system(size: 10))
                    .foregroundColor(AppTheme.textMuted)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.bgSecondary)
        .cornerRadius(12)
    }
}
