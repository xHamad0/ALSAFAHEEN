import Foundation

/// سجل مباراة مكتملة
public struct MatchRecord: Identifiable, Codable {
    public let id: String
    public let date: Date
    public let team1Name: String
    public let team1ColorHex: String
    public let team1Score: Int
    public let team1Correct: Int
    public let team1Wrong: Int
    
    public let team2Name: String
    public let team2ColorHex: String
    public let team2Score: Int
    public let team2Correct: Int
    public let team2Wrong: Int
    
    public let winnerName: String? // nil if tie
    public let roundsCount: Int
    public let categoriesPlayedCount: Int
    
    public init(
        id: String = UUID().uuidString,
        date: Date = Date(),
        team1Name: String,
        team1ColorHex: String,
        team1Score: Int,
        team1Correct: Int,
        team1Wrong: Int,
        team2Name: String,
        team2ColorHex: String,
        team2Score: Int,
        team2Correct: Int,
        team2Wrong: Int,
        winnerName: String?,
        roundsCount: Int,
        categoriesPlayedCount: Int
    ) {
        self.id = id
        self.date = date
        self.team1Name = team1Name
        self.team1ColorHex = team1ColorHex
        self.team1Score = team1Score
        self.team1Correct = team1Correct
        self.team1Wrong = team1Wrong
        self.team2Name = team2Name
        self.team2ColorHex = team2ColorHex
        self.team2Score = team2Score
        self.team2Correct = team2Correct
        self.team2Wrong = team2Wrong
        self.winnerName = winnerName
        self.roundsCount = roundsCount
        self.categoriesPlayedCount = categoriesPlayedCount
    }
}
