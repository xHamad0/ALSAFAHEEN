import Foundation
import SwiftUI
import Combine

/// مدير منطق اللعبة وشاشة اللعب المباشر
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
    
    private var timerSubscription: AnyCancellable?
    private let questionService = QuestionBankService.shared
    private let tracker = UsedQuestionsTracker.shared
    private let dataManager = DataManager.shared
    private let audio = AudioService.shared
    private let haptic = HapticService.shared
    
    public init(session: GameSession) {
        self.session = session
        self.remainingSeconds = session.timeLimitSeconds
        
        // إذا كان التوزيع العشوائي مفعلاً، نبدأ باختيار عشوائي للتصنيف
        if session.isRandomCategoryDistribution {
            pickRandomCategory()
        }
    }
    
    // MARK: - Category Selection
    public func selectCategory(_ category: QuestionCategory) {
        haptic.selection()
        session.activeCategory = category
        session.phase = .pointsSelection
        saveCurrentProgress()
    }
    
    public func pickRandomCategory() {
        if let cat = session.selectedCategories.shuffled().first {
            selectCategory(cat)
        }
    }
    
    // MARK: - Points & Question Selection (100 | 200 | 300 | 400 | 500)
    public func selectPoints(_ difficulty: DifficultyLevel) {
        guard let category = session.activeCategory else { return }
        haptic.impact(.medium)
        
        session.activeDifficulty = difficulty
        
        // جلب سؤال غير مكرر
        if let question = questionService.fetchQuestion(for: category, difficulty: difficulty) {
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
            
            // تسجيل السؤال لمنع تكراره مستقبلاً
            tracker.markAsUsed(id: question.id)
            session.questionsUsedInSession.append(question.id)
            
            startTimer()
            saveCurrentProgress()
        } else {
            // نفاد الأسئلة في هذا التصنيف والصعوبة
            alertMessage = "تم استهلاك جميع أسئلة تصنيف «\(category.titleArabic)» بقيمة \(difficulty.points) نقطة! يمكنك تجربة قيمة أخرى أو تصنيف آخر."
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
        
        if isCorrect {
            audio.playCorrectSound()
            haptic.notification(.success)
            
            // إضافة النقاط للفريق صاحب الدور
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
    
    // MARK: - Lifelines (وسائل المساعدة)
    public func canUseLifeline(_ type: LifelineType) -> Bool {
        let count = session.currentTeam.lifelinesRemaining[type.rawValue] ?? 0
        return count > 0 && session.phase == .questionAnswering
    }
    
    public func useLifeline(_ type: LifelineType) {
        guard canUseLifeline(type) else { return }
        audio.playLifelineSound()
        haptic.impact(.heavy)
        
        // خصم الاستخدام
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
    
    // MARK: - Move to Next Turn / Finish
    public func proceedToNextTurn() {
        haptic.selection()
        
        // التحقق مما إذا كان كلا الفريقين قد لعبا نفس الجولة
        if session.currentTurnTeamIndex == 0 {
            // الانتقال للفريق الثاني
            session.currentTurnTeamIndex = 1
        } else {
            // اكتملت دورة الجولة للفريقين معاً
            if session.currentRound < session.totalRounds {
                session.currentRound += 1
                session.currentTurnTeamIndex = 0
            } else {
                // نهاية الجولات المحددة
                finishMatch()
                return
            }
        }
        
        // إعادة التعيين للجولة التالية
        resetForNextTurn()
    }
    
    private func resetForNextTurn() {
        session.phase = session.isRandomCategoryDistribution ? .pointsSelection : .categorySelection
        if session.isRandomCategoryDistribution {
            pickRandomCategory()
        } else {
            session.activeCategory = nil
        }
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
        
        // فحص التعادل
        let winnerName: String?
        if session.team1.score > session.team2.score {
            winnerName = session.team1.name
            audio.playVictorySound()
        } else if session.team2.score > session.team1.score {
            winnerName = session.team2.name
            audio.playVictorySound()
        } else {
            winnerName = nil // تعادل
        }
        
        // حفظ سجل المباراة
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
            categoriesPlayedCount: session.selectedCategories.count
        )
        
        dataManager.saveMatchRecord(record)
        dataManager.clearActiveSession()
    }
    
    /// جولة الحسم لفض التعادل
    public func startTieBreakerRound() {
        session.totalRounds += 1
        session.currentRound += 1
        session.currentTurnTeamIndex = 0
        resetForNextTurn()
    }
    
    private func saveCurrentProgress() {
        dataManager.saveActiveSession(session)
    }
}
