import Foundation

public struct TypingValidationResult: Equatable {
    public let isComplete: Bool
    public let isValidPrefix: Bool
    public let pasteDetected: Bool
    public let firstErrorIndex: Int?
    public let accuracyPercentage: Int
    
    public init(
        isComplete: Bool,
        isValidPrefix: Bool,
        pasteDetected: Bool,
        firstErrorIndex: Int?,
        accuracyPercentage: Int
    ) {
        self.isComplete = isComplete
        self.isValidPrefix = isValidPrefix
        self.pasteDetected = pasteDetected
        self.firstErrorIndex = firstErrorIndex
        self.accuracyPercentage = accuracyPercentage
    }
}

public struct MathProblem: Identifiable, Equatable {
    public var id: String { expression }
    public let expression: String
    public let expectedAnswer: Int
    
    public init(expression: String, expectedAnswer: Int) {
        self.expression = expression
        self.expectedAnswer = expectedAnswer
    }
}

public enum ChallengeEngine {
    
    /// Validates character-by-character typing for Faith/Scripture and Quotes challenges.
    /// Detects and blocks clipboard paste / autocomplete bursts (> 2 characters added at once).
    public static func validateTyping(
        targetText: String,
        previousInput: String,
        newInput: String
    ) -> TypingValidationResult {
        // Detect clipboard paste or predictive word burst (> 2 characters added in one change)
        if newInput.count - previousInput.count > 2 {
            return TypingValidationResult(
                isComplete: false,
                isValidPrefix: false,
                pasteDetected: true,
                firstErrorIndex: previousInput.count,
                accuracyPercentage: 0
            )
        }
        
        var firstError: Int? = nil
        var matchingChars = 0
        
        let targetChars = Array(targetText)
        let inputChars = Array(newInput)
        let compareLength = min(inputChars.count, targetChars.count)
        
        for i in 0..<compareLength {
            if inputChars[i] == targetChars[i] {
                matchingChars += 1
            } else if firstError == nil {
                firstError = i
            }
        }
        
        if inputChars.count > targetChars.count && firstError == nil {
            firstError = targetChars.count
        }
        
        let isComplete = (newInput == targetText)
        let isValidPrefix = (firstError == nil)
        let accuracy = targetText.isEmpty ? 100 : (matchingChars * 100) / targetText.count
        
        return TypingValidationResult(
            isComplete: isComplete,
            isValidPrefix: isValidPrefix,
            pasteDetected: false,
            firstErrorIndex: firstError,
            accuracyPercentage: accuracy
        )
    }
    
    /// Generates mental arithmetic problems for Cognitive Math Challenge.
    public static func generateMathGauntlet(difficulty: ChallengeDifficulty) -> [MathProblem] {
        switch difficulty {
        case .easy:
            return [
                MathProblem(expression: "(18 × 4) + 27", expectedAnswer: 99),
                MathProblem(expression: "(64 ÷ 8) + 49", expectedAnswer: 57),
                MathProblem(expression: "(35 × 3) - 19", expectedAnswer: 86)
            ]
        case .medium:
            return [
                MathProblem(expression: "(27 × 6) - 48", expectedAnswer: 114),
                MathProblem(expression: "(43 × 5) + 67", expectedAnswer: 282),
                MathProblem(expression: "(144 ÷ 12) × 14", expectedAnswer: 168),
                MathProblem(expression: "(58 × 4) - 79", expectedAnswer: 153),
                MathProblem(expression: "(39 × 7) + 38", expectedAnswer: 311)
            ]
        case .brutal:
            return [
                MathProblem(expression: "(47 × 8) - 139", expectedAnswer: 237),
                MathProblem(expression: "(63 × 9) + 184", expectedAnswer: 751),
                MathProblem(expression: "(84 × 7) - 219", expectedAnswer: 369),
                MathProblem(expression: "(96 × 6) + 245", expectedAnswer: 821),
                MathProblem(expression: "(78 × 8) - 187", expectedAnswer: 437),
                MathProblem(expression: "(54 × 11) - 168", expectedAnswer: 426),
                MathProblem(expression: "(67 × 9) + 149", expectedAnswer: 752),
                MathProblem(expression: "(89 × 7) - 256", expectedAnswer: 367)
            ]
        }
    }
}
