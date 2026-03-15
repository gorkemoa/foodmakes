import Foundation
import Observation

// MARK: - Supported Languages
enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case turkish = "tr"
    case spanish = "es"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .english: return "English"
        case .turkish: return "Türkçe"
        case .spanish: return "Español"
        }
    }

    var flag: String {
        switch self {
        case .english: return "🇬🇧"
        case .turkish: return "🇹🇷"
        case .spanish: return "🇪🇸"
        }
    }
}

// MARK: - All UI Strings
struct Translations {
    // Home
    let appTagline: String
    let mealsLeft: String        // used as suffix: "12 kaldı"
    let skip: String
    let save: String
    let tryStamp: String
    let nopeStamp: String

    // MealDetail / Sheet
    let savedToTryList: String
    let dislikedLabel: String
    let ingredients: String
    let howToCook: String
    let loadingRecipe: String
    let watchAndRead: String
    let watchOnYoutube: String
    let originalRecipe: String
    let viewFullRecipe: String
    let moreStepsFormat: String  // "%d more steps"
    let stepsCountFormat: String  // "%d steps"
    let ingredientsCountFormat: String  // "%d ingredients"

    // TryList
    let tryListTitle: String
    let searchSavedPrompt: String
    let nothingSavedYet: String
    let swipeRightHint: String

    // Disliked
    let dislikedTitle: String
    let searchDislikedPrompt: String
    let noRejectedMeals: String
    let swipeLeftHint: String

    // Settings
    let settingsTitle: String
    let appSubtitle: String
    let dataManagement: String
    let clearTryList: String
    let clearTryListSub: String
    let clearDisliked: String
    let clearDislikedSub: String
    let resetSwipeHistory: String
    let resetSwipeHistorySub: String
    let resetEverything: String
    let resetEverythingSub: String
    let about: String
    let version: String
    let poweredBy: String
    let clearAll: String
    let resetHistory: String
    let resetAllData: String
    let clearTryConfirm: String
    let clearDislikedConfirm: String
    let resetSwipeConfirm: String
    let resetAllConfirm: String

    // Settings toasts
    let toastSwipeCleared: String
    let toastTryCleared: String
    let toastDislikedCleared: String
    let toastAllReset: String

    // Language Picker
    let language: String
    let languageSub: String

    // Tab Labels
    let tabDiscover: String
    let tabTryList: String
    let tabDisliked: String
    let tabSettings: String

    // Rating
    let rateMeal: String
    let yourRating: String
    let overallScore: String
    let tasteScore: String
    let wouldEatAgain: String
    let wouldRecommend: String
    let saveRating: String
    let editRating: String

    // Sheet tutorial
    let sheetDismissHint: String

    // Swipe toast
    let addedToLiked: String
    let goToDetail: String

    // Category grouping
    let categoryOther: String
}

// MARK: - Language Manager
@MainActor
@Observable
final class LanguageManager {
    static let shared = LanguageManager()

    private let userDefaultsKey = "fm_selected_language"

    var current: AppLanguage {
        didSet {
            UserDefaults.standard.set(current.rawValue, forKey: userDefaultsKey)
            // Clear translation cache so new language fetches fresh translations
            Task { await TranslationService.shared.clearCache() }
        }
    }

    var t: Translations { translations(for: current) }

    private init() {
        // 1. Check persisted user preference
        if let saved = UserDefaults.standard.string(forKey: "fm_selected_language"),
           let lang = AppLanguage(rawValue: saved) {
            current = lang
            return
        }
        // 2. Detect from device preferred languages
        let deviceCode = Locale.preferredLanguages
            .first
            .map { String($0.prefix(2)) } ?? "en"
        current = AppLanguage(rawValue: deviceCode) ?? .english
    }
}

// MARK: - String Tables
private func translations(for lang: AppLanguage) -> Translations {
    switch lang {
    case .english: return englishTranslations
    case .turkish: return turkishTranslations
    case .spanish: return spanishTranslations
    }
}

