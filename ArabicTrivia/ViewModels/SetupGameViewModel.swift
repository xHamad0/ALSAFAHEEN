import Foundation
import SwiftUI

/// مدير إعداد المباراة قبل بدئها مع تثبيت الـ 6 فئات للجولة
public final class SetupGameViewModel: ObservableObject {
    @Published public var team1Name: String
    @Published public var team2Name: String
    @Published public var team1ColorHex: String
    @Published public var team2ColorHex: String
    
    @Published public var timeLimitSeconds: Int = 30
    @Published public var selectedCategories: Set<QuestionCategory> = []
    @Published public var allowStealQuestion: Bool = true
    
    public let timeOptions = [15, 20, 30, 45, 60]
    public let targetCategoriesCount = 6
    
    private let dataManager = DataManager.shared
    private let questionService = QuestionBankService.shared
    
    public init() {
        self.team1Name = dataManager.defaultTeam1Name
        self.team2Name = dataManager.defaultTeam2Name
        self.team1ColorHex = dataManager.defaultTeam1Color
        self.team2ColorHex = dataManager.defaultTeam2Color
        selectRandomSixCategories()
    }
    
    /// اختيار 6 فئات عشوائية فوراً
    public func selectRandomSixCategories() {
        let shuffled = QuestionCategory.allCases.shuffled()
        selectedCategories = Set(shuffled.prefix(targetCategoriesCount))
    }
    
    public func toggleCategory(_ category: QuestionCategory) {
        if selectedCategories.contains(category) {
            selectedCategories.remove(category)
        } else {
            if selectedCategories.count < targetCategoriesCount {
                selectedCategories.insert(category)
            }
        }
    }
    
    public var isValidSetup: Bool {
        !team1Name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !team2Name.trimmingCharacters(in: .whitespaces).isEmpty &&
        team1Name != team2Name &&
        selectedCategories.count == targetCategoriesCount
    }
    
    public func createGameSession() -> GameSession {
        dataManager.defaultTeam1Name = team1Name
        dataManager.defaultTeam2Name = team2Name
        dataManager.defaultTeam1Color = team1ColorHex
        dataManager.defaultTeam2Color = team2ColorHex
        dataManager.saveSettings()
        
        let team1 = Team(name: team1Name, colorHex: team1ColorHex)
        let team2 = Team(name: team2Name, colorHex: team2ColorHex)
        
        // تثبيت الفئات الـ 6 للجولة
        let boardCats = Array(selectedCategories)
        
        // بناء الـ 60 خانة (6 فئات × 5 قيم من 100 إلى 500 × سؤالين لكل قيمة: يمين ويسار)
        var slots: [BoardSlot] = []
        var assignedQuestionIDs = Set<String>()
        
        for cat in boardCats {
            for diff in DifficultyLevel.allCases {
                // السؤال الأول (العمود الأيمن)
                let q1 = questionService.fetchQuestionForSlot(category: cat, difficulty: diff, excludeIDs: assignedQuestionIDs)
                if let q1 = q1 {
                    assignedQuestionIDs.insert(q1.id)
                }
                slots.append(BoardSlot(
                    category: cat,
                    difficulty: diff,
                    slotNumber: 1,
                    questionId: q1?.id
                ))
                
                // السؤال الثاني (العمود الأيسر)
                let q2 = questionService.fetchQuestionForSlot(category: cat, difficulty: diff, excludeIDs: assignedQuestionIDs)
                if let q2 = q2 {
                    assignedQuestionIDs.insert(q2.id)
                }
                slots.append(BoardSlot(
                    category: cat,
                    difficulty: diff,
                    slotNumber: 2,
                    questionId: q2?.id
                ))
            }
        }
        
        return GameSession(
            team1: team1,
            team2: team2,
            totalRounds: 1,
            currentRound: 1,
            currentTurnTeamIndex: 0,
            timeLimitSeconds: timeLimitSeconds,
            selectedCategories: boardCats,
            boardCategories: boardCats,
            boardSlots: slots,
            allowStealQuestion: allowStealQuestion
        )
    }
}
