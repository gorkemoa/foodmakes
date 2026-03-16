import SwiftUI

// MARK: - Color Palette
extension Color {
    // Warm food palette — muted terracotta, clean neutrals
    static let warmOrange     = Color(red: 0.82, green: 0.33, blue: 0.19)   // terracotta
    static let warmOrangeLight = Color(red: 0.93, green: 0.60, blue: 0.44)
    static let warmRed        = Color(red: 0.87, green: 0.24, blue: 0.14)
    static let warmCream      = Color(red: 0.99, green: 0.97, blue: 0.94)
    static let warmSand       = Color(red: 0.95, green: 0.91, blue: 0.85)
    static let warmGold       = Color(red: 0.80, green: 0.62, blue: 0.26)
    static let warmAmber      = Color(red: 0.88, green: 0.70, blue: 0.22)
    static let deepBrown      = Color(red: 0.18, green: 0.12, blue: 0.08)
    static let cardBg         = Color(red: 0.11, green: 0.08, blue: 0.06)

    // Surface colors
    static let surfacePrimary = Color(.systemBackground)
    static let surfaceSecondary = Color(.secondarySystemBackground)
    static let surfaceTertiary = Color(.tertiarySystemBackground)

    // Semantic
    static let tryGreen = Color(red: 0.17, green: 0.80, blue: 0.44)
    static let dislikeRed = Color(red: 0.98, green: 0.30, blue: 0.30)
    static let textPrimary = Color(.label)
    static let textSecondary = Color(.secondaryLabel)
    static let textTertiary = Color(.tertiaryLabel)
}

// MARK: - ShapeStyle dot-syntax forwarding
extension ShapeStyle where Self == Color {
    static var warmOrange: Color      { .warmOrange }
    static var warmOrangeLight: Color { .warmOrangeLight }
    static var warmRed: Color         { .warmRed }
    static var warmCream: Color       { .warmCream }
    static var warmSand: Color        { .warmSand }
    static var warmGold: Color        { .warmGold }
    static var warmAmber: Color       { .warmAmber }
    static var deepBrown: Color       { .deepBrown }
    static var cardBg: Color          { .cardBg }
    static var surfacePrimary: Color    { .surfacePrimary }
    static var surfaceSecondary: Color  { .surfaceSecondary }
    static var surfaceTertiary: Color   { .surfaceTertiary }
    static var tryGreen: Color          { .tryGreen }
    static var dislikeRed: Color        { .dislikeRed }
    static var textPrimary: Color       { .textPrimary }
    static var textSecondary: Color     { .textSecondary }
    static var textTertiary: Color      { .textTertiary }
}

// MARK: - Typography
struct AppFont {
    // Display
    static func displayLarge(_ weight: Font.Weight = .bold) -> Font {
        .system(size: 34, weight: weight, design: .rounded)
    }
    static func displayMedium(_ weight: Font.Weight = .bold) -> Font {
        .system(size: 28, weight: weight, design: .rounded)
    }
    static func displaySmall(_ weight: Font.Weight = .semibold) -> Font {
        .system(size: 22, weight: weight, design: .rounded)
    }

    // Headline
    static func headlineLarge(_ weight: Font.Weight = .semibold) -> Font {
        .system(size: 20, weight: weight, design: .rounded)
    }
    static func headlineMedium(_ weight: Font.Weight = .semibold) -> Font {
        .system(size: 17, weight: weight, design: .rounded)
    }
    static func headlineSmall(_ weight: Font.Weight = .medium) -> Font {
        .system(size: 15, weight: weight, design: .rounded)
    }

    // Body
    static func bodyLarge(_ weight: Font.Weight = .regular) -> Font {
        .system(size: 17, weight: weight, design: .default)
    }
    static func bodyMedium(_ weight: Font.Weight = .regular) -> Font {
        .system(size: 15, weight: weight, design: .default)
    }
    static func bodySmall(_ weight: Font.Weight = .regular) -> Font {
        .system(size: 13, weight: weight, design: .default)
    }

    // Caption
    static func caption(_ weight: Font.Weight = .medium) -> Font {
        .system(size: 12, weight: weight, design: .rounded)
    }
    static func captionSmall(_ weight: Font.Weight = .medium) -> Font {
        .system(size: 10, weight: weight, design: .rounded)
    }

