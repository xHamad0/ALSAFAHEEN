import Foundation

/// نموذج السؤال الواحد في بنك الأسئلة
public struct Question: Identifiable, Codable, Hashable {
    public let id: String
    public let text: String
    public let answer: String
    public let options: [String]?
    public let category: QuestionCategory
    public let difficulty: DifficultyLevel
    public let type: QuestionType
    public let explanation: String?
    public let letter: String?
    public let flagImage: String?
    public let flagCountryCode: String?
    
    public init(
        id: String = UUID().uuidString,
        text: String,
        answer: String,
        options: [String]? = nil,
        category: QuestionCategory,
        difficulty: DifficultyLevel,
        type: QuestionType,
        explanation: String? = nil,
        letter: String? = nil,
        flagImage: String? = nil,
        flagCountryCode: String? = nil
    ) {
        self.id = id
        self.text = text
        self.answer = answer
        self.options = options
        self.category = category
        self.difficulty = difficulty
        self.type = type
        self.explanation = explanation
        self.letter = letter
        self.flagImage = flagImage
        self.flagCountryCode = flagCountryCode
    }
}
