import Foundation

/// حالات تدفق اللعب في الجولة
public enum GamePhase: String, Codable {
    case categorySelection     // اختيار التصنيف
    case pointsSelection       // اختيار قيمة السؤال (100, 200, 300, 400, 500)
    case questionAnswering     // الإجابة عن السؤال
    case answerRevealed        // كشف الإجابة والنتيجة
    case tieBreakerPending     // حالة التعادل في انتظار جولة الحسم
    case matchFinished         // انتهاء المباراة
}

/// جلسة المباراة الحالية
public struct GameSession: Identifiable, Codable {
    public var id: String
    public var team1: Team
    public var team2: Team
    public var totalRounds: Int
    public var currentRound: Int
    public var currentTurnTeamIndex: Int // 0: Team 1, 1: Team 2
    public var timeLimitSeconds: Int
    public var selectedCategories: [QuestionCategory]
    public var isRandomCategoryDistribution: Bool
    public var allowStealQuestion: Bool
    
    public var phase: GamePhase
    public var activeCategory: QuestionCategory?
    public var activeDifficulty: DifficultyLevel?
    public var currentQuestion: Question?
    public var eliminatedOptions: [String] // الخيارات المحذوفة عبر 50:50
    public var isDoublePointsActive: Bool
    public var isStealAttempt: Bool
    public var lastAnswerWasCorrect: Bool?
    public var lastPointsEarned: Int
    public var isPaused: Bool
    public var dateStarted: Date
    public var questionsUsedInSession: [String] // معرّفات الأسئلة المستخدمة في هذه المباراة
    
    public init(
        id: String = UUID().uuidString,
        team1: Team,
        team2: Team,
        totalRounds: Int = 10,
        currentRound: Int = 1,
        currentTurnTeamIndex: Int = 0,
        timeLimitSeconds: Int = 30,
        selectedCategories: [QuestionCategory] = QuestionCategory.allCases,
        isRandomCategoryDistribution: Bool = false,
        allowStealQuestion: Bool = true
    ) {
        self.id = id
        self.team1 = team1
        self.team2 = team2
        self.totalRounds = totalRounds
        self.currentRound = currentRound
        self.currentTurnTeamIndex = currentTurnTeamIndex
        self.timeLimitSeconds = timeLimitSeconds
        self.selectedCategories = selectedCategories
        self.isRandomCategoryDistribution = isRandomCategoryDistribution
        self.allowStealQuestion = allowStealQuestion
        self.phase = .categorySelection
        self.activeCategory = nil
        self.activeDifficulty = nil
        self.currentQuestion = nil
        self.eliminatedOptions = []
        self.isDoublePointsActive = false
        self.isStealAttempt = false
        self.lastAnswerWasCorrect = nil
        self.lastPointsEarned = 0
        self.isPaused = false
        self.dateStarted = Date()
        self.questionsUsedInSession = []
    }
    
    public var currentTeam: Team {
        get {
            currentTurnTeamIndex == 0 ? team1 : team2
        }
        set {
            if currentTurnTeamIndex == 0 {
                team1 = newValue
            } else {
                team2 = newValue
            }
        }
    }
    
    public var opposingTeam: Team {
        get {
            currentTurnTeamIndex == 0 ? team2 : team1
        }
        set {
            if currentTurnTeamIndex == 0 {
                team2 = newValue
            } else {
                team1 = newValue
            }
        }
    }
}
