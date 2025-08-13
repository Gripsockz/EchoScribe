import SwiftUI

// MARK: - View Extensions
extension View {
    
    // MARK: - Conditional Modifiers
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    @ViewBuilder
    func `if`<TrueContent: View, FalseContent: View>(
        _ condition: Bool,
        if ifTransform: (Self) -> TrueContent,
        else elseTransform: (Self) -> FalseContent
    ) -> some View {
        if condition {
            ifTransform(self)
        } else {
            elseTransform(self)
        }
    }
    
    // MARK: - Background Modifiers
    func backgroundCard() -> some View {
        self
            .background(DesignSystem.Colors.secondaryBackground)
            .cornerRadius(DesignSystem.CornerRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .stroke(DesignSystem.Colors.border, lineWidth: 1)
            )
    }
    
    func backgroundCard(color: Color) -> some View {
        self
            .background(color)
            .cornerRadius(DesignSystem.CornerRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .stroke(DesignSystem.Colors.border, lineWidth: 1)
            )
    }
    
    // MARK: - Shadow Modifiers
    func shadowSmall() -> some View {
        self.shadow(
            color: DesignSystem.Shadows.small.color,
            radius: DesignSystem.Shadows.small.radius,
            x: DesignSystem.Shadows.small.x,
            y: DesignSystem.Shadows.small.y
        )
    }
    
    func shadowMedium() -> some View {
        self.shadow(
            color: DesignSystem.Shadows.medium.color,
            radius: DesignSystem.Shadows.medium.radius,
            x: DesignSystem.Shadows.medium.x,
            y: DesignSystem.Shadows.medium.y
        )
    }
    
    func shadowLarge() -> some View {
        self.shadow(
            color: DesignSystem.Shadows.large.color,
            radius: DesignSystem.Shadows.large.radius,
            x: DesignSystem.Shadows.large.x,
            y: DesignSystem.Shadows.large.y
        )
    }
    
    // MARK: - Animation Modifiers
    func animateQuick() -> some View {
        self.animation(DesignSystem.Animations.quick, value: true)
    }
    
    func animateStandard() -> some View {
        self.animation(DesignSystem.Animations.standard, value: true)
    }
    
    func animateSlow() -> some View {
        self.animation(DesignSystem.Animations.slow, value: true)
    }
    
    func animateSpring() -> some View {
        self.animation(DesignSystem.Animations.spring, value: true)
    }
    
    func animateBouncy() -> some View {
        self.animation(DesignSystem.Animations.bouncy, value: true)
    }
    
