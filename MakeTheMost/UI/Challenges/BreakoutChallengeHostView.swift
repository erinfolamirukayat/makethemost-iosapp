import SwiftUI

public struct BreakoutChallengeHostView: View {
    public let category: ChallengeCategory
    public let difficulty: ChallengeDifficulty
    
    public var body: some View {
        NavigationView {
            Group {
                switch category {
                case .physicalSquats:
                    SquatsChallengeView(difficulty: difficulty)
                case .faithScripture:
                    ScriptureTypingView(difficulty: difficulty)
                case .productivityQuotes:
                    WisdomQuotesView(difficulty: difficulty)
                case .cognitiveMath:
                    MathChallengeView(difficulty: difficulty)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 6) {
                        Image(systemName: category.sfSymbol)
                            .foregroundColor(Theme.electricEmerald)
                        Text(category.displayName)
                            .font(.headline)
                            .foregroundColor(Theme.textPrimary)
                    }
                }
            }
        }
    }
}
