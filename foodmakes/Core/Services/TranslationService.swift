import Foundation
import SwiftUI

// MARK: - Translation Service
// Uses MyMemory API — completely free, no API key required
// Docs: https://mymemory.translated.net/doc/spec.php
actor TranslationService {
    static let shared = TranslationService()

    private var memoryCache: [String: String] = [:]
    private let persistKey = "fm_translation_cache_v1"
    private var pendingKeys: Set<String> = []

    private init() {
        // Load persisted cache on first access
        if let saved = UserDefaults.standard.dictionary(forKey: persistKey) as? [String: String] {
            memoryCache = saved
        }
    }

    /// Translates `text` from English to `language`. Returns original if language is English or on error.
    func translate(_ text: String, to language: AppLanguage) async -> String {
        guard language != .english, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return text
        }
        let cacheKey = "\(language.rawValue):\(text)"
        if let cached = memoryCache[cacheKey] { return cached }

        // MyMemory API endpoint
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        // Truncate very long texts to stay within 5000 char limit
        let query = trimmed.count > 4500 ? String(trimmed.prefix(4500)) : trimmed
        guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://api.mymemory.translated.net/get?q=\(encoded)&langpair=en|\(language.rawValue)")
        else { return text }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(MyMemoryResponse.self, from: data)
            let translated = response.responseData.translatedText
            // MyMemory returns the original text (uppercased/modified) on error — check for it
            let result = translated.isEmpty ? text : translated
            memoryCache[cacheKey] = result
            persistCache()
            return result
        } catch {
            return text
        }
    }

    private func persistCache() {
        UserDefaults.standard.set(memoryCache, forKey: persistKey)
    }

    /// Clears the in-memory and persisted translation cache.
    func clearCache() {
        memoryCache.removeAll()
        UserDefaults.standard.removeObject(forKey: persistKey)
    }
}

// MARK: - MyMemory Response DTO
private struct MyMemoryResponse: Decodable {
    let responseData: ResponseData
    struct ResponseData: Decodable {
        let translatedText: String
    }
}

// MARK: - TranslatedText SwiftUI View
/// Drop-in replacement for Text that auto-translates content using the device/user language.
/// Shows original text immediately, then smoothly fades in the translation when ready.
struct TranslatedText: View {
    let original: String
    var font: Font = .body
    var color: Color = Color(.label)
    var fontWeight: Font.Weight? = nil
    var lineLimit: Int? = nil
    var fixedVertical: Bool = false

    @State private var translated: String?

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
        .task(id: "\(lm.current.rawValue):\(original)") {
            if lm.current == .english {
                translated = nil
            } else {
                let result = await TranslationService.shared.translate(original, to: lm.current)
                translated = result
            }
        }
    }
}