    // MARK: - Layout Modifiers
    func centerInParent() -> some View {
        self.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    func centerHorizontally() -> some View {
        self.frame(maxWidth: .infinity)
    }
    
    func centerVertically() -> some View {
        self.frame(maxHeight: .infinity)
    }
    
    // MARK: - Size Modifiers
    func square(_ size: CGFloat) -> some View {
        self.frame(width: size, height: size)
    }
    
    func minWidth(_ width: CGFloat) -> some View {
        self.frame(minWidth: width)
    }
    
    func maxWidth(_ width: CGFloat) -> some View {
        self.frame(maxWidth: width)
    }
    
    func minHeight(_ height: CGFloat) -> some View {
        self.frame(minHeight: height)
    }
    
    func maxHeight(_ height: CGFloat) -> some View {
        self.frame(maxHeight: height)
    }
    
    // MARK: - Opacity Modifiers
    func opacityIf(_ condition: Bool, opacity: Double = 0.5) -> some View {
        self.opacity(condition ? 1.0 : opacity)
    }
    
    // MARK: - Scale Modifiers
    func scaleIf(_ condition: Bool, scale: CGFloat = 0.95) -> some View {
        self.scaleEffect(condition ? 1.0 : scale)
    }
    
    // MARK: - Offset Modifiers
    func offsetIf(_ condition: Bool, offset: CGSize) -> some View {
        self.offset(condition ? .zero : offset)
    }
    
    // MARK: - Rotation Modifiers
    func rotateIf(_ condition: Bool, angle: Angle) -> some View {
        self.rotationEffect(condition ? .zero : angle)
    }
    
    // MARK: - Blur Modifiers
    func blurIf(_ condition: Bool, radius: CGFloat = 2) -> some View {
        self.blur(radius: condition ? 0 : radius)
    }
    
    // MARK: - Brightness Modifiers
    func brightnessIf(_ condition: Bool, brightness: Double = -0.1) -> some View {
        self.brightness(condition ? 0 : brightness)
    }
    
    // MARK: - Contrast Modifiers
    func contrastIf(_ condition: Bool, contrast: Double = 0.9) -> some View {
        self.contrast(condition ? 1.0 : contrast)
    }
    
    // MARK: - Saturation Modifiers
    func saturationIf(_ condition: Bool, saturation: Double = 0.8) -> some View {
        self.saturation(condition ? 1.0 : saturation)
    }
    
    // MARK: - Grayscale Modifiers
    func grayscaleIf(_ condition: Bool, intensity: Double = 0.3) -> some View {
        self.grayscale(condition ? 0 : intensity)
    }
    
    // MARK: - Hue Rotation Modifiers
    func hueRotationIf(_ condition: Bool, angle: Angle) -> some View {
        self.hueRotation(condition ? .zero : angle)
    }
    
    // MARK: - Color Invert Modifiers
    func colorInvertIf(_ condition: Bool) -> some View {
        Group {
            if condition {
                self.colorInvert()
            } else {
                self
            }
        }
    }
    
    // MARK: - Color Multiply Modifiers
    func colorMultiplyIf(_ condition: Bool, color: Color) -> some View {
        self.colorMultiply(condition ? .clear : color)
    }
    
    // MARK: - Composed Modifiers
    func disabledStyle(_ disabled: Bool) -> some View {
        self
            .opacityIf(!disabled, opacity: 0.5)
            .scaleIf(!disabled, scale: 0.98)
            .brightnessIf(!disabled, brightness: -0.05)
    }
    
    func pressedStyle(_ pressed: Bool) -> some View {
        self
            .scaleIf(!pressed, scale: 0.95)
            .brightnessIf(!pressed, brightness: -0.1)
    }
    
    func loadingStyle(_ loading: Bool) -> some View {
        self
            .opacityIf(!loading, opacity: 0.7)
            .blurIf(!loading, radius: 1)
    }
    
    func errorStyle(_ hasError: Bool) -> some View {
        self
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                    .stroke(hasError ? DesignSystem.Colors.error : Color.clear, lineWidth: 2)
            )
    }
    
    func successStyle(_ isSuccess: Bool) -> some View {
        self
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                    .stroke(isSuccess ? DesignSystem.Colors.success : Color.clear, lineWidth: 2)
            )
    }
    
    // MARK: - Accessibility Modifiers
    func accessibilityLabel(_ label: String) -> some View {
        self.accessibilityLabel(Text(label))
    }
    
    func accessibilityHint(_ hint: String) -> some View {
        self.accessibilityHint(Text(hint))
    }
    
    func accessibilityValue(_ value: String) -> some View {
        self.accessibilityValue(Text(value))
    }
    

    
    // MARK: - Help Modifiers
    func helpText(_ text: String) -> some View {
        self.help(text)
    }
    
    // MARK: - Hidden Modifiers
    func hiddenIf(_ condition: Bool) -> some View {
        Group {
            if condition {
                self.hidden()
            } else {
                self
            }
        }
    }
    
    // MARK: - Clipped Modifiers
    func clippedIf(_ condition: Bool) -> some View {
        Group {
            if condition {
                self.clipped()
            } else {
                self
            }
        }
    }
    
    // MARK: - Mask Modifiers
    func maskIf<Mask: View>(_ condition: Bool, @ViewBuilder mask: () -> Mask) -> some View {
        self.mask(condition ? mask() : nil)
    }
    
    // MARK: - Composable Modifiers
    func compose<M: ViewModifier>(_ modifier: M) -> some View {
        self.modifier(modifier)
    }
    
    func compose<M1: ViewModifier, M2: ViewModifier>(_ m1: M1, _ m2: M2) -> some View {
        self.modifier(m1).modifier(m2)
    }
    
    func compose<M1: ViewModifier, M2: ViewModifier, M3: ViewModifier>(_ m1: M1, _ m2: M2, _ m3: M3) -> some View {
        self.modifier(m1).modifier(m2).modifier(m3)
    }
}
