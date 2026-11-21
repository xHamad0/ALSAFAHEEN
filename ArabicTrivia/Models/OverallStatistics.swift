import Foundation

/// الإحصائيات الشاملة لجميع المباريات
public struct OverallStatistics: Codable {
    public var totalMatchesPlayed: Int
    public var teamWins: [String: Int]
    public var totalPointsScored: Int
    public var totalCorrectAnswers: Int
    public var totalWrongAnswers: Int
    public var mostPlayedCategories: [String: Int] // category id -> count
    public var longestStreakRecord: Int
    public var highestScoreRecord: Int
    public var headToHeadRecords: [String: [String: Int]] // "الفريق أ vs الفريق ب" -> ["الفريق أ": 3, "الفريق ب": 2, "تعادل": 1]
    
    public init(
        totalMatchesPlayed: Int = 0,
        teamWins: [String: Int] = [:],
        totalPointsScored: Int = 0,
        totalCorrectAnswers: Int = 0,
        totalWrongAnswers: Int = 0,
        mostPlayedCategories: [String: Int] = [:],
        longestStreakRecord: Int = 0,
        highestScoreRecord: Int = 0,
        headToHeadRecords: [String: [String: Int]] = [:]
    ) {
        self.totalMatchesPlayed = totalMatchesPlayed
        self.teamWins = teamWins
        self.totalPointsScored = totalPointsScored
        self.totalCorrectAnswers = totalCorrectAnswers
        self.totalWrongAnswers = totalWrongAnswers
        self.mostPlayedCategories = mostPlayedCategories
        self.longestStreakRecord = longestStreakRecord
        self.highestScoreRecord = highestScoreRecord
        self.headToHeadRecords = headToHeadRecords
    }
    
    public var accuracyPercentage: Double {
        let total = totalCorrectAnswers + totalWrongAnswers
        guard total > 0 else { return 0.0 }
        return (Double(totalCorrectAnswers) / Double(total)) * 100.0
    }
}
