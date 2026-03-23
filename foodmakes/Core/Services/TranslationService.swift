import Foundation
import SwiftUI

// MARK: - Google Translate Service
/// A free wrapper for Google Translate using the translate_a/single endpoint.
actor GoogleTranslateService {
    static let shared = GoogleTranslateService()

    private var cache: [String: String] = [:]
    private let persistKey = "fm_translation_cache_google_v1"

    private init() {
        if let saved = UserDefaults.standard.dictionary(forKey: persistKey) as? [String: String] {
            cache = saved
        }
    }

    func translate(text: String, target: String) async -> String? {
        let key = "\(target):\(text)"
        if let hit = cache[key] { return hit }

        // Final check in legacy cache to avoid re-translating already translated items
        if let legacyHit = await TranslationService.shared.cached(key: key) {
            cache[key] = legacyHit
            UserDefaults.standard.set(cache, forKey: persistKey)
            return legacyHit
        }

        guard let url = URL(string: "https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=\(target)&dt=t&q=\(text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") else {
            return nil
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let json = try JSONSerialization.jsonObject(with: data) as? [Any],
               let firstPart = json.first as? [Any] {
                
                var resultArr: [String] = []
                for part in firstPart {
                    if let innerPart = part as? [Any], let translatedText = innerPart.first as? String {
                        resultArr.append(translatedText)
                    }
                }
                
                let result = resultArr.joined()
                
                if !result.isEmpty {
                    cache[key] = result
                    // Always save to disk immediately to persist
                    UserDefaults.standard.set(cache, forKey: persistKey)
                    return result
                }
            }
        } catch {
            print("Google Translate error: \(error)")
        }
        return nil
    }

    func clearCache() {
        cache.removeAll()
        UserDefaults.standard.removeObject(forKey: persistKey)
    }
}

// MARK: - Translation Cache (Legacy Shim for compatibility if needed)
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
    @State private var isTranslating = false

    private var lm: LanguageManager { LanguageManager.shared }

    var body: some View {
        let display = translated ?? original
        ZStack(alignment: .trailing) {
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

            // Translation Status Indicator
            if isTranslating {
                translatingIndicator
            }
        }
        // Re-run when language changes or original text changes
        .task(id: "\(lm.current.rawValue):\(original)") {
            translated = nil
            isTranslating = false
            
            guard lm.current != .english else { return }
            let langCode = lm.current.rawValue
            
            isTranslating = true
            if let result = await GoogleTranslateService.shared.translate(text: original, target: langCode) {
                translated = result
            }
            isTranslating = false
        }
    }

    private var translatingIndicator: some View {
        HStack(spacing: 4) {
            ProgressView()
                .controlSize(.mini)
                .tint(.warmOrange)
            Image(systemName: " globe")
                .font(.system(size: 10))
                .foregroundStyle(.warmOrange)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(Color(.secondarySystemBackground).opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.trailing, -30)
        .transition(.opacity.combined(with: .scale))
    }
}


