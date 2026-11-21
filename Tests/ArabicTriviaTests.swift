import XCTest
@testable import ArabicTrivia

final class ArabicTriviaTests: XCTestCase {

    func testScoringSystemNewValues() {
        XCTAssertEqual(DifficultyLevel.veryEasy.points, 100)
        XCTAssertEqual(DifficultyLevel.easy.points, 200)
        XCTAssertEqual(DifficultyLevel.medium.points, 300)
        XCTAssertEqual(DifficultyLevel.hard.points, 400)
        XCTAssertEqual(DifficultyLevel.expert.points, 500)
    }

    func testArabicNormalizer() {
        XCTAssertEqual(ArabicNormalizer.normalize("أحمد"), ArabicNormalizer.normalize("احمد"))
        XCTAssertEqual(ArabicNormalizer.normalize("إبراهيم"), ArabicNormalizer.normalize("ابراهيم"))
        XCTAssertEqual(ArabicNormalizer.normalize("آسيا"), ArabicNormalizer.normalize("اسيا"))
        XCTAssertEqual(ArabicNormalizer.removeDiacritics("سِـجَـالٌ"), "سـجـال")
        XCTAssertEqual(ArabicNormalizer.normalize("موسى"), ArabicNormalizer.normalize("موسي"))
        XCTAssertTrue(ArabicNormalizer.isAnswerMatch(userInput: "مكسيك", correctAnswer: "المكسيك"))
        XCTAssertTrue(ArabicNormalizer.isAnswerMatch(userInput: "المكسيك", correctAnswer: "مكسيك"))
    }

    func testLettersCategoryStrictRule() {
        XCTAssertTrue(ArabicNormalizer.startsWithLetter("المكسيك", letter: "م"))
        XCTAssertTrue(ArabicNormalizer.startsWithLetter("مكسيكو", letter: "م"))
        XCTAssertFalse(ArabicNormalizer.startsWithLetter("بوخارست", letter: "ر"))
        XCTAssertTrue(ArabicNormalizer.startsWithLetter("رومانيا", letter: "ر"))
        XCTAssertTrue(ArabicNormalizer.startsWithLetter("أمستردام", letter: "أ"))
        XCTAssertTrue(ArabicNormalizer.startsWithLetter("امستردام", letter: "أ"))
    }

    func testAntiRepetitionTracker() {
        let tracker = UsedQuestionsTracker.shared
        let testID = "test-uuid-anti-repetition-\(UUID().uuidString)"
        XCTAssertFalse(tracker.isUsed(id: testID))
        tracker.markAsUsed(id: testID)
        XCTAssertTrue(tracker.isUsed(id: testID))
    }

    func testSixCategoriesAndSixtyBoardSlots() {
        let vm = SetupGameViewModel()
        vm.selectRandomSixCategories()
        XCTAssertEqual(vm.selectedCategories.count, 6)
        
        let session = vm.createGameSession()
        XCTAssertEqual(session.boardCategories.count, 6)
        // 6 فئات × 5 قيم × 2 سؤالين = 60 خانة
        XCTAssertEqual(session.boardSlots.count, 60)
        
        // التحقق من أن كل تصنيف به 10 خانات
        for cat in session.boardCategories {
            let catSlots = session.boardSlots.filter { $0.category == cat }
            XCTAssertEqual(catSlots.count, 10)
            
            // تحقق من أن كل صعوبة بها خانتان (1 و 2)
            for diff in DifficultyLevel.allCases {
                let diffSlots = catSlots.filter { $0.difficulty == diff }
                XCTAssertEqual(diffSlots.count, 2)
            }
        }
    }

    func testManualScoreEdit() {
        let team1 = Team(name: "الفريق الأول", colorHex: "#3B82F6", score: 500)
        let team2 = Team(name: "الفريق الثاني", colorHex: "#EF4444", score: 200)
        let session = GameSession(team1: team1, team2: team2)
        let vm = GamePlayViewModel(session: session)
        
        vm.editingTeamIndex = 0
        vm.adjustScore(delta: 300)
        XCTAssertEqual(vm.session.team1.score, 800)
        
        vm.adjustScore(delta: -200)
        XCTAssertEqual(vm.session.team1.score, 600)
        
        vm.editingTeamIndex = 1
        vm.manualScoreText = "1500"
        vm.applyManualScore()
        XCTAssertEqual(vm.session.team2.score, 1500)
    }

    func testManualTurnSwitching() {
        let team1 = Team(name: "الفريق الأول", colorHex: "#3B82F6")
        let team2 = Team(name: "الفريق الثاني", colorHex: "#EF4444")
        let session = GameSession(team1: team1, team2: team2)
        let vm = GamePlayViewModel(session: session)
        
        XCTAssertEqual(vm.session.currentTurnTeamIndex, 0)
        vm.switchTurn()
        XCTAssertEqual(vm.session.currentTurnTeamIndex, 1)
        vm.switchTurn()
        XCTAssertEqual(vm.session.currentTurnTeamIndex, 0)
        
        vm.setTurn(to: 1)
        XCTAssertEqual(vm.session.currentTurnTeamIndex, 1)
    }
}
