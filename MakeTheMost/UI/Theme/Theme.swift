import SwiftUI

/// Shared UI Color tokens matching Android Compose theme
public enum Theme {
    // Dark Theme Palette
    public static let deepObsidian = Color(hex: 0x090A0F)
    public static let elevatedSlate = Color(hex: 0x12151E)
    public static let frostedCard = Color(hex: 0x191D2A)
    public static let subtleBorder = Color(hex: 0x282E42)
    public static let electricEmerald = Color(hex: 0x10B981)
    public static let emeraldGlow = Color(hex: 0x059669)
    public static let warmAmber = Color(hex: 0xF59E0B)
    public static let crimsonPulse = Color(hex: 0xEF4444)
    public static let royalIndigo = Color(hex: 0x6366F1)
    
    // Typography
    public static let textPrimary = Color(hex: 0xFFFFFF)
    public static let textSecondary = Color(hex: 0xCBD5E1)
    public static let textMuted = Color(hex: 0x94A3B8)
    
    // Status & Badges
    public static let alertSuccessBg = Color(hex: 0x10B981).opacity(0.15)
    public static let alertSuccessText = Color(hex: 0x34D399)
    public static let alertWarningBg = Color(hex: 0xF59E0B).opacity(0.15)
    public static let alertWarningText = Color(hex: 0xFBBF24)
}

extension Color {
    public init(hex: UInt32, alpha: Double = 1.0) {
        let red = Double((hex >> 16) & 0xFF) / 255.0
        let green = Double((hex >> 8) & 0xFF) / 255.0
        let blue = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
}

// MARK: - Reusable View Modifiers

public struct CardBackgroundModifier: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .background(Theme.frostedCard)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Theme.subtleBorder, lineWidth: 1)
            )
    }
}

public struct PrimaryButtonModifier: ViewModifier {
    public var isEnabled: Bool = true
    
    public func body(content: Content) -> some View {
        content
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(Color(hex: 0x032218))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(isEnabled ? Theme.electricEmerald : Theme.textMuted.opacity(0.3))
            .cornerRadius(12)
            .shadow(color: isEnabled ? Theme.electricEmerald.opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
    }
}

public extension View {
    func frostedCardStyle() -> some View {
        modifier(CardBackgroundModifier())
    }
    
    func primaryButtonStyle(isEnabled: Bool = true) -> some View {
        modifier(PrimaryButtonModifier(isEnabled: isEnabled))
    }
}
