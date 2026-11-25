import SwiftUI

public struct SquatsChallengeView: View {
    @StateObject private var detector: SquatMotionDetector
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    
    private let targetReps: Int
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    public init(difficulty: ChallengeDifficulty) {
        self.targetReps = difficulty.squatCount
        _detector = StateObject(wrappedValue: SquatMotionDetector(targetReps: difficulty.squatCount))
    }
    
    public var body: some View {
        VStack(spacing: 28) {
            // Header instructions
            VStack(spacing: 8) {
                Text("Physical Reset")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.warmAmber)
                    .textCase(.uppercase)
                    .tracking(2)
                
                Text("Break Screen Trance")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.textPrimary)
                
                Text("Place phone in pocket or hold firmly against your chest while performing full bodyweight squats.")
                    .font(.subheadline)
                    .foregroundColor(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            
            Spacer()
            
            // Circular Rep Counter
            ZStack {
                Circle()
                    .stroke(Theme.subtleBorder, lineWidth: 16)
                    .frame(width: 200, height: 200)
                
                Circle()
                    .trim(from: 0, to: CGFloat(detector.repCount) / CGFloat(targetReps))
                    .stroke(
                        LinearGradient(
                            colors: [Theme.electricEmerald, Theme.emeraldGlow],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 16, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 200, height: 200)
                    .animation(.easeInOut, value: detector.repCount)
                
                VStack(spacing: 4) {
                    Text("\(detector.repCount)")
                        .font(.system(size: 64, weight: .black, design: .rounded))
                        .foregroundColor(Theme.textPrimary)
                    
                    Text("of \(targetReps) reps")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(Theme.textMuted)
                }
            }
            
            // Motion Phase Badge
            VStack(spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "figure.run")
                        .foregroundColor(phaseColor)
                    
                    Text(detector.currentPhase.instructionText)
                        .font(.headline)
                        .foregroundColor(Theme.textPrimary)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Theme.elevatedSlate)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(phaseColor.opacity(0.5), lineWidth: 1)
                )
            }
            
            Spacer()
            
            // Actions
            VStack(spacing: 12) {
                #if DEBUG
                // Simulator testing button
                Button("Simulate 1 Rep (Testing)") {
                    detector.simulateRepetition()
                }
                .font(.footnote)
                .foregroundColor(Theme.textMuted)
                #endif
                
                Button("Cancel Challenge") {
                    detector.stop()
                    dismiss()
                }
                .foregroundColor(Theme.crimsonPulse)
                .font(.subheadline)
            }
            .padding(.bottom, 24)
        }
        .padding()
        .background(Theme.deepObsidian.ignoresSafeArea())
        .onAppear {
            detector.onRepCounted = { _ in
                hapticFeedback.impactOccurred()
            }
            detector.onChallengeCompleted = {
                hapticFeedback.impactOccurred()
                appState.completeBreakoutChallenge()
            }
            detector.start(targetReps: targetReps)
        }
        .onDisappear {
            detector.stop()
        }
    }
    
    private var phaseColor: Color {
        switch detector.currentPhase {
        case .ready: return Theme.electricEmerald
        case .descending: return Theme.warmAmber
        case .ascending: return Theme.royalIndigo
        case .completed: return Theme.electricEmerald
        }
    }
}
