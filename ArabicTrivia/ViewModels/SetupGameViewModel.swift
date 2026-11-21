import Foundation
import SwiftUI

/// مدير إعداد المباراة قبل بدئها
public final class SetupGameViewModel: ObservableObject {
    @Published public var team1Name: String
    @Published public var team2Name: String
    @Published public var team1ColorHex: String
    @Published public var team2ColorHex: String
    
    @Published public var totalRounds: Int = 10
    @Published public var timeLimitSeconds: Int = 30
    @Published public var selectedCategories: Set<QuestionCategory> = Set(QuestionCategory.allCases)
    @Published public var isRandomCategoryDistribution: Bool = false
    @Published public var allowStealQuestion: Bool = true
    
    public let roundOptions = [5, 10, 15, 20]
    public let timeOptions = [15, 20, 30, 45, 60]
    
    private let dataManager = DataManager.shared
    
    public init() {
        self.team1Name = dataManager.defaultTeam1Name
        self.team2Name = dataManager.defaultTeam2Name
        self.team1ColorHex = dataManager.defaultTeam1Color
        self.team2ColorHex = dataManager.defaultTeam2Color
    }
    
    public func selectAllCategories() {
        selectedCategories = Set(QuestionCategory.allCases)
    }
    
    public func deselectAllCategories() {
        selectedCategories.removeAll()
    }
    
    public func toggleCategory(_ category: QuestionCategory) {
        if selectedCategories.contains(category) {
            if selectedCategories.count > 1 {
                selectedCategories.remove(category)
            }
        } else {
            selectedCategories.insert(category)
        }
    }
    
    public var isValidSetup: Bool {
        !team1Name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !team2Name.trimmingCharacters(in: .whitespaces).isEmpty &&
        team1Name != team2Name &&
        !selectedCategories.isEmpty
    }
    
    public func createGameSession() -> GameSession {
        // حفظ الأسماء والألوان كإعدادات افتراضية للمرات القادمة
        dataManager.defaultTeam1Name = team1Name
        dataManager.defaultTeam2Name = team2Name
        dataManager.defaultTeam1Color = team1ColorHex
        dataManager.defaultTeam2Color = team2ColorHex
        dataManager.saveSettings()
        
        let team1 = Team(name: team1Name, colorHex: team1ColorHex)
        let team2 = Team(name: team2Name, colorHex: team2ColorHex)
        
        return GameSession(
            team1: team1,
            team2: team2,
            totalRounds: totalRounds,
            timeLimitSeconds: timeLimitSeconds,
            selectedCategories: Array(selectedCategories),
            isRandomCategoryDistribution: isRandomCategoryDistribution,
            allowStealQuestion: allowStealQuestion
        )
    }
}
