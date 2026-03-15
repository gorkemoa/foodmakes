import Foundation
import SwiftUI
import Translation

// MARK: - Download Coordinator
/// Controls when the Apple Translation download sheet appears.
/// Rate-limited to once per session and at most once per 24 hours per language.
@MainActor
@Observable
final class TranslationDownloadManager {
    static let shared = TranslationDownloadManager()

    /// Set by coordinator or Settings; observed by RootTabView's .translationTask
    var pendingConfig: TranslationSession.Configuration?
    /// Increments when a download completes; causes TranslatedText to retry
    var downloadRevision: Int = 0

    private var promptedThisSession = false
    private let cooldownSeconds: TimeInterval = 60 * 60 * 24 // 24 hours

    private init() {}

    /// Called from TranslatedText when pack is missing. Shows prompt at most once
    /// per session and once per 24 hours per language.
    func promptIfAppropriate(for langCode: String) {
        guard !promptedThisSession else { return }
        let key = "fm_tl_prompt_\(langCode)"
        let last = UserDefaults.standard.double(forKey: key)
        if last > 0, Date().timeIntervalSince1970 - last < cooldownSeconds { return }
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: key)
        promptedThisSession = true
        pendingConfig = TranslationSession.Configuration(
            source: Locale.Language(identifier: "en"),
            target: Locale.Language(identifier: langCode)
        )
    }

    /// Called from Settings download button — bypasses cooldown.
    func forcePrompt(for langCode: String) {
        promptedThisSession = true
        pendingConfig = TranslationSession.Configuration(
            source: Locale.Language(identifier: "en"),
            target: Locale.Language(identifier: langCode)
        )
    }

    /// Called when RootTabView's .translationTask finishes.
    func onDownloadCompleted() {
        pendingConfig = nil
        downloadRevision += 1
    }
}

// MARK: - Translation Cache (Apple Translation)
actor TranslationService {
    static let shared = TranslationService()

    private var cache: [String: String] = [:]
    private let persistKey = "fm_translation_cache_v8"

    private init() {
        if let saved = UserDefaults.standard.dictionary(forKey: persistKey) as? [String: String] {
            cache = saved
        }
    }

    func cached(key: String) -> String? { cache[key] }

    func store(key: String, value: String) {
        cache[key] = value
        UserDefaults.standard.set(cache, forKey: persistKey)
    }

    func clearCache() {
        cache.removeAll()
        UserDefaults.standard.removeObject(forKey: persistKey)
    }
}

// MARK: - TranslatedText SwiftUI View
struct TranslatedText: View {
    let original: String
    var font: Font = .body
    var color: Color = Color(.label)
    var fontWeight: Font.Weight? = nil
    var lineLimit: Int? = nil
    var fixedVertical: Bool = false

    @State private var translated: String?
    @State private var translationConfig: TranslationSession.Configuration?

    private var lm: LanguageManager { LanguageManager.shared }

    var body: some View {
        let display = translated ?? original
        Group {
            if let ll = lineLimit {
                Text(display)
                    .font(font)
                    .fontWeight(fontWeight)
                    .foregroundStyle(color)
                    .lineLimit(ll)
            } else if fixedVertical {
                Text(display)
                    .font(font)
                    .fontWeight(fontWeight)
                    .foregroundStyle(color)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                Text(display)
                    .font(font)
                    .fontWeight(fontWeight)
                    .foregroundStyle(color)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: translated)
        // Re-run when language changes OR a download just finished (downloadRevision bumps)
        .task(id: "\(lm.current.rawValue):\(original):\(TranslationDownloadManager.shared.downloadRevision)") {
            translated = nil
            translationConfig = nil
            guard lm.current != .english else { return }
            let langCode = lm.current.rawValue
            let key = "\(langCode):\(original)"
            if let hit = await TranslationService.shared.cached(key: key) {
                translated = hit
                return
            }
            // Check if the language pack is already on-device
            let availability = LanguageAvailability()
            let status = await availability.status(
                from: Locale.Language(identifier: "en"),
                to: Locale.Language(identifier: langCode)
            )
            switch status {
            case .installed:
                // Pack ready — translate silently (no dialog)
                translationConfig = TranslationSession.Configuration(
                    source: Locale.Language(identifier: "en"),
                    target: Locale.Language(identifier: langCode)
                )
            case .supported:
                // Pack not yet downloaded — notify coordinator (rate-limited dialog)
                await MainActor.run {
                    TranslationDownloadManager.shared.promptIfAppropriate(for: langCode)
                }
            default:
                break // unsupported — show original
            }
        }
        .translationTask(translationConfig) { session in
            guard translated == nil else { return }
            do {
                let response = try await session.translate(original)
                let result = response.targetText.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !result.isEmpty else { return }
                translated = result
                let key = "\(lm.current.rawValue):\(original)"
                await TranslationService.shared.store(key: key, value: result)
            } catch {
                print("Apple Translation error: \(error)")
            }
        }
    }
}

