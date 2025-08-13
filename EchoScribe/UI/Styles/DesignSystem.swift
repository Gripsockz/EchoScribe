import SwiftUI

// MARK: - Design System
struct DesignSystem {
    
    // MARK: - Colors
    struct Colors {
        // Primary Colors
        static let primary = Color.accentColor
        static let primaryLight = Color.accentColor.opacity(0.8)
        static let primaryDark = Color.accentColor.opacity(1.2)
        
        // Background Colors
        static let background = Color(NSColor.controlBackgroundColor)
        static let secondaryBackground = Color(NSColor.controlBackgroundColor)
        static let tertiaryBackground = Color(NSColor.controlBackgroundColor)
        
        // Text Colors
        static let primaryText = Color(NSColor.labelColor)
        static let secondaryText = Color(NSColor.secondaryLabelColor)
        static let tertiaryText = Color(NSColor.tertiaryLabelColor)
        
        // Status Colors
        static let success = Color.green
        static let warning = Color.orange
        static let error = Color.red
        static let info = Color.blue
        
        // Recording Colors
        static let recording = Color.red
        static let recordingPulse = Color.red.opacity(0.3)
        static let recordingBackground = Color.red.opacity(0.1)
        
        // Transcription Colors
        static let transcription = Color.green
        static let transcriptionPulse = Color.green.opacity(0.3)
        static let transcriptionBackground = Color.green.opacity(0.1)
        
        // Border Colors
        static let border = Color.secondary.opacity(0.2)
        static let borderLight = Color.secondary.opacity(0.1)
        static let borderDark = Color.secondary.opacity(0.3)
        
        // Shadow Colors
        static let shadow = Color.black.opacity(0.1)
        static let shadowLight = Color.black.opacity(0.05)
        static let shadowDark = Color.black.opacity(0.2)
    }
    
    // MARK: - Typography
    struct Typography {
        // Font Sizes
        static let largeTitle: CGFloat = 34
        static let title1: CGFloat = 28
        static let title2: CGFloat = 22
        static let title3: CGFloat = 20
        static let headline: CGFloat = 17
        static let body: CGFloat = 17
        static let callout: CGFloat = 16
        static let subheadline: CGFloat = 15
        static let footnote: CGFloat = 13
        static let caption1: CGFloat = 12
        static let caption2: CGFloat = 11
        
        // Font Weights
        static let regular = Font.Weight.regular
        static let medium = Font.Weight.medium
        static let semibold = Font.Weight.semibold
        static let bold = Font.Weight.bold
        
        // Font Styles
        static func largeTitle(_ weight: Font.Weight = .bold) -> Font {
            return .system(size: largeTitle, weight: weight, design: .default)
        }
        
        static func title1(_ weight: Font.Weight = .bold) -> Font {
            return .system(size: title1, weight: weight, design: .default)
        }
        
        static func title2(_ weight: Font.Weight = .semibold) -> Font {
            return .system(size: title2, weight: weight, design: .default)
        }
        
        static func title3(_ weight: Font.Weight = .semibold) -> Font {
            return .system(size: title3, weight: weight, design: .default)
        }
        
        static func headline(_ weight: Font.Weight = .semibold) -> Font {
            return .system(size: headline, weight: weight, design: .default)
        }
        
        static func body(_ weight: Font.Weight = .regular) -> Font {
            return .system(size: body, weight: weight, design: .default)
        }
        
        static func callout(_ weight: Font.Weight = .regular) -> Font {
            return .system(size: callout, weight: weight, design: .default)
        }
        
        static func subheadline(_ weight: Font.Weight = .medium) -> Font {
            return .system(size: subheadline, weight: weight, design: .default)
        }
        
        static func footnote(_ weight: Font.Weight = .regular) -> Font {
            return .system(size: footnote, weight: weight, design: .default)
        }
        
        static func caption1(_ weight: Font.Weight = .regular) -> Font {
            return .system(size: caption1, weight: weight, design: .default)
        }
        
        static func caption2(_ weight: Font.Weight = .regular) -> Font {
            return .system(size: caption2, weight: weight, design: .default)
        }
        
        // Monospace font for transcription
        static func monospace(_ size: CGFloat = 16) -> Font {
            return .system(size: size, weight: .regular, design: .monospaced)
        }
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
        static let xxxl: CGFloat = 64
        
        // Layout Spacing
        static let sectionSpacing: CGFloat = 24
        static let itemSpacing: CGFloat = 16
        static let buttonSpacing: CGFloat = 12
        static let textSpacing: CGFloat = 8
    }
    
    // MARK: - Corner Radius
    struct CornerRadius {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let round: CGFloat = 50
    }
    
    // MARK: - Shadows
    struct Shadows {
        static let small = Shadow(
            color: Colors.shadowLight,
            radius: 2,
            x: 0,
            y: 1
        )
        
        static let medium = Shadow(
            color: Colors.shadow,
            radius: 4,
            x: 0,
            y: 2
        )
        
        static let large = Shadow(
            color: Colors.shadowDark,
            radius: 8,
            x: 0,
            y: 4
        )
    }
    
    // MARK: - Animations
    struct Animations {
        static let quick = Animation.easeInOut(duration: 0.2)
        static let standard = Animation.easeInOut(duration: 0.3)
        static let slow = Animation.easeInOut(duration: 0.5)
        static let spring = Animation.spring(response: 0.3, dampingFraction: 0.6)
        static let bouncy = Animation.spring(response: 0.4, dampingFraction: 0.8)
    }
    
    // MARK: - Layout
    struct Layout {
        static let sidebarWidth: CGFloat = 280
        static let keyPointsWidth: CGFloat = 320
        static let minWindowWidth: CGFloat = 1200
        static let minWindowHeight: CGFloat = 800
        static let maxWindowWidth: CGFloat = 2000
        static let maxWindowHeight: CGFloat = 1400
    }
}

// MARK: - Shadow Helper
struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - View Modifiers
struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(DesignSystem.Colors.secondaryBackground)
            .cornerRadius(DesignSystem.CornerRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .stroke(DesignSystem.Colors.border, lineWidth: 1)
            )
            .shadow(
                color: DesignSystem.Shadows.small.color,
                radius: DesignSystem.Shadows.small.radius,
                x: DesignSystem.Shadows.small.x,
                y: DesignSystem.Shadows.small.y
            )
    }
}

struct ButtonStyle: ViewModifier {
    let isEnabled: Bool
    let color: Color
    
    init(isEnabled: Bool = true, color: Color = DesignSystem.Colors.primary) {
        self.isEnabled = isEnabled
        self.color = color
    }
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(isEnabled ? color : DesignSystem.Colors.tertiaryText)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                    .fill(isEnabled ? color.opacity(0.1) : DesignSystem.Colors.tertiaryBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                            .stroke(isEnabled ? color.opacity(0.3) : DesignSystem.Colors.border, lineWidth: 1)
                    )
            )
    }
}

// MARK: - View Extensions
extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
    
    func buttonStyle(isEnabled: Bool = true, color: Color = DesignSystem.Colors.primary) -> some View {
        modifier(ButtonStyle(isEnabled: isEnabled, color: color))
    }
    
    func standardPadding() -> some View {
        padding(DesignSystem.Spacing.md)
    }
    
    func sectionPadding() -> some View {
        padding(DesignSystem.Spacing.lg)
    }
}
