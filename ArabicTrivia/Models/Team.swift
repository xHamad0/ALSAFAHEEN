import Foundation
import SwiftUI

/// نموذج الفريق المشارك في اللعبة
public struct Team: Identifiable, Codable, Equatable {
    public var id: String
    public var name: String
    public var colorHex: String
    public var score: Int
    public var correctAnswersCount: Int
    public var wrongAnswersCount: Int
    public var lifelinesRemaining: [String: Int] // LifelineType.rawValue -> Count
    public var currentStreak: Int
    public var longestStreak: Int
    
    public init(
        id: String = UUID().uuidString,
        name: String,
        colorHex: String,
        score: Int = 0,
        correctAnswersCount: Int = 0,
        wrongAnswersCount: Int = 0,
        lifelinesRemaining: [String: Int] = [
            LifelineType.fiftyFifty.rawValue: 1,
            LifelineType.doublePoints.rawValue: 1,
            LifelineType.extraTime.rawValue: 1,
            LifelineType.stealQuestion.rawValue: 1
        ],
        currentStreak: Int = 0,
        longestStreak: Int = 0
    ) {
        self.id = id
        self.name = name
        self.colorHex = colorHex
        self.score = score
        self.correctAnswersCount = correctAnswersCount
        self.wrongAnswersCount = wrongAnswersCount
        self.lifelinesRemaining = lifelinesRemaining
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
    }
    
    public var color: Color {
        Color(hex: colorHex)
    }
    
    public mutating func resetForNewGame() {
        self.score = 0
        self.correctAnswersCount = 0
        self.wrongAnswersCount = 0
        self.currentStreak = 0
        self.longestStreak = 0
        self.lifelinesRemaining = [
            LifelineType.fiftyFifty.rawValue: 1,
            LifelineType.doublePoints.rawValue: 1,
            LifelineType.extraTime.rawValue: 1,
            LifelineType.stealQuestion.rawValue: 1
        ]
    }
}