private let englishTranslations = Translations(
    appTagline:             "swipe right to save  ·  left to skip",
    mealsLeft:              "left",
    skip:                   "Skip",
    save:                   "Save",
    tryStamp:               "TRY",
    nopeStamp:              "NOPE",
    savedToTryList:         "Saved to Try List",
    dislikedLabel:          "Disliked",
    ingredients:            "Ingredients",
    howToCook:              "How to Cook",
    loadingRecipe:          "Loading recipe…",
    watchAndRead:           "Watch & Read",
    watchOnYoutube:         "Watch on YouTube",
    originalRecipe:         "Original Recipe",
    viewFullRecipe:         "View Full Recipe",
    moreStepsFormat:        "+%d more steps",
    stepsCountFormat:       "%d steps",
    ingredientsCountFormat: "%d ingredients",
    tryListTitle:           "Liked",
    searchSavedPrompt:      "Search liked meals…",
    nothingSavedYet:        "Nothing liked yet",
    swipeRightHint:         "Swipe right on a meal to add it here.",
    dislikedTitle:          "Disliked",
    searchDislikedPrompt:   "Search disliked meals…",
    noRejectedMeals:        "No rejected meals",
    swipeLeftHint:          "Swipe left on a meal to move it here.",
    settingsTitle:          "Settings",
    appSubtitle:            "Discover your next favourite meal",
    dataManagement:         "Data Management",
    clearTryList:           "Clear Try List",
    clearTryListSub:        "Remove all saved meals",
    clearDisliked:          "Clear Disliked",
    clearDislikedSub:       "Remove all disliked meals",
    resetSwipeHistory:      "Reset Swipe History",
    resetSwipeHistorySub:   "All swiped meals will reappear",
    resetEverything:        "Reset Everything",
    resetEverythingSub:     "Clears all data and history",
    about:                  "About",
    version:                "Version",
    poweredBy:              "Powered by TheMealDB",
    clearAll:               "Clear All",
    resetHistory:           "Reset History",
    resetAllData:           "Reset All Data",
    clearTryConfirm:        "Clear Try List?",
    clearDislikedConfirm:   "Clear Disliked?",
    resetSwipeConfirm:      "Reset swipe history?",
    resetAllConfirm:        "Reset all data?",
    toastSwipeCleared:      "Swipe history cleared ✓",
    toastTryCleared:        "Try List cleared ✓",
    toastDislikedCleared:   "Disliked list cleared ✓",
    toastAllReset:          "All data reset ✓",
    language:               "Language",
    languageSub:            "App display language",
    tabDiscover:            "Discover",
    tabTryList:             "Liked",
    tabDisliked:            "Disliked",
    tabSettings:            "Settings",
    rateMeal:               "Rate this meal",
    yourRating:             "Your Rating",
    overallScore:           "Overall",
    tasteScore:             "Taste",
    wouldEatAgain:          "Would eat again?",
    wouldRecommend:         "Would recommend?",
    saveRating:             "Save Rating",
    editRating:             "Edit Rating",
    sheetDismissHint:       "Tap × to close · or swipe down",
    addedToLiked:           "Added to Liked",
    goToDetail:             "View",
    categoryOther:          "Other"
)

private let turkishTranslations = Translations(
    appTagline:             "kaydet için sağa  ·  geç için sola kaydır",
    mealsLeft:              "kaldı",
    skip:                   "Geç",
    save:                   "Kaydet",
    tryStamp:               "DENE",
    nopeStamp:              "YOK",
    savedToTryList:         "Listeye Kaydedildi",
    dislikedLabel:          "Beğenilmedi",
    ingredients:            "Malzemeler",
    howToCook:              "Nasıl Yapılır",
    loadingRecipe:          "Tarif yükleniyor…",
    watchAndRead:           "İzle & Oku",
    watchOnYoutube:         "YouTube'da İzle",
    originalRecipe:         "Orijinal Tarif",
    viewFullRecipe:         "Tam Tarifi Gör",
    moreStepsFormat:        "+%d adım daha",
    stepsCountFormat:       "%d adım",
    ingredientsCountFormat: "%d malzeme",
    tryListTitle:           "Beğendiklerim",
    searchSavedPrompt:      "Beğenilen yemek ara…",
    nothingSavedYet:        "Henüz beğenilmedi",
    swipeRightHint:         "Bir yemeği buraya eklemek için sağa kaydırın.",
    dislikedTitle:          "Beğenmediklerim",
    searchDislikedPrompt:   "Beğenmediklerim içinde ara…",
    noRejectedMeals:        "Reddedilen yemek yok",
    swipeLeftHint:          "Sola kaydırdığınız yemekler buraya gelir.",
    settingsTitle:          "Ayarlar",
    appSubtitle:            "Yeni favori yemeğini keşfet",
    dataManagement:         "Veri Yönetimi",
    clearTryList:           "Dene Listesini Temizle",
    clearTryListSub:        "Tüm kaydedilen yemekleri kaldır",
    clearDisliked:          "Beğenilmeyenleri Temizle",
    clearDislikedSub:       "Tüm beğenilmeyen yemekleri kaldır",
    resetSwipeHistory:      "Kaydırma Geçmişini Sıfırla",
    resetSwipeHistorySub:   "Kaydırılan tüm yemekler tekrar görünecek",
    resetEverything:        "Her Şeyi Sıfırla",
    resetEverythingSub:     "Tüm veri ve geçmişi temizler",
    about:                  "Hakkında",
    version:                "Sürüm",
    poweredBy:              "TheMealDB tarafından desteklenir",
    clearAll:               "Tümünü Temizle",
    resetHistory:           "Geçmişi Sıfırla",
    resetAllData:           "Tüm Veriyi Sıfırla",
    clearTryConfirm:        "Dene Listesi silinsin mi?",
    clearDislikedConfirm:   "Beğenilmeyenler silinsin mi?",
    resetSwipeConfirm:      "Kaydırma geçmişi sıfırlansın mı?",
    resetAllConfirm:        "Tüm veriler sıfırlansın mı?",
    toastSwipeCleared:      "Kaydırma geçmişi temizlendi ✓",
    toastTryCleared:        "Dene Listesi temizlendi ✓",
    toastDislikedCleared:   "Beğenilmeyenler temizlendi ✓",
    toastAllReset:          "Tüm veriler sıfırlandı ✓",
    language:               "Dil",
    languageSub:            "Uygulama görüntüleme dili",
    tabDiscover:            "Keşfet",
    tabTryList:             "Beğendiklerim",
    tabDisliked:            "Beğenmediklerim",
    tabSettings:            "Ayarlar",
    rateMeal:               "Bu yemeği puanla",
    yourRating:             "Puanınız",
    overallScore:           "Genel",
    tasteScore:             "Lezzet",
    wouldEatAgain:          "Tekrar yer misin?",
    wouldRecommend:         "Önerir misin?",
    saveRating:             "Puanı Kaydet",
    editRating:             "Puanı Düzenle",
    sheetDismissHint:       "× ile kapat · veya aşağı kaydır",
    addedToLiked:           "Beğenilenlere eklendi",
    goToDetail:             "Detaya git",
    categoryOther:          "Diğer"
)

