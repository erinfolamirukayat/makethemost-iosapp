import SwiftUI

public struct ScriptureTypingView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    
    private let prompt: ScripturePrompt
    @State private var userInput: String = ""
    @State private var previousInput: String = ""
    @State private var validationResult: TypingValidationResult? = nil
    @State private var pasteWarningVisible: Bool = false
    @FocusState private var isFieldFocused: Bool
    
    public init(difficulty: ChallengeDifficulty) {
        self.prompt = NkjvScriptureLibrary.randomPrompt(difficulty: difficulty)
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 6) {
                    Text("Faith & Scripture Typing")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.electricEmerald)
                        .textCase(.uppercase)
                        .tracking(2)
                    
                    Text(prompt.reference)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.textPrimary)
                }
                .padding(.top, 16)
                
                // Target Scripture Box
                VStack(alignment: .leading, spacing: 12) {
                    Text("Target Scripture:")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Theme.textMuted)
                    
                    Text(prompt.text)
                        .font(.system(size: 17, weight: .medium, design: .serif))
                        .foregroundColor(Theme.textSecondary)
                        .lineSpacing(4)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Theme.elevatedSlate)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Theme.subtleBorder, lineWidth: 1)
                )
                
                // Live Progress & Accuracy Bar
                HStack {
                    Text("Accuracy: \(validationResult?.accuracyPercentage ?? 0)%")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.electricEmerald)
                    
                    Spacer()
                    
                    Text("\(userInput.count) / \(prompt.text.count) characters")
                        .font(.caption)
                        .foregroundColor(Theme.textMuted)
                }
                
                // Anti-Paste Warning Alert
                if pasteWarningVisible {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(Theme.crimsonPulse)
                        Text("Clipboard paste & autocomplete bursts blocked! Please type each letter manually.")
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
                    Text("Type passage exactly:")
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
                                .stroke(inputBorderColor, lineWidth: 1.5)
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
    
    private var inputBorderColor: Color {
        guard let res = validationResult else { return Theme.subtleBorder }
        if res.pasteDetected { return Theme.crimsonPulse }
        if !res.isValidPrefix { return Theme.crimsonPulse }
        if res.isComplete { return Theme.electricEmerald }
        return Theme.electricEmerald.opacity(0.6)
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
            // Revert back to previous valid input
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
