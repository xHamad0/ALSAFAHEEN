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
        // فحص توحيد الهمزات والألفات
        XCTAssertEqual(ArabicNormalizer.normalize("أحمد"), ArabicNormalizer.normalize("احمد"))
        XCTAssertEqual(ArabicNormalizer.normalize("إبراهيم"), ArabicNormalizer.normalize("ابراهيم"))
        XCTAssertEqual(ArabicNormalizer.normalize("آسيا"), ArabicNormalizer.normalize("اسيا"))
        
        // فحص إزالة الحركات والتشكيل
        XCTAssertEqual(ArabicNormalizer.removeDiacritics("سِـجَـالٌ"), "سـجـال")
        
        // فحص الياء والألف المقصورة
        XCTAssertEqual(ArabicNormalizer.normalize("موسى"), ArabicNormalizer.normalize("موسي"))
        
        // فحص مطابقة الإجابات مع تجريد الـ التعريف
        XCTAssertTrue(ArabicNormalizer.isAnswerMatch(userInput: "مكسيك", correctAnswer: "المكسيك"))
        XCTAssertTrue(ArabicNormalizer.isAnswerMatch(userInput: "المكسيك", correctAnswer: "مكسيك"))
    }

    func testLettersCategoryStrictRule() {
        // التحقق من أن "المكسيك" تبدأ بحرف "م"
        XCTAssertTrue(ArabicNormalizer.startsWithLetter("المكسيك", letter: "م"))
        XCTAssertTrue(ArabicNormalizer.startsWithLetter("مكسيكو", letter: "م"))
        
        // التحقق من أن "بوخارست" لا تبدأ بحرف "ر"
        XCTAssertFalse(ArabicNormalizer.startsWithLetter("بوخارست", letter: "ر"))
        
        // التحقق من أن "رومانيا" تبدأ بحرف "ر"
        XCTAssertTrue(ArabicNormalizer.startsWithLetter("رومانيا", letter: "ر"))
        
        // التحقق من الألف والهمزات
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

    func testJSONImporterStrictRejectionOfTrueFalse() {
        let importer = JSONImporterService.shared
        
        // محاولة استيراد سؤال صح وخطأ يجب أن ترفض تماماً
        let invalidJSON = """
        [
            {
                "id": "invalid-tf-1",
                "text": "هل الشمس تدور حول الأرض؟",
                "answer": "خطأ",
                "category": "science",
                "difficulty": 100,
                "type": "true_false"
            }
        ]
        """
        
        let result = importer.importQuestions(from: invalidJSON.data(using: .utf8)!)
        XCTAssertEqual(result.successfullyAdded, 0)
        XCTAssertFalse(result.errors.isEmpty)
        XCTAssertTrue(result.errors.first?.contains("صح أو خطأ ممنوعة") ?? false)
    }

    func testTeamTurnSwitching() {
        let team1 = Team(name: "الفريق الأول", colorHex: "#3B82F6")
        let team2 = Team(name: "الفريق الثاني", colorHex: "#EF4444")
        
        var session = GameSession(
            team1: team1,
            team2: team2,
            totalRounds: 5,
            currentRound: 1,
            currentTurnTeamIndex: 0
        )
        
        let vm = GamePlayViewModel(session: session)
        XCTAssertEqual(vm.session.currentTurnTeamIndex, 0)
        
        vm.proceedToNextTurn()
        XCTAssertEqual(vm.session.currentTurnTeamIndex, 1)
        
        vm.proceedToNextTurn()
        XCTAssertEqual(vm.session.currentTurnTeamIndex, 0)
        XCTAssertEqual(vm.session.currentRound, 2)
    }
}
