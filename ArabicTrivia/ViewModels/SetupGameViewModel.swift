import Foundation
import SwiftUI

/// مدير إعداد المباراة قبل بدئها مع تثبيت الـ 6 فئات للجولة ووسائل المساعدة المختارة
public final class SetupGameViewModel: ObservableObject {
    @Published public var gameName: String = ""
    @Published public var team1Name: String
    @Published public var team2Name: String
    @Published public var team1ColorHex: String
    @Published public var team2ColorHex: String
    
    @Published public var team1SelectedLifelines: Set<LifelineType> = [.fiftyFifty, .doublePoints, .extraTime]
    @Published public var team2SelectedLifelines: Set<LifelineType> = [.fiftyFifty, .doublePoints, .extraTime]
    
    @Published public var timeLimitSeconds: Int = 30
    @Published public var selectedCategories: Set<QuestionCategory> = []
    @Published public var allowStealQuestion: Bool = true
    
    public let timeOptions = [15, 20, 30, 45, 60]
    public let targetCategoriesCount = 6
    public let maxLifelinesPerTeam = 3
    
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
    
    /// تبديل وسيلة المساعدة لفريق معين (بحد أقصى 3 وسائل)
    public func toggleLifeline(_ lifeline: LifelineType, forTeam teamIndex: Int) {
        if teamIndex == 0 {
            if team1SelectedLifelines.contains(lifeline) {
                if team1SelectedLifelines.count > 1 {
                    team1SelectedLifelines.remove(lifeline)
                }
            } else if team1SelectedLifelines.count < maxLifelinesPerTeam {
                team1SelectedLifelines.insert(lifeline)
            }
        } else {
            if team2SelectedLifelines.contains(lifeline) {
                if team2SelectedLifelines.count > 1 {
                    team2SelectedLifelines.remove(lifeline)
                }
            } else if team2SelectedLifelines.count < maxLifelinesPerTeam {
                team2SelectedLifelines.insert(lifeline)
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
        
        var t1Lifelines: [String: Int] = [:]
        for l in LifelineType.allCases {
            t1Lifelines[l.rawValue] = team1SelectedLifelines.contains(l) ? 1 : 0
        }
        
        var t2Lifelines: [String: Int] = [:]
        for l in LifelineType.allCases {
            t2Lifelines[l.rawValue] = team2SelectedLifelines.contains(l) ? 1 : 0
        }
        
        let team1 = Team(name: team1Name, colorHex: team1ColorHex, lifelinesRemaining: t1Lifelines)
        let team2 = Team(name: team2Name, colorHex: team2ColorHex, lifelinesRemaining: t2Lifelines)
        
        // تثبيت الفئات الـ 6 للجولة
        let boardCats = Array(selectedCategories)
        
        // بناء الـ 60 خانة (6 فئات × 5 قيم من 100 إلى 500 × سؤالين لكل قيمة: يمين ويسار)
        var slots: [BoardSlot] = []
        var assignedQuestionIDs = Set<String>()
        
        for cat in boardCats {
            for diff in DifficultyLevel.allCases {
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
