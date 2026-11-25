import Foundation

public struct QuotePrompt: Identifiable, Codable, Equatable {
    public var id: String { "\(author)_\(text.prefix(20))" }
    public var author: String
    public var sourceOrRole: String
    public var topic: String
    public var text: String
    
    public init(author: String, sourceOrRole: String, topic: String, text: String) {
        self.author = author
        self.sourceOrRole = sourceOrRole
        self.topic = topic
        self.text = text
    }
    
    public var fullReference: String {
        sourceOrRole.isEmpty ? author : "\(author) (\(sourceOrRole))"
    }
}

/// Curated Library of Productivity, Focus, and Discipline Quotes.
/// Categorized by difficulty length across core focus themes:
/// - Deep Work & Distraction Resistance
/// - Consistency & Systems
/// - Action & Overcoming Procrastination
/// - Mental Toughness & Stoic Discipline
public enum ProductivityQuoteLibrary {
    public static let quotes: [ChallengeDifficulty: [QuotePrompt]] = [
        .easy: [
            QuotePrompt(
                author: "James Clear",
                sourceOrRole: "Atomic Habits",
                topic: "Habits & Systems",
                text: "You do not rise to the level of your goals. You fall to the level of your systems."
            ),
            QuotePrompt(
                author: "Marcus Aurelius",
                sourceOrRole: "Meditations",
                topic: "Essentialism",
                text: "Ask yourself at every moment, Is this necessary?"
            ),
            QuotePrompt(
                author: "Cal Newport",
                sourceOrRole: "Deep Work",
                topic: "Focus",
                text: "Clarity about what matters provides clarity about what does not."
            ),
            QuotePrompt(
                author: "Seneca",
                sourceOrRole: "On the Shortness of Life",
                topic: "Time Stewardship",
                text: "It is not that we have a short time to live, but that we waste a lot of it."
            ),
            QuotePrompt(
                author: "Epictetus",
                sourceOrRole: "Discourses",
                topic: "Self-Discipline",
                text: "No man is free who is not master of himself."
            ),
            QuotePrompt(
                author: "Derek Sivers",
                sourceOrRole: "Anything You Want",
                topic: "Essentialism",
                text: "If it is not a definite yes, then it is a no."
            ),
            QuotePrompt(
                author: "Tim Ferriss",
                sourceOrRole: "The 4-Hour Workweek",
                topic: "Action",
                text: "Focus on being productive instead of busy."
            )
        ],
        .medium: [
            QuotePrompt(
                author: "Cal Newport",
                sourceOrRole: "Deep Work",
                topic: "Distraction Resistance",
                text: "If you do not produce, you will not thrive. To produce, you must master the art of deep, uninterrupted focus in a world designed to fragment your attention."
            ),
            QuotePrompt(
                author: "Marcus Aurelius",
                sourceOrRole: "Meditations",
                topic: "Presence & Purpose",
                text: "Concentrate every minute like a Roman—like a man—on doing what is in front of you with precise and genuine seriousness, tenderly, willingly, with justice."
            ),
            QuotePrompt(
                author: "Steven Pressfield",
                sourceOrRole: "The War of Art",
                topic: "Overcoming Resistance",
                text: "The most important thing about art is work. Nothing else matters except sitting down every day and trying. Resistance will always flee before relentless dedication."
            ),
            QuotePrompt(
                author: "James Clear",
                sourceOrRole: "Atomic Habits",
                topic: "Identity & Focus",
                text: "Every action you take is a vote for the type of person you wish to become. No single instance will transform your beliefs, but as the votes build up, so does the evidence of your new identity."
            )
        ],
        .brutal: [
            QuotePrompt(
                author: "Seneca",
                sourceOrRole: "Letters from a Stoic",
                topic: "Mastery of Time",
                text: "Hold every hour in your grasp. Lay hold of today's task, and you will not need to depend so much upon tomorrow's. While we are postponing, life speeds by. Nothing is ours, Lucilius, except time; we were entrusted by nature with the ownership of this single fleeting and slippery resource."
            ),
            QuotePrompt(
                author: "Cal Newport",
                sourceOrRole: "Digital Minimalism",
                topic: "Digital Intentionality",
                text: "Digital minimalists see new technologies as tools to be used to support things they deeply value—not as sources of value themselves. They do not accept the idea that offering some value is justification for using a service; instead, they extract the signal and ruthlessly discard the noise."
            )
        ]
    ]
    
    public static func randomQuote(difficulty: ChallengeDifficulty) -> QuotePrompt {
        let list = quotes[difficulty] ?? quotes[.easy]!
        return list.randomElement() ?? list[0]
    }
}
