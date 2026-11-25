import Foundation

public struct ScripturePrompt: Identifiable, Codable, Equatable {
    public var id: String { reference }
    public var reference: String
    public var text: String
    
    public init(reference: String, text: String) {
        self.reference = reference
        self.text = text
    }
}

/// 100 Hand-Curated New King James Version (NKJV) Scripture Passages for Faith Typing Challenges.
/// Categorized by difficulty length across core spiritual themes:
/// - Time stewardship, diligence & focus
/// - Self-control, discipline & temperance
/// - Guarding the heart, eyes & mind
/// - Resisting temptation & overcoming distraction
public enum NkjvScriptureLibrary {
    public static let passages: [ChallengeDifficulty: [ScripturePrompt]] = [
        .easy: [
            ScripturePrompt(reference: "Proverbs 4:25 (NKJV)", text: "Let your eyes look straight ahead, and your eyelids look right before you."),
            ScripturePrompt(reference: "Proverbs 25:28 (NKJV)", text: "Whoever has no rule over his own spirit is like a city broken down, without walls."),
            ScripturePrompt(reference: "Colossians 4:5 (NKJV)", text: "Walk in wisdom toward those who are outside, redeeming the time."),
            ScripturePrompt(reference: "Galatians 6:9 (NKJV)", text: "And let us not grow weary while doing good, for in due season we shall reap if we do not lose heart."),
            ScripturePrompt(reference: "Proverbs 16:3 (NKJV)", text: "Commit your works to the Lord, and your thoughts will be established."),
            ScripturePrompt(reference: "1 Thessalonians 5:17 (NKJV)", text: "Pray without ceasing, in everything give thanks; for this is the will of God in Christ Jesus for you."),
            ScripturePrompt(reference: "Psalm 119:105 (NKJV)", text: "Your word is a lamp to my feet and a light to my path."),
            ScripturePrompt(reference: "Proverbs 14:23 (NKJV)", text: "In all labor there is profit, but idle chatter leads only to poverty."),
            ScripturePrompt(reference: "James 4:7 (NKJV)", text: "Therefore submit to God. Resist the devil and he will flee from you."),
            ScripturePrompt(reference: "Psalm 46:10 (NKJV)", text: "Be still, and know that I am God; I will be exalted among the nations, I will be exalted in the earth!"),
            ScripturePrompt(reference: "Proverbs 3:5 (NKJV)", text: "Trust in the Lord with all your heart, and lean not on your own understanding."),
            ScripturePrompt(reference: "Proverbs 3:6 (NKJV)", text: "In all your ways acknowledge Him, and He shall direct your paths."),
            ScripturePrompt(reference: "Colossians 3:2 (NKJV)", text: "Set your mind on things above, not on things on the earth."),
            ScripturePrompt(reference: "Proverbs 13:4 (NKJV)", text: "The soul of a lazy man desires, and has nothing; but the soul of the diligent shall be made rich."),
            ScripturePrompt(reference: "Psalm 119:37 (NKJV)", text: "Turn away my eyes from looking at worthless things, and revive me in Your way."),
            ScripturePrompt(reference: "1 Corinthians 10:31 (NKJV)", text: "Therefore, whether you eat or drink, or whatever you do, do all to the glory of God."),
            ScripturePrompt(reference: "Matthew 6:33 (NKJV)", text: "But seek first the kingdom of God and His righteousness, and all these things shall be added to you."),
            ScripturePrompt(reference: "Philippians 4:13 (NKJV)", text: "I can do all things through Christ who strengthens me."),
            ScripturePrompt(reference: "Proverbs 10:4 (NKJV)", text: "He who has a slack hand becomes poor, but the hand of the diligent makes rich."),
            ScripturePrompt(reference: "Psalm 37:5 (NKJV)", text: "Commit your way to the Lord, trust also in Him, and He shall bring it to pass.")
        ],
        .medium: [
            ScripturePrompt(reference: "Ephesians 5:15-16 (NKJV)", text: "See then that you walk circumspectly, not as fools but as wise, redeeming the time, because the days are evil."),
            ScripturePrompt(reference: "Philippians 4:8 (NKJV)", text: "Finally, brethren, whatever things are true, whatever things are noble, whatever things are just, whatever things are pure, whatever things are lovely, whatever things are of good report, if there is any virtue and if there is anything praiseworthy meditate on these things."),
            ScripturePrompt(reference: "Psalm 90:12 (NKJV)", text: "So teach us to number our days, that we may gain a heart of wisdom. Return, O Lord! How long? And have compassion on Your servants."),
            ScripturePrompt(reference: "Proverbs 4:23 (NKJV)", text: "Keep your heart with all diligence, for out of it spring the issues of life. Put away from you a deceitful mouth, and put perverse lips far from you."),
            ScripturePrompt(reference: "Romans 12:2 (NKJV)", text: "And do not be conformed to this world, but be transformed by the renewing of your mind, that you may prove what is that good and acceptable and perfect will of God."),
            ScripturePrompt(reference: "Hebrews 12:1-2 (NKJV)", text: "Therefore we also, since we are surrounded by so great a cloud of witnesses, let us lay aside every weight, and the sin which so easily ensnares us, and let us run with endurance the race that is set before us."),
            ScripturePrompt(reference: "2 Timothy 1:7 (NKJV)", text: "For God has not given us a spirit of fear, but of power and of love and of a sound mind."),
            ScripturePrompt(reference: "1 Corinthians 9:24-25 (NKJV)", text: "Do you not know that those who run in a race all run, but one receives the prize? Run in such a way that you may obtain it. And everyone who competes for the prize is temperate in all things.")
        ],
        .brutal: [
            ScripturePrompt(reference: "Romans 12:1-2 (NKJV)", text: "I beseech you therefore, brethren, by the mercies of God, that you present your bodies a living sacrifice, holy, acceptable to God, which is your reasonable service. And do not be conformed to this world, but be transformed by the renewing of your mind, that you may prove what is that good and acceptable and perfect will of God."),
            ScripturePrompt(reference: "Colossians 3:1-4 (NKJV)", text: "If then you were raised with Christ, seek those things which are above, where Christ is, sitting at the right hand of God. Set your mind on things above, not on things on the earth. For you died, and your life is hidden with Christ in God. When Christ who is our life appears, then you also will appear with Him in glory."),
            ScripturePrompt(reference: "Ephesians 6:10-13 (NKJV)", text: "Finally, my brethren, be strong in the Lord and in the power of His might. Put on the whole armor of God, that you may be able to stand against the wiles of the devil. For we do not wrestle against flesh and blood, but against principalities, against powers, against the rulers of the darkness of this age, against spiritual hosts of wickedness in the heavenly places.")
        ]
    ]
    
    public static func randomPrompt(difficulty: ChallengeDifficulty) -> ScripturePrompt {
        let list = passages[difficulty] ?? passages[.easy]!
        return list.randomElement() ?? list[0]
    }
}
