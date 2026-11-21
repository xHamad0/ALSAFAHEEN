import Foundation
import SwiftUI
import Combine

/// مدير منطق اللعبة وشاشة اللعب المباشر مع دعم اللوحة المكونة من 6 فئات وتعديل النتيجة وتغيير الدور
public final class GamePlayViewModel: ObservableObject {
    @Published public var session: GameSession
    @Published public var remainingSeconds: Int = 30
    @Published public var isTimerRunning: Bool = false
    @Published public var selectedOptionIndex: Int? = nil
    @Published public var directAnswerInput: String = ""
    @Published public var showExplanation: Bool = false
    @Published public var isStealMode: Bool = false
    @Published public var noQuestionsAvailableAlert: Bool = false
    @Published public var alertMessage: String = ""
    
    // تعديل النتيجة (Requirement 2)
    @Published public var showScoreEditSheet: Bool = false
    @Published public var editingTeamIndex: Int = 0
    @Published public var manualScoreText: String = ""
    
    private var timerSubscription: AnyCancellable?
    private let questionService = QuestionBankService.shared
    private let tracker = UsedQuestionsTracker.shared
    private let dataManager = DataManager.shared
    private let audio = AudioService.shared
    private let haptic = HapticService.shared
    
    public init(session: GameSession) {
        self.session = session
        self.remainingSeconds = session.timeLimitSeconds
    }
    
    // MARK: - تعديل الدور (Requirement 3: اقدر اعدل الدور عند مين)
    
    /// تبديل الدور إلى الفريق الآخر مباشرة في أي وقت
    public func switchTurn() {
        haptic.selection()
        session.currentTurnTeamIndex = (session.currentTurnTeamIndex == 0 ? 1 : 0)
        saveCurrentProgress()
    }
    
    /// تحديد الفريق صاحب الدور بشكل صريح
    public func setTurn(to teamIndex: Int) {
        guard teamIndex == 0 || teamIndex == 1 else { return }
        haptic.selection()
        session.currentTurnTeamIndex = teamIndex
        saveCurrentProgress()
    }
    
    // MARK: - تعديل النتيجة (Requirement 2: اقدر اعدل النتيجه)
    
    /// فتح واجهة تعديل نتيجة فريق معين
    public func openScoreEditor(for teamIndex: Int) {
        self.editingTeamIndex = teamIndex
        let currentScore = (teamIndex == 0 ? session.team1.score : session.team2.score)
        self.manualScoreText = "\(currentScore)"
        self.showScoreEditSheet = true
    }
    
    /// تعديل نتيجة الفريق بزيادة أو إنقاص نقاط
    public func adjustScore(delta: Int) {
        haptic.impact(.medium)
        if editingTeamIndex == 0 {
            session.team1.score = max(0, session.team1.score + delta)
            manualScoreText = "\(session.team1.score)"
        } else {
            session.team2.score = max(0, session.team2.score + delta)
            manualScoreText = "\(session.team2.score)"
        }
        saveCurrentProgress()
    }
    
    /// حفظ النتيجة المدخلة يدوياً
    public func applyManualScore() {
        if let newScore = Int(manualScoreText.trimmingCharacters(in: .whitespaces)) {
            haptic.notification(.success)
            if editingTeamIndex == 0 {
                session.team1.score = max(0, newScore)
            } else {
                session.team2.score = max(0, newScore)
            }
            saveCurrentProgress()
        }
        showScoreEditSheet = false
    }
    
    // MARK: - اختيار خانة من اللوحة (Requirement 4: 6 فئات، 100-500 بسؤالين لكل خانة)
    
    public func selectBoardSlot(_ slot: BoardSlot) {
        guard !slot.isPlayed else { return }
        haptic.impact(.medium)
        
        session.activeBoardSlotId = slot.id
        session.activeCategory = slot.category
        session.activeDifficulty = slot.difficulty
        
        // جلب السؤال المحجوز لهذه الخانة
        var question: Question? = nil
        if let qId = slot.questionId {
            question = questionService.fetchQuestionById(qId)
        }
        
        // في حال عدم توفره نجلب سؤالاً مطابقاً
        if question == nil {
            question = questionService.fetchQuestionForSlot(category: slot.category, difficulty: slot.difficulty)
        }
        
        if let question = question {
            session.currentQuestion = question
            session.phase = .questionAnswering
            session.eliminatedOptions = []
            session.isDoublePointsActive = false
            session.isStealAttempt = false
            session.lastAnswerWasCorrect = nil
            session.lastPointsEarned = 0
            selectedOptionIndex = nil
            directAnswerInput = ""
            showExplanation = false
            
            // تسجيل السؤال لمنع تكراره
            tracker.markAsUsed(id: question.id)
            session.questionsUsedInSession.append(question.id)
            
            startTimer()
            saveCurrentProgress()
        } else {
            alertMessage = "لم يتم العثور على سؤال متاح لهذه الخانة."
            noQuestionsAvailableAlert = true
            haptic.notification(.warning)
        }
    }
    