    // Label
    static func label(_ weight: Font.Weight = .semibold) -> Font {
        .system(size: 11, weight: weight, design: .rounded)
    }
}

// MARK: - Spacing
struct AppSpacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
    static let xxxl: CGFloat = 64
}

// MARK: - Corner Radius
struct AppRadius {
    static let xs: CGFloat = 6
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let pill: CGFloat = 100
    static let card: CGFloat = 28
}

// MARK: - Shadow
struct AppShadow {
    static let cardSoft   = ShadowConfig(color: .black.opacity(0.07), radius: 14, x: 0, y: 4)
    static let cardMedium = ShadowConfig(color: .black.opacity(0.10), radius: 22, x: 0, y: 8)
    static let cardStrong = ShadowConfig(color: .black.opacity(0.14), radius: 32, x: 0, y: 12)
    static let button     = ShadowConfig(color: Color.warmOrange.opacity(0.25), radius: 12, x: 0, y: 5)
    static let glow       = ShadowConfig(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 3)
    static let tab        = ShadowConfig(color: .black.opacity(0.06), radius: 16, x: 0, y: -4)
}

struct ShadowConfig {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - View Extensions
extension View {
    func appShadow(_ shadow: ShadowConfig) -> some View {
        self.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }

    func cardStyle(radius: CGFloat = AppRadius.card) -> some View {
        self
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .appShadow(AppShadow.cardSoft)
    }

    /// Clean white card surface (replaces glass morphism)
    func cleanCard(radius: CGFloat = AppRadius.md) -> some View {
        self
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .appShadow(AppShadow.cardSoft)
    }
}

// MARK: - Gradients
struct AppGradient {
    // Card image overlays
    static var cardOverlay: LinearGradient {
        LinearGradient(
            stops: [
                .init(color: .clear, location: 0),
                .init(color: .black.opacity(0.08), location: 0.45),
                .init(color: .black.opacity(0.72), location: 1)
            ],
            startPoint: .top, endPoint: .bottom
        )
    }

    static var cardOverlayStrong: LinearGradient {
        LinearGradient(
            stops: [
                .init(color: .clear, location: 0),
                .init(color: .black.opacity(0.25), location: 0.5),
                .init(color: .black.opacity(0.88), location: 1)
            ],
            startPoint: .top, endPoint: .bottom
        )
    }

    // Swipe overlays
    static var tryOverlay: LinearGradient {
        LinearGradient(
            colors: [Color.tryGreen.opacity(0.0), Color.tryGreen.opacity(0.65)],
            startPoint: .trailing, endPoint: .leading
        )
    }
    static var dislikeOverlay: LinearGradient {
        LinearGradient(
            colors: [Color.dislikeRed.opacity(0.0), Color.dislikeRed.opacity(0.65)],
            startPoint: .leading, endPoint: .trailing
        )
    }

    // Backgrounds
    static var warmBackground: LinearGradient {
        LinearGradient(
            colors: [Color.warmCream, Color.warmSand.opacity(0.6)],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }

    // subtle off-white — barely noticeable, just warm
    static var homeBackground: LinearGradient {
        LinearGradient(
            colors: [Color(red: 0.99, green: 0.98, blue: 0.97), Color(red: 0.97, green: 0.96, blue: 0.94)],
            startPoint: .top, endPoint: .bottom
        )
    }

    static var homeBackgroundDark: LinearGradient {
        LinearGradient(
            colors: [Color(red: 0.11, green: 0.10, blue: 0.09), Color(red: 0.09, green: 0.08, blue: 0.07)],
            startPoint: .top, endPoint: .bottom
        )
    }

    // Button / accent
    static var orangePrimary: LinearGradient {
        LinearGradient(
            colors: [Color.warmOrange, Color(red: 0.72, green: 0.24, blue: 0.13)],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }

    static var goldAccent: LinearGradient {
        LinearGradient(
            colors: [Color.warmAmber, Color.warmGold],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }

    // Hero detail fade
    static var heroFade: LinearGradient {
        LinearGradient(
            stops: [
                .init(color: .clear, location: 0),
                .init(color: .clear, location: 0.38),
                .init(color: .black.opacity(0.45), location: 0.72),
                .init(color: .black.opacity(0.78), location: 1)
            ],
            startPoint: .top, endPoint: .bottom
        )
    }
}
