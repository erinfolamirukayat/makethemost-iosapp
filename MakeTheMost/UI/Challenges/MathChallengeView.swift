import SwiftUI

public struct MathChallengeView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    
    private let problems: [MathProblem]
    @State private var currentIndex: Int = 0
    @State private var userStreak: Int = 0
    @State private var answerInput: String = ""
    @State private var errorMessage: String? = nil
    @FocusState private var isFieldFocused: Bool
    
    private let hapticFeedback = UINotificationFeedbackGenerator()
    
    public init(difficulty: ChallengeDifficulty) {
        self.problems = ChallengeEngine.generateMathGauntlet(difficulty: difficulty)
    }
    
    public var body: some View {
        VStack(spacing: 28) {
            // Header
            VStack(spacing: 6) {
                Text("Cognitive Mental Friction")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.royalIndigo)
                    .textCase(.uppercase)
                    .tracking(2)
                
                Text("Solve Mental Math")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.textPrimary)
                
                Text("One wrong answer resets your streak to 0.")
                    .font(.subheadline)
                    .foregroundColor(Theme.textMuted)
            }
            .padding(.top, 16)
            
            // Streak Progress
            HStack(spacing: 8) {
                ForEach(0..<problems.count, id: \.self) { idx in
                    Circle()
                        .fill(idx < userStreak ? Theme.electricEmerald : Theme.subtleBorder)
                        .frame(width: 14, height: 14)
                }
            }
            
            Spacer()
            
            // Math Card
            VStack(spacing: 16) {
                Text(currentProblem.expression)
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.textPrimary)
                
                Text("= ?")
                    .font(.title3)
                    .foregroundColor(Theme.textMuted)
                
                TextField("Your answer", text: $answerInput)
                    .focused($isFieldFocused)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .padding(.vertical, 12)
                    .frame(maxWidth: 180)
                    .background(Theme.elevatedSlate)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Theme.royalIndigo, lineWidth: 1.5)
                    )
            }
            .padding(32)
            .frame(maxWidth: .infinity)
            .frostedCardStyle()
            
            if let error = errorMessage {
                Text(error)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.crimsonPulse)
            }
            
            Spacer()
            
            // Submit Button
            Button(action: submitAnswer) {
                Text("Submit Answer")
                    .primaryButtonStyle(isEnabled: !answerInput.isEmpty)
            }
            .disabled(answerInput.isEmpty)
            
            Button("Cancel Challenge") {
                dismiss()
            }
            .foregroundColor(Theme.crimsonPulse)
            .font(.subheadline)
            .padding(.bottom, 24)
        }
        .padding(.horizontal, 24)
        .background(Theme.deepObsidian.ignoresSafeArea())
        .onAppear {
            isFieldFocused = true
        }
    }
    
    private var currentProblem: MathProblem {
        problems[min(currentIndex, problems.count - 1)]
    }
    
    private func submitAnswer() {
        guard let entered = Int(answerInput.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            return
        }
        
        if entered == currentProblem.expectedAnswer {
            // Correct answer
            hapticFeedback.notificationOccurred(.success)
            errorMessage = nil
            answerInput = ""
            userStreak += 1
            
            if userStreak >= problems.count {
                // Completed entire streak!
                appState.completeBreakoutChallenge()
            } else {
                currentIndex = (currentIndex + 1) % problems.count
            }
        } else {
            // Wrong answer -> reset streak
            hapticFeedback.notificationOccurred(.error)
            errorMessage = "Incorrect! Streak reset to 0."
            userStreak = 0
            answerInput = ""
        }
    }
}