    // MARK: - Timer Handling
    public func startTimer() {
        guard session.timeLimitSeconds > 0 else { return }
        remainingSeconds = session.timeLimitSeconds
        isTimerRunning = true
        
        timerSubscription?.cancel()
        timerSubscription = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, self.isTimerRunning else { return }
                if self.remainingSeconds > 1 {
                    self.remainingSeconds -= 1
                    if self.remainingSeconds <= 5 {
                        self.audio.playTimerTickSound()
                        self.haptic.impact(.light)
                    }
                } else {
                    self.remainingSeconds = 0
                    self.timeDidExpire()
                }
            }
    }
    
    public func pauseTimer() {
        isTimerRunning = false
    }
    
    public func resumeTimer() {
        if remainingSeconds > 0 {
            isTimerRunning = true
        }
    }
    
    public func togglePauseGame() {
        session.isPaused.toggle()
        if session.isPaused {
            pauseTimer()
        } else {
            resumeTimer()
        }
    }
    
    private func timeDidExpire() {
        stopTimer()
        audio.playTimeOutSound()
        haptic.notification(.error)
        evaluateAnswer(isCorrect: false, points: 0)
    }
    
    public func stopTimer() {
        isTimerRunning = false
        timerSubscription?.cancel()
        timerSubscription = nil
    }
    
    // MARK: - Answer Submission & Evaluation
    public func submitMultipleChoiceAnswer(selectedIndex: Int) {
        guard let question = session.currentQuestion,
              let options = question.options,
              selectedIndex < options.count else { return }
        
        stopTimer()
        selectedOptionIndex = selectedIndex
        let chosenText = options[selectedIndex]
        let isCorrect = ArabicNormalizer.isAnswerMatch(userInput: chosenText, correctAnswer: question.answer)
        
        processAnswerResult(isCorrect: isCorrect)
    }
    
    public func submitDirectOrBlankAnswer() {
        guard let question = session.currentQuestion else { return }
        stopTimer()
        
        let isCorrect: Bool
        if question.category == .letters, let letter = question.letter {
            let matchesLetter = ArabicNormalizer.startsWithLetter(directAnswerInput, letter: letter)
            let matchesText = ArabicNormalizer.isAnswerMatch(userInput: directAnswerInput, correctAnswer: question.answer)
            isCorrect = matchesLetter && matchesText
        } else {
            isCorrect = ArabicNormalizer.isAnswerMatch(userInput: directAnswerInput, correctAnswer: question.answer)
        }
        
        processAnswerResult(isCorrect: isCorrect)
    }
    
    public func verifyManualAnswer(isCorrect: Bool) {
        stopTimer()
        processAnswerResult(isCorrect: isCorrect)
    }
    
    private func processAnswerResult(isCorrect: Bool) {
        guard let difficulty = session.activeDifficulty else { return }
        let basePoints = difficulty.points
        let earnedPoints = isCorrect ? (session.isDoublePointsActive ? basePoints * 2 : basePoints) : 0
        
        evaluateAnswer(isCorrect: isCorrect, points: earnedPoints)
    }
    
    private func evaluateAnswer(isCorrect: Bool, points: Int) {
        session.lastAnswerWasCorrect = isCorrect
        session.lastPointsEarned = points
        
        // تحديث حالة الخانة في لوحة الأسئلة
        if let activeSlotId = session.activeBoardSlotId,
           let index = session.boardSlots.firstIndex(where: { $0.id == activeSlotId }) {
            session.boardSlots[index].isPlayed = true
            session.boardSlots[index].playedByTeamIndex = session.currentTurnTeamIndex
            session.boardSlots[index].wasCorrect = isCorrect
        }
        
        if isCorrect {
            audio.playCorrectSound()
            haptic.notification(.success)
            
            if session.currentTurnTeamIndex == 0 {
                session.team1.score += points
                session.team1.correctAnswersCount += 1
                session.team1.currentStreak += 1
                if session.team1.currentStreak > session.team1.longestStreak {
                    session.team1.longestStreak = session.team1.currentStreak
                }
            } else {
                session.team2.score += points
                session.team2.correctAnswersCount += 1
                session.team2.currentStreak += 1
                if session.team2.currentStreak > session.team2.longestStreak {
                    session.team2.longestStreak = session.team2.currentStreak
                }
            }
        } else {
            audio.playWrongSound()
            haptic.notification(.error)
            
            if session.currentTurnTeamIndex == 0 {
                session.team1.wrongAnswersCount += 1
                session.team1.currentStreak = 0
            } else {
                session.team2.wrongAnswersCount += 1
                session.team2.currentStreak = 0
            }
        }
        
        session.phase = .answerRevealed
        saveCurrentProgress()
    }
    
    // MARK: - Lifelines
    public func canUseLifeline(_ type: LifelineType) -> Bool {
        let count = session.currentTeam.lifelinesRemaining[type.rawValue] ?? 0
        return count > 0 && session.phase == .questionAnswering
    }
    
    public func useLifeline(_ type: LifelineType) {
        guard canUseLifeline(type) else { return }
        audio.playLifelineSound()
        haptic.impact(.heavy)
        
        if session.currentTurnTeamIndex == 0 {
            session.team1.lifelinesRemaining[type.rawValue, default: 1] -= 1
        } else {
            session.team2.lifelinesRemaining[type.rawValue, default: 1] -= 1
        }
        
        switch type {
        case .fiftyFifty:
            applyFiftyFifty()
        case .doublePoints:
            session.isDoublePointsActive = true
        case .extraTime:
            remainingSeconds += 20
        case .stealQuestion:
            session.isStealAttempt = true
        }
    }
    
    private func applyFiftyFifty() {
        guard let question = session.currentQuestion,
              let options = question.options,
              options.count >= 4 else { return }
        
        var incorrectOptions = options.filter { !ArabicNormalizer.isAnswerMatch(userInput: $0, correctAnswer: question.answer) }
        incorrectOptions.shuffle()
        let toEliminate = Array(incorrectOptions.prefix(2))
        session.eliminatedOptions = toEliminate
    }
    
    // MARK: - الانتقال إلى الدور التالي والعودة للوحة الجولة
    public func proceedToNextTurn() {
        haptic.selection()
        
        // التحقق من اكتمال جميع خانات اللوحة الـ 60
        let unplayedSlots = session.boardSlots.filter { !$0.isPlayed }
        if unplayedSlots.isEmpty {
            finishMatch()
            return
        }
        
        // تبديل الدور تلقائياً للفريق الآخر
        session.currentTurnTeamIndex = (session.currentTurnTeamIndex == 0 ? 1 : 0)
        
        // العودة إلى لوحة الفئات الـ 6
        session.phase = .boardSelection
        session.activeBoardSlotId = nil
        session.activeCategory = nil
        session.activeDifficulty = nil
        session.currentQuestion = nil
        session.eliminatedOptions = []
        session.isDoublePointsActive = false
        session.isStealAttempt = false
        session.lastAnswerWasCorrect = nil
        session.lastPointsEarned = 0
        selectedOptionIndex = nil
        directAnswerInput = ""
        showExplanation = false
        
        saveCurrentProgress()
    }
    
    public func skipQuestion() {
        haptic.impact(.medium)
        stopTimer()
        evaluateAnswer(isCorrect: false, points: 0)
    }
    
    public func finishMatch() {
        stopTimer()
        session.phase = .matchFinished
        
        let winnerName: String?
        if session.team1.score > session.team2.score {
            winnerName = session.team1.name
            audio.playVictorySound()
        } else if session.team2.score > session.team1.score {
            winnerName = session.team2.name
            audio.playVictorySound()
        } else {
            winnerName = nil
        }
        
        let record = MatchRecord(
            team1Name: session.team1.name,
            team1ColorHex: session.team1.colorHex,
            team1Score: session.team1.score,
            team1Correct: session.team1.correctAnswersCount,
            team1Wrong: session.team1.wrongAnswersCount,
            team2Name: session.team2.name,
            team2ColorHex: session.team2.colorHex,
            team2Score: session.team2.score,
            team2Correct: session.team2.correctAnswersCount,
            team2Wrong: session.team2.wrongAnswersCount,
            winnerName: winnerName,
            roundsCount: session.currentRound,
            categoriesPlayedCount: session.boardCategories.count
        )
        
        dataManager.saveMatchRecord(record)
        dataManager.clearActiveSession()
    }
    
    public func startTieBreakerRound() {
        session.totalRounds += 1
        session.currentRound += 1
        session.phase = .boardSelection
        saveCurrentProgress()
    }
    
    private func saveCurrentProgress() {
        dataManager.saveActiveSession(session)
    }
}
