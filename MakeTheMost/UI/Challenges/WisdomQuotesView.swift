import SwiftUI

public struct WisdomQuotesView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    
    private let prompt: QuotePrompt
    @State private var userInput: String = ""
    @State private var previousInput: String = ""
    @State private var validationResult: TypingValidationResult? = nil
    @State private var pasteWarningVisible: Bool = false
    @FocusState private var isFieldFocused: Bool
    
    public init(difficulty: ChallengeDifficulty) {
        self.prompt = ProductivityQuoteLibrary.randomQuote(difficulty: difficulty)
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 6) {
                    Text(prompt.topic)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.warmAmber)
                        .textCase(.uppercase)
                        .tracking(2)
                    
                    Text("Wisdom & Discipline Reflection")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.textPrimary)
                }
                .padding(.top, 16)
                
                // Target Quote Box
                VStack(alignment: .leading, spacing: 12) {
                    Text("“\(prompt.text)”")
                        .font(.system(size: 17, weight: .medium, design: .serif))
                        .foregroundColor(Theme.textPrimary)
                        .lineSpacing(4)
                    
                    HStack {
                        Spacer()
                        Text("— \(prompt.fullReference)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(Theme.textMuted)
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Theme.elevatedSlate)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Theme.subtleBorder, lineWidth: 1)
                )
                
                // Anti-Paste Warning Alert
                if pasteWarningVisible {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(Theme.crimsonPulse)
                        Text("Please type the wisdom quote manually.")
                            .font(.caption)
                            .foregroundColor(Theme.crimsonPulse)
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity)
                    .background(Theme.crimsonPulse.opacity(0.15))
                    .cornerRadius(8)
                }
                
                // Typing Input Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Type quote to reflect:")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Theme.textMuted)
                    
                    TextEditor(text: $userInput)
                        .focused($isFieldFocused)
                        .frame(minHeight: 140)
                        .padding(12)
                        .background(Theme.frostedCard)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Theme.warmAmber.opacity(0.5), lineWidth: 1.5)
                        )
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .onChange(of: userInput) { newValue in
                            handleTypingChange(newValue)
                        }
                }
                
                Spacer(minLength: 20)
                
                Button("Cancel Challenge") {
                    dismiss()
                }
                .foregroundColor(Theme.crimsonPulse)
                .font(.subheadline)
                .padding(.bottom, 24)
            }
            .padding(.horizontal, 20)
        }
        .background(Theme.deepObsidian.ignoresSafeArea())
        .onAppear {
            isFieldFocused = true
        }
    }
    
    private func handleTypingChange(_ newValue: String) {
        let result = ChallengeEngine.validateTyping(
            targetText: prompt.text,
            previousInput: previousInput,
            newInput: newValue
        )
        
        self.validationResult = result
        self.pasteWarningVisible = result.pasteDetected
        
        if result.pasteDetected {
            self.userInput = previousInput
            return
        }
        
        self.previousInput = newValue
        
        if result.isComplete {
            isFieldFocused = false
            appState.completeBreakoutChallenge()
        }
    }
}
