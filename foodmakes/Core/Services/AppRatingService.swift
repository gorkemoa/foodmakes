import Foundation
import UIKit
import Observation

// MARK: - App Rating Service
@MainActor
@Observable
final class AppRatingService {

    static let shared = AppRatingService()

    // Triggers the custom prompt overlay
    var showRatingPrompt = false

    private let launchCountKey    = "fm_launch_count"
    private let promptedCountKey  = "fm_rating_prompted_count"

    /// Milestones (app opens) at which the prompt appears
    private let milestones = [4, 15, 50]

    private init() {}

    // MARK: - Called once per launch
    func onAppLaunched() {
        let count = UserDefaults.standard.integer(forKey: launchCountKey) + 1
        UserDefaults.standard.set(count, forKey: launchCountKey)

        let alreadyPrompted = UserDefaults.standard.integer(forKey: promptedCountKey)
        let nextMilestone = milestones.dropFirst(alreadyPrompted).first

        if let target = nextMilestone, count == target {
            // Small delay so the app UI finishes loading
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.showRatingPrompt = true
            }
        }
    }

    // MARK: - Called after user interacts with the prompt
    func dismissPrompt() {
        showRatingPrompt = false
        let prompted = UserDefaults.standard.integer(forKey: promptedCountKey)
        UserDefaults.standard.set(prompted + 1, forKey: promptedCountKey)
    }

    // MARK: - Open App Store page directly (used from Settings)
    func openAppStorePage() {
        // Replace the numeric App Store ID below once the app is published.
        // e.g. "https://apps.apple.com/app/id1234567890?action=write-review"
        guard let id = Bundle.main.object(forInfoDictionaryKey: "AppStoreID") as? String,
              let url = URL(string: "https://apps.apple.com/app/id\(id)?action=write-review") else {
            // Fallback: search by bundle ID
            let bundleID = Bundle.main.bundleIdentifier ?? "com.rivorya.foodmakes"
            if let url = URL(string: "https://apps.apple.com/search?term=\(bundleID)") {
                UIApplication.shared.open(url)
            }
            return
        }
        UIApplication.shared.open(url)
    }
}
