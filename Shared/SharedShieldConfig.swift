import Foundation

/// Lightweight data payload shared with ShieldConfigurationExtension and ShieldActionExtension.
public struct SharedShieldConfig: Codable {
    public var title: String
    public var scriptureText: String
    public var scriptureReference: String
    public var swapAppButtonTitle: String
    public var swapAppUrlScheme: String
    public var challengeButtonTitle: String
    
    public init(
        title: String = "Take a Breath",
        scriptureText: String = "Look carefully then how you walk, not as unwise but as wise, making the best use of the time.",
        scriptureReference: String = "Ephesians 5:15-16",
        swapAppButtonTitle: String = "Open Bible App",
        swapAppUrlScheme: String = "youversion://",
        challengeButtonTitle: String = "Breakout Challenge"
    ) {
        self.title = title
        self.scriptureText = scriptureText
        self.scriptureReference = scriptureReference
        self.swapAppButtonTitle = swapAppButtonTitle
        self.swapAppUrlScheme = swapAppUrlScheme
        self.challengeButtonTitle = challengeButtonTitle
    }
}
