import Foundation

/// حالات تدفق اللعب في الجولة
public enum GamePhase: String, Codable {
    case boardSelection        // لوحة الجولة (عرض الفئات الـ 6 وخانات 100-500 بسؤالين لكل خانة)
    case questionAnswering     // الإجابة عن السؤال المختار
    case answerRevealed        // كشف الإجابة والنتيجة
    case tieBreakerPending     // حالة التعادل في انتظار جولة الحسم
    case matchFinished         // انتهاء المباراة
}

/// خانة في لوحة الأسئلة للجولة المكونة من 6 فئات (كل قيمة تحتوي على سؤالين)
public struct BoardSlot: Identifiable, Codable, Equatable {
    public var id: String
    public var category: QuestionCategory
    public var difficulty: DifficultyLevel
    public var slotNumber: Int // 1 أو 2 (لأن كل خانة بها سؤالان)
    public var questionId: String?
    public var isPlayed: Bool
    public var playedByTeamIndex: Int? // 0 أو 1
    public var wasCorrect: Bool?
    
    public init(
        category: QuestionCategory,
        difficulty: DifficultyLevel,
        slotNumber: Int,
        questionId: String? = nil,
        isPlayed: Bool = false,
        playedByTeamIndex: Int? = nil,
        wasCorrect: Bool? = nil
    ) {
        self.id = "\(category.id)_\(difficulty.rawValue)_\(slotNumber)"
        self.category = category
        self.difficulty = difficulty
        self.slotNumber = slotNumber
        self.questionId = questionId
        self.isPlayed = isPlayed
        self.playedByTeamIndex = playedByTeamIndex
        self.wasCorrect = wasCorrect
    }
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
    public var boardCategories: [QuestionCategory] // الفئات الـ 6 الثابتة للجولة
    public var boardSlots: [BoardSlot] // الـ 60 خانة في اللوحة (6 فئات × 5 قيم × سؤالين)
    public var activeBoardSlotId: String?
    
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
    public var questionsUsedInSession: [String]
    
    public init(
        id: String = UUID().uuidString,
        team1: Team,
        team2: Team,
        totalRounds: Int = 1,
        currentRound: Int = 1,
        currentTurnTeamIndex: Int = 0,
        timeLimitSeconds: Int = 30,
        selectedCategories: [QuestionCategory] = [],
        boardCategories: [QuestionCategory] = [],
        boardSlots: [BoardSlot] = [],
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
        self.boardCategories = boardCategories
        self.boardSlots = boardSlots
        self.activeBoardSlotId = nil
        self.allowStealQuestion = allowStealQuestion
        self.phase = .boardSelection
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
    
    public var totalPlayedSlotsCount: Int {
        boardSlots.filter { $0.isPlayed }.count
    }
}