private let spanishTranslations = Translations(
    appTagline:             "derecha guardar  ·  izquierda omitir",
    mealsLeft:              "restantes",
    skip:                   "Omitir",
    save:                   "Guardar",
    tryStamp:               "PROBAR",
    nopeStamp:              "NO",
    savedToTryList:         "Guardado en la lista",
    dislikedLabel:          "No me gusta",
    ingredients:            "Ingredientes",
    howToCook:              "Cómo Cocinar",
    loadingRecipe:          "Cargando receta…",
    watchAndRead:           "Ver & Leer",
    watchOnYoutube:         "Ver en YouTube",
    originalRecipe:         "Receta Original",
    viewFullRecipe:         "Ver Receta Completa",
    moreStepsFormat:        "+%d pasos más",
    stepsCountFormat:       "%d pasos",
    ingredientsCountFormat: "%d ingredientes",
    tryListTitle:           "Me Gusta",
    searchSavedPrompt:      "Buscar favoritas…",
    nothingSavedYet:        "Nada marcado aún",
    swipeRightHint:         "Desliza a la derecha para añadirla aquí.",
    dislikedTitle:          "No Me Gusta",
    searchDislikedPrompt:   "Buscar comidas rechazadas…",
    noRejectedMeals:        "Sin comidas rechazadas",
    swipeLeftHint:          "Desliza a la izquierda para moverla aquí.",
    settingsTitle:          "Ajustes",
    appSubtitle:            "Descubre tu próxima comida favorita",
    dataManagement:         "Gestión de datos",
    clearTryList:           "Limpiar Lista de Prueba",
    clearTryListSub:        "Eliminar todas las comidas guardadas",
    clearDisliked:          "Limpiar No Me Gusta",
    clearDislikedSub:       "Eliminar todas las comidas rechazadas",
    resetSwipeHistory:      "Restablecer Historial",
    resetSwipeHistorySub:   "Las comidas deslizadas reaparecerán",
    resetEverything:        "Restablecer Todo",
    resetEverythingSub:     "Elimina todos los datos e historial",
    about:                  "Acerca de",
    version:                "Versión",
    poweredBy:              "Impulsado por TheMealDB",
    clearAll:               "Limpiar Todo",
    resetHistory:           "Restablecer Historial",
    resetAllData:           "Restablecer Todo",
    clearTryConfirm:        "¿Limpiar Lista de Prueba?",
    clearDislikedConfirm:   "¿Limpiar No Me Gusta?",
    resetSwipeConfirm:      "¿Restablecer historial?",
    resetAllConfirm:        "¿Restablecer todos los datos?",
    toastSwipeCleared:      "Historial de deslizamiento borrado ✓",
    toastTryCleared:        "Lista de Prueba borrada ✓",
    toastDislikedCleared:   "Lista No Me Gusta borrada ✓",
    toastAllReset:          "Todos los datos restablecidos ✓",
    language:               "Idioma",
    languageSub:            "Idioma de la aplicación",
    tabDiscover:            "Descubrir",
    tabTryList:             "Me Gusta",
    tabDisliked:            "No Me Gusta",
    tabSettings:            "Ajustes",
    rateMeal:               "Califica esta comida",
    yourRating:             "Tu calificación",
    overallScore:           "General",
    tasteScore:             "Sabor",
    wouldEatAgain:          "¿Lo comerías de nuevo?",
    wouldRecommend:         "¿Lo recomendarías?",
    saveRating:             "Guardar calificación",
    editRating:             "Editar calificación",
    sheetDismissHint:       "Toca × para cerrar · o desliza abajo",
    addedToLiked:           "Añadido a Me Gusta",
    goToDetail:             "Ver detalle",
    categoryOther:          "Otros"
)
