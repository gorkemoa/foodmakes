import Foundation
import UIKit
import Observation

// MARK: - App Update Checker (Flutter Upgrader-style)
@MainActor
@Observable
final class AppUpdateChecker {

    static let shared = AppUpdateChecker()

    var showUpdateAlert  = false
    var latestVersion    = ""
    private var storeURL: URL?

    private let dismissedVersionKey = "fm_dismissed_update_version"

    var currentVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0"
    }

    private init() {}

    // MARK: - Check iTunes Lookup API
    func checkForUpdate() async {
        let appleID = "6760628300"
        let urlString = "https://itunes.apple.com/lookup?id=\(appleID)"
        guard let url = URL(string: urlString) else { return }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else { return }

            let decoded = try JSONDecoder().decode(ITunesLookupResponse.self, from: data)
            guard let result = decoded.results.first else { return }

            let storeVersion = result.version
            let dismissed    = UserDefaults.standard.string(forKey: dismissedVersionKey)

            guard isNewer(storeVersion, than: currentVersion) else { return }
            guard dismissed != storeVersion else { return }  // user already dismissed this version

            latestVersion = storeVersion
            storeURL      = URL(string: result.trackViewUrl)
            showUpdateAlert = true
        } catch {
            // Silently ignore — update check is non-critical
        }
    }

    // MARK: - User actions
    func openStore() {
        guard let url = storeURL else { return }
        UIApplication.shared.open(url)
        showUpdateAlert = false
    }

    func dismissUpdate() {
        // Remember this version so we don't prompt again for the same release
        UserDefaults.standard.set(latestVersion, forKey: dismissedVersionKey)
        showUpdateAlert = false
    }

    // MARK: - Version comparison (semantic "major.minor.patch")
    private func isNewer(_ a: String, than b: String) -> Bool {
        a.compare(b, options: .numeric) == .orderedDescending
    }
}

// MARK: - iTunes Lookup API models
private struct ITunesLookupResponse: Decodable {
    let results: [ITunesResult]
    struct ITunesResult: Decodable {
        let version: String
        let trackViewUrl: String
    }
}
