import SwiftUI
import Observation

// MARK: - App Theme Preference
enum AppThemePreference: String, CaseIterable {
    case system = "system"
    case light  = "light"
    case dark   = "dark"

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }

    var icon: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light:  return "sun.max.fill"
        case .dark:   return "moon.fill"
        }
    }
}

// MARK: - Theme Manager
@MainActor
@Observable
final class ThemeManager {
    static let shared = ThemeManager()

    private let key = "fm_theme_preference"
    private let onboardingKey = "fm_theme_onboarding_done"

    var preference: AppThemePreference {
        didSet {
            UserDefaults.standard.set(preference.rawValue, forKey: key)
        }
    }

    /// False on first launch — triggers the theme onboarding screen
    var onboardingDone: Bool = UserDefaults.standard.bool(forKey: "fm_theme_onboarding_done") {
        didSet { UserDefaults.standard.set(onboardingDone, forKey: "fm_theme_onboarding_done") }
    }

    /// False on first launch — triggers the feature showcase onboarding
    var showcaseDone: Bool = UserDefaults.standard.bool(forKey: "fm_showcase_done") {
        didSet { UserDefaults.standard.set(showcaseDone, forKey: "fm_showcase_done") }
    }

    private init() {
        if let saved = UserDefaults.standard.string(forKey: "fm_theme_preference"),
           let pref = AppThemePreference(rawValue: saved) {
            preference = pref
        } else {
            preference = .system
        }
    }
}
