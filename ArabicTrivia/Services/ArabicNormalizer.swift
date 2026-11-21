import Foundation

/// خدمة تطبيع ومقارنة النصوص والكلمات باللغة العربية السليمة
public struct ArabicNormalizer {
    
    /// إزالة التشكيل (الحركات والتنوين والشدة)
    public static func removeDiacritics(_ text: String) -> String {
        let diacritics: Set<Character> = [
            "\u{064B}", // Tanwin Fath
            "\u{064C}", // Tanwin Damm
            "\u{064D}", // Tanwin Kasr
            "\u{064E}", // Fatha
            "\u{064F}", // Damma
            "\u{0650}", // Kasra
            "\u{0651}", // Shadda
            "\u{0652}", // Sukun
            "\u{0670}", // Dagger Alif
            "\u{0640}"  // Tatweel / Kashida
        ]
        return text.filter { !diacritics.contains($0) }
    }
    
    /// تطبيع الألف والهمزات والياء والتاء المربوطة
    public static func normalize(_ text: String) -> String {
        var result = removeDiacritics(text.trimmingCharacters(in: .whitespacesAndNewlines))
        
        // توحيد الألفات (أ ، إ ، آ ، ٱ -> ا)
        result = result.replacingOccurrences(of: "[أإآٱ]", with: "ا", options: .regularExpression)
        
        // توحيد الياء والألف المقصورة (ى -> ي)
        result = result.replacingOccurrences(of: "ى", with: "ي")
        
        // توحيد التاء المربوطة والهاء (ة -> ه)
        result = result.replacingOccurrences(of: "ة", with: "ه")
        
        // إزالة علامات الترقيم والأقواس والمسافات الزائدة
        result = result.replacingOccurrences(of: "[\\.,;:!؟?()\\-_\"'`]", with: " ", options: .regularExpression)
        result = result.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        
        return result.trimmingCharacters(in: .whitespaces)
    }
    
    /// التحقق مما إذا كانت الكلمة تبدأ بالحرف المحدد
    /// يأخذ بالحسبان "الـ" التعريفية (مثل "المكسيك" مع حرف "م")
    public static func startsWithLetter(_ word: String, letter: String) -> Bool {
        let cleanWord = normalize(word).lowercased()
        let cleanLetter = normalize(letter).lowercased()
        
        guard let targetChar = cleanLetter.first else { return false }
        
        // فحص البداية المباشرة
        if cleanWord.first == targetChar {
            return true
        }
        
        // فحص البداية بعد تجريد "الـ" التعريفية
        if cleanWord.hasPrefix("ال") && cleanWord.count > 2 {
            let indexAfterAl = cleanWord.index(cleanWord.startIndex, offsetBy: 2)
            let withoutAl = cleanWord[indexAfterAl...]
            if withoutAl.first == targetChar {
                return true
            }
        }
        
        // فحص خاص بالهمزات عند الألف
        let alefGroup: Set<Character> = ["ا", "أ", "إ", "آ", "ٱ"]
        if alefGroup.contains(targetChar) {
            if let firstChar = cleanWord.first, alefGroup.contains(firstChar) {
                return true
            }
            if cleanWord.hasPrefix("ال") && cleanWord.count > 2 {
                let indexAfterAl = cleanWord.index(cleanWord.startIndex, offsetBy: 2)
                if let charAfterAl = cleanWord[indexAfterAl...].first, alefGroup.contains(charAfterAl) {
                    return true
                }
            }
        }
        
        return false
    }
    
    /// فحص دقة إجابة اللاعب مقارنة بالإجابة الصحيحة
    public static func isAnswerMatch(userInput: String, correctAnswer: String) -> Bool {
        let normalizedUser = normalize(userInput).lowercased()
        let normalizedCorrect = normalize(correctAnswer).lowercased()
        
        if normalizedUser == normalizedCorrect {
            return true
        }
        
        // مطابقة مع تجريد "ال"
        let userStripped = normalizedUser.hasPrefix("ال") ? String(normalizedUser.dropFirst(2)) : normalizedUser
        let correctStripped = normalizedCorrect.hasPrefix("ال") ? String(normalizedCorrect.dropFirst(2)) : normalizedCorrect
        
        return userStripped == correctStripped
    }
}
