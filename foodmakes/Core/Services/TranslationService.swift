import Foundation
import SwiftUI
import Translation

// MARK: - Translation Cache + Web Fallback
actor TranslationService {
    static let shared = TranslationService()

    private var cache: [String: String] = [:]
    private let persistKey = "fm_translation_cache_v7"

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

    // Web fallback: used on Simulator or when Apple Translation is unavailable
    func webTranslate(_ text: String, target: String) async -> String? {
        let cleanText = (text.removingPercentEncoding ?? text)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanText.isEmpty else { return nil }

        var components = URLComponents(string: "https://api.mymemory.translated.net/get")!
        components.queryItems = [
            URLQueryItem(name: "q", value: cleanText),
            URLQueryItem(name: "langpair", value: "en|\(target)")
        ]
        guard let url = components.url else { return nil }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            struct Resp: Codable {
                struct D: Codable { let translatedText: String }
                let responseData: D
            }
            let result = try JSONDecoder().decode(Resp.self, from: data)
            let raw = result.responseData.translatedText
            let decoded = (raw.removingPercentEncoding ?? raw)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            return decoded.isEmpty || decoded == cleanText ? nil : decoded
        } catch {
            return nil
        }
    }
}

// MARK: - TranslatedText SwiftUI View
/// - Gerçek cihaz: Apple Translation (dil paketi yoksa otomatik indirme diyalogu gösterir)
/// - Simülatör / desteklenmeyen cihaz: Web API (MyMemory / Google backend) ile yedek çeviri
struct TranslatedText: View {
    let original: String
    var font: Font = .body
    var color: Color = Color(.label)
    var fontWeight: Font.Weight? = nil
    var lineLimit: Int? = nil
    var fixedVertical: Bool = false

    @State private var translated: String?
    @State private var sessionConfig: TranslationSession.Configuration?

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
            guard lm.current != .english else {
                translated = nil
                sessionConfig = nil
                return
            }

            // Cache'den hızlı döndür
            let key = "\(lm.current.rawValue):\(original)"
            if let hit = await TranslationService.shared.cached(key: key) {
                translated = hit
                sessionConfig = nil
                return
            }

            let source = Locale.Language(identifier: "en")
            let target = Locale.Language(identifier: lm.current.rawValue)
            let status = await LanguageAvailability().status(from: source, to: target)

            switch status {
            case .installed, .supported:
                // .installed → doğrudan çevirir
                // .supported → iOS dil paketi indirme diyalogu gösterir, sonra çevirir
                sessionConfig = TranslationSession.Configuration(source: source, target: target)
            default:
                // Simülatör veya gerçekten desteklenmeyen → web yedek
                sessionConfig = nil
                if let result = await TranslationService.shared.webTranslate(original, target: lm.current.rawValue) {
                    translated = result
                    await TranslationService.shared.store(key: key, value: result)
                }
            }
        }
        // Apple Translation session hazır olduğunda bu blok çalışır
        .translationTask(sessionConfig) { session in
            defer { sessionConfig = nil }
            let key = "\(lm.current.rawValue):\(original)"
            do {
                let response = try await session.translate(original)
                let result = response.targetText
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                guard !result.isEmpty else { return }
                translated = result
                await TranslationService.shared.store(key: key, value: result)
            } catch {
                // Apple Translation başarısız → web yedek
                if let result = await TranslationService.shared.webTranslate(original, target: lm.current.rawValue) {
                    translated = result
                    await TranslationService.shared.store(key: key, value: result)
                }
            }
        }
    }
}


    func translate(_ text: String, target: String) async -> String? {
        // Normalize input: strip any accidental percent-encoding first
        let cleanText = text.removingPercentEncoding ?? text
        let cacheKey = "\(target):\(cleanText)"
        if let hit = cache[cacheKey] { return hit }

        // Build URL using URLComponents so encoding is handled correctly
        var components = URLComponents(string: "https://api.mymemory.translated.net/get")!
        components.queryItems = [
            URLQueryItem(name: "q", value: cleanText),
            URLQueryItem(name: "langpair", value: "en|\(target)")
        ]
        guard let url = components.url else { return nil }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let result = try JSONDecoder().decode(TranslationResponseDTO.self, from: data)

            // Decode the result to remove any leftover percent-encoding from the API
            let raw = result.responseData.translatedText
            let translatedText = (raw.removingPercentEncoding ?? raw)
                .trimmingCharacters(in: .whitespacesAndNewlines)

            guard !translatedText.isEmpty, translatedText != cleanText else { return nil }

            cache[cacheKey] = translatedText
            saveCache()
            return translatedText
        } catch {
            print("Translation Error: \(error)")
        }
        return nil
    }

    func clearCache() {
        cache.removeAll()
        UserDefaults.standard.removeObject(forKey: persistKey)
    }

    private func saveCache() {
        UserDefaults.standard.set(cache, forKey: persistKey)
    }


struct TranslationResponseDTO: Codable {
    struct ResponseData: Codable {
        let translatedText: String
    }
    let responseData: ResponseData
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
            guard lm.current != .english else {
                translated = nil
                return
            }
            if let result = await TranslationService.shared.translate(original, target: lm.current.rawValue) {
                translated = result
            }
        }
    }
}
