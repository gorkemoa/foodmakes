import Foundation
import Observation

// MARK: - Supported Languages
enum AppLanguage: String, CaseIterable, Identifiable {
    case english  = "en"
    case turkish  = "tr"
    case french   = "fr"
    case spanish  = "es"
    case italian  = "it"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .english:  return "English"
        case .turkish:  return "Türkçe"
        case .french:   return "Français"
        case .spanish:  return "Español"
        case .italian:  return "Italiano"
        }
    }

    var flag: String {
        switch self {
        case .english:  return "🇬🇧"
        case .turkish:  return "🇹🇷"
        case .french:   return "🇫🇷"
        case .spanish:  return "🇪🇸"
        case .italian:  return "🇮🇹"
        }
    }
}

// MARK: - All UI Strings
struct Translations {
    let appName: String
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

    // Meal Plan
    let tabMealPlan: String
    let mealPlanTitle: String
    let addToPlan: String
    let selectDate: String
    let planReminderNote: String
    let confirmPlan: String
    let noMealsPlanned: String
    let noMealsPlannedHint: String
    let mealPlanAdded: String
    let upcomingPlans: String
    let pastPlans: String
    let clearMealPlan: String
    let clearMealPlanSub: String
    let clearMealPlanConfirm: String
    let toastMealPlanCleared: String

    // Notifications
    let notificationsTitle: String
    let dailyReminder: String
    let dailyReminderSub: String
    let reminderTime: String
    let toastNotifEnabled: String
    let toastNotifDisabled: String
    let planReminders: String
    let planRemindersSub: String
    let morningReminder: String
    let eveningReminder: String
    let notifPermissionDenied: String
    let addSecondReminder: String
    let removeSecondReminder: String

    // Appearance / Theme
    let themeOnboardingTitle: String
    let themeOnboardingSubtitle: String
    let themeLight: String
    let themeDark: String
    let themeContinue: String
    let themeChangeHint: String
    let themeSection: String
    let themeSystem: String
    let themeRecommended: String

    // TryList filter
    let filterAll: String
    let filterCategories: String

    // App Rating
    let rateApp: String
    let rateAppSub: String
    let rateAppPopupTitle: String
    let rateAppPopupMessage: String
    let rateNow: String
    let notNow: String

    // Update Checker
    let updateAvailableTitle: String
    let updateAvailableMessage: String   // "%@ is available"
    let updateCurrentVersion: String     // "Current: %@"
    let updateNow: String
    let updateLater: String

    // Onboarding Slides (5 slides)
    let onboardSlide1Title: String
    let onboardSlide1Sub: String
    let onboardSlide2Title: String
    let onboardSlide2Sub: String
    let onboardSlide3Title: String
    let onboardSlide3Sub: String
    let onboardSlide4Title: String
    let onboardSlide4Sub: String
    let onboardSlide5Title: String
    let onboardSlide5Sub: String
    let onboardGetStarted: String
    let onboardNext: String
    let onboardSkip: String
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
    case .english:  return englishTranslations
    case .turkish:  return turkishTranslations
    case .french:   return frenchTranslations
    case .spanish:  return spanishTranslations
    case .italian:  return italianTranslations
    }
}

private let englishTranslations = Translations(
    appName:                "Food Recipes",
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
    categoryOther:          "Other",
    tabMealPlan:            "Meal Plan",
    mealPlanTitle:          "Meal Plan",
    addToPlan:              "Add to Plan",
    selectDate:             "Select Date",
    planReminderNote:       "You'll be reminded at 8:00 AM and 6:00 PM",
    confirmPlan:            "Add to Plan",
    noMealsPlanned:         "No meals planned",
    noMealsPlannedHint:     "Open a meal and tap the calendar icon to plan it.",
    mealPlanAdded:          "Added to Meal Plan ✓",
    upcomingPlans:          "Upcoming",
    pastPlans:              "Past",
    clearMealPlan:          "Clear Meal Plan",
    clearMealPlanSub:       "Remove all planned meals",
    clearMealPlanConfirm:   "Clear meal plan?",
    toastMealPlanCleared:   "Meal plan cleared ✓",
    notificationsTitle:     "Notifications",
    dailyReminder:          "Daily Reminder",
    dailyReminderSub:       "Get a meal suggestion every day",
    reminderTime:           "Reminder Time",
    toastNotifEnabled:      "Daily reminder enabled ✓",
    toastNotifDisabled:     "Daily reminder disabled ✓",
    planReminders:          "Plan Reminders",
    planRemindersSub:       "Set times for your planned meals",
    morningReminder:        "Morning",
    eveningReminder:        "Evening",
    notifPermissionDenied:  "Enable notifications in Settings app",
    addSecondReminder:      "Add second reminder",
    removeSecondReminder:   "Remove second reminder",
    themeOnboardingTitle:   "How do you like it?",
    themeOnboardingSubtitle: "Choose the look that feels right. You can always change it later in Settings.",
    themeLight:             "Light",
    themeDark:              "Dark",
    themeContinue:          "Continue",
    themeChangeHint:        "You can change this anytime in Settings → Appearance",
    themeSection:           "Appearance",
    themeSystem:            "System Default",
    themeRecommended:       "Recommended",
    filterAll:              "All",
    filterCategories:       "Categories",
    rateApp:                "Rate the App",
    rateAppSub:             "Share your feedback on the App Store",
    rateAppPopupTitle:      "Enjoying the app?",
    rateAppPopupMessage:    "A quick rating helps us grow and keep improving recipes for you.",
    rateNow:                "Rate Now ★",
    notNow:                 "Not Now",
    updateAvailableTitle:   "Update Available",
    updateAvailableMessage: "Version %@ is now available.",
    updateCurrentVersion:   "You have version %@",
    updateNow:              "Update Now",
    updateLater:            "Later",
    onboardSlide1Title:     "Discover New Meals",
    onboardSlide1Sub:       "Swipe through hundreds of recipes from around the world. Your next favourite is one swipe away.",
    onboardSlide2Title:     "Swipe Right to Save",
    onboardSlide2Sub:       "Like a meal? Swipe right and it lands in your personal Try List, ready whenever you are.",
    onboardSlide3Title:     "Swipe Left to Skip",
    onboardSlide3Sub:       "Not feeling it? Swipe left and we'll show you something better. No meal is here forever.",
    onboardSlide4Title:     "Plan Your Week",
    onboardSlide4Sub:       "Add meals to your weekly plan and get timely reminders so you never miss a home-cooked meal.",
    onboardSlide5Title:     "Recipes in Your Language",
    onboardSlide5Sub:       "Everything translates to your language, on-device, privately. No internet needed after download.",
    onboardGetStarted:      "Get Started",
    onboardNext:            "Next",
    onboardSkip:            "Skip"
)

private let turkishTranslations = Translations(
    appName:                "Yemek Tarifleri",
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
    categoryOther:          "Diğer",
    tabMealPlan:            "Yemek Planı",
    mealPlanTitle:          "Yemek Planı",
    addToPlan:              "Plana Ekle",
    selectDate:             "Tarih Seç",
    planReminderNote:       "Sabah 08:00 ve akşam 18:00'de hatırlatılacaksın",
    confirmPlan:            "Plana Ekle",
    noMealsPlanned:         "Henüz plan yok",
    noMealsPlannedHint:     "Bir yemek aç ve takvim ikonuna bas.",
    mealPlanAdded:          "Plana eklendi ✓",
    upcomingPlans:          "Yakında",
    pastPlans:              "Geçmiş",
    clearMealPlan:          "Yemek Planını Temizle",
    clearMealPlanSub:       "Tüm planlanan yemekleri kaldır",
    clearMealPlanConfirm:   "Yemek planı silinsin mi?",
    toastMealPlanCleared:   "Yemek planı temizlendi ✓",
    notificationsTitle:     "Bildirimler",
    dailyReminder:          "Günlük Hatırlatıcı",
    dailyReminderSub:       "Her gün yemek önerisi al",
    reminderTime:           "Hatırlatma Saati",
    toastNotifEnabled:      "Günlük hatırlatıcı etkinleştirildi ✓",
    toastNotifDisabled:     "Günlük hatırlatıcı kapatıldı ✓",
    planReminders:          "Plan Hatırlatıcıları",
    planRemindersSub:       "Planlı yemekleriniz için saatleri belirleyin",
    morningReminder:        "Sabah",
    eveningReminder:        "Akşam",
    notifPermissionDenied:  "Bildirimler için Ayarlar'ı aç",
    addSecondReminder:      "İkinci hatırlatıcı ekle",
    removeSecondReminder:   "İkinci hatırlatıcıyı kaldır",
    themeOnboardingTitle:   "Nasıl görünsün?",
    themeOnboardingSubtitle: "Sana uygun görünümü seç. Daha sonra Ayarlar'dan değiştirebilirsin.",
    themeLight:             "Aydınlık",
    themeDark:              "Karanlık",
    themeContinue:          "Devam Et",
    themeChangeHint:        "Bunu istediğin zaman Ayarlar → Görünüm'den değiştirebilirsin",
    themeSection:           "Görünüm",
    themeSystem:            "Sistem Varsayılanı",
    themeRecommended:       "Önerilen",
    filterAll:              "Tümü",
    filterCategories:       "Kategoriler",
    rateApp:                "Uygulamayı Puanla",
    rateAppSub:             "App Store'da geri bildiriminizi paylaşın",
    rateAppPopupTitle:      "Uygulamayı seviyor musun?",
    rateAppPopupMessage:    "Kısa bir değerlendirme büyümemize ve tarifleri iyileştirmemize yardımcı olur.",
    rateNow:                "Şimdi Puan Ver ★",
    notNow:                 "Şimdi Değil",
    updateAvailableTitle:   "Güncelleme Mevcut",
    updateAvailableMessage: "%@ sürümü kullanılabilir.",
    updateCurrentVersion:   "Mevcut sürüm: %@",
    updateNow:              "Güncelle",
    updateLater:            "Sonra",
    onboardSlide1Title:     "Yeni Yemekler Keşfet",
    onboardSlide1Sub:       "Dünyanın dört bir yanından yüzlerce tarif arasında gezin. Favorin bir kaydırmada.",
    onboardSlide2Title:     "Kaydetmek İçin Sağa Kaydır",
    onboardSlide2Sub:       "Beğendin mi? Sağa kaydır ve yemek Dene Listenize eklensin, istediğinde hazır olsun.",
    onboardSlide3Title:     "Geçmek İçin Sola Kaydır",
    onboardSlide3Sub:       "İstemiyorsan? Sola kaydır, sana daha iyisini gösterelim. Hiçbir yemek burada sonsuza kalmaz.",
    onboardSlide4Title:     "Haftanı Planla",
    onboardSlide4Sub:       "Yemekleri haftalık planına ekle, zamanında hatırlatıcı al. Ev yemeklerini hiç kaçırma.",
    onboardSlide5Title:     "Tarifler Senin Dilinde",
    onboardSlide5Sub:       "Her şey dilini çevirilir, cihazında, gizlice. İndirdikten sonra internete gerek yok.",
    onboardGetStarted:      "Başla",
    onboardNext:            "İleri",
    onboardSkip:            "Geç"
)

private let spanishTranslations = Translations(
    appName:                "Recetas de Cocina",
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
    categoryOther:          "Otros",
    tabMealPlan:            "Plan de Comidas",
    mealPlanTitle:          "Plan de Comidas",
    addToPlan:              "Añadir al Plan",
    selectDate:             "Seleccionar Fecha",
    planReminderNote:       "Se te recordará a las 8:00 y a las 18:00",
    confirmPlan:            "Añadir al Plan",
    noMealsPlanned:         "Sin comidas planificadas",
    noMealsPlannedHint:     "Abre una comida y toca el icono del calendario.",
    mealPlanAdded:          "Añadido al plan ✓",
    upcomingPlans:          "Próximas",
    pastPlans:              "Pasadas",
    clearMealPlan:          "Limpiar Plan de Comidas",
    clearMealPlanSub:       "Eliminar todas las comidas planificadas",
    clearMealPlanConfirm:   "¿Limpiar el plan?",
    toastMealPlanCleared:   "Plan de comidas eliminado ✓",
    notificationsTitle:     "Notificaciones",
    dailyReminder:          "Recordatorio diario",
    dailyReminderSub:       "Recibe una sugerencia de comida cada día",
    reminderTime:           "Hora del recordatorio",
    toastNotifEnabled:      "Recordatorio diario activado ✓",
    toastNotifDisabled:     "Recordatorio diario desactivado ✓",
    planReminders:          "Recordatorios del Plan",
    planRemindersSub:       "Configura las horas para tus comidas planificadas",
    morningReminder:        "Mañana",
    eveningReminder:        "Noche",
    notifPermissionDenied:  "Activa las notificaciones en Ajustes",
    addSecondReminder:      "Añadir segundo recordatorio",
    removeSecondReminder:   "Quitar segundo recordatorio",
    themeOnboardingTitle:   "¿Cómo te gusta?",
    themeOnboardingSubtitle: "Elige el aspecto que prefieras. Puedes cambiarlo en Ajustes.",
    themeLight:             "Claro",
    themeDark:              "Oscuro",
    themeContinue:          "Continuar",
    themeChangeHint:        "Puedes cambiarlo en cualquier momento en Ajustes → Apariencia",
    themeSection:           "Apariencia",
    themeSystem:            "Por defecto del sistema",
    themeRecommended:       "Recomendado",
    filterAll:              "Todos",
    filterCategories:       "Categorías",
    rateApp:                "Calificar la App",
    rateAppSub:             "Comparte tu opinión en el App Store",
    rateAppPopupTitle:      "¿Te gusta la app?",
    rateAppPopupMessage:    "Una calificación rápida nos ayuda a crecer y mejorar las recetas.",
    rateNow:                "Calificar Ahora ★",
    notNow:                 "Ahora no",
    updateAvailableTitle:   "Actualización Disponible",
    updateAvailableMessage: "La versión %@ ya está disponible.",
    updateCurrentVersion:   "Tienes la versión %@",
    updateNow:              "Actualizar Ahora",
    updateLater:            "Después",
    onboardSlide1Title:     "Descubre Nuevas Comidas",
    onboardSlide1Sub:       "Desliza entre cientos de recetas de todo el mundo. Tu próxima favorita está a un deslizamiento.",
    onboardSlide2Title:     "Desliza a la Derecha para Guardar",
    onboardSlide2Sub:       "¿Te gusta? Desliza a la derecha y se guarda en tu lista, lista cuando quieras.",
    onboardSlide3Title:     "Desliza a la Izquierda para Saltar",
    onboardSlide3Sub:       "¿No te convence? Desliza a la izquierda y te mostraremos algo mejor.",
    onboardSlide4Title:     "Planifica tu Semana",
    onboardSlide4Sub:       "Añade comidas a tu plan semanal y recibe recordatorios. Nunca más te pierdas una comida casera.",
    onboardSlide5Title:     "Recetas en tu Idioma",
    onboardSlide5Sub:       "Todo se traduce a tu idioma, en el dispositivo, sin privacidad comprometida.",
    onboardGetStarted:      "Empezar",
    onboardNext:            "Siguiente",
    onboardSkip:            "Omitir"
)

private let frenchTranslations = Translations(
    appName:                "Recettes de Cuisine",
    appTagline:             "glisser à droite pour garder  ·  à gauche pour passer",
    mealsLeft:              "restants",
    skip:                   "Passer",
    save:                   "Garder",
    tryStamp:               "ESSAYER",
    nopeStamp:              "NON",
    savedToTryList:         "Ajouté à la liste",
    dislikedLabel:          "Pas aimé",
    ingredients:            "Ingrédients",
    howToCook:              "Comment cuisiner",
    loadingRecipe:          "Chargement de la recette…",
    watchAndRead:           "Voir & Lire",
    watchOnYoutube:         "Voir sur YouTube",
    originalRecipe:         "Recette originale",
    viewFullRecipe:         "Voir la recette complète",
    moreStepsFormat:        "+%d étapes",
    stepsCountFormat:       "%d étapes",
    ingredientsCountFormat: "%d ingrédients",
    tryListTitle:           "J'aime",
    searchSavedPrompt:      "Rechercher mes favoris…",
    nothingSavedYet:        "Rien aimé pour l'instant",
    swipeRightHint:         "Glissez à droite pour ajouter ici.",
    dislikedTitle:          "Pas aimé",
    searchDislikedPrompt:   "Rechercher les plats rejetés…",
    noRejectedMeals:        "Aucun plat rejeté",
    swipeLeftHint:          "Glissez à gauche pour déplacer ici.",
    settingsTitle:          "Réglages",
    appSubtitle:            "Découvrez votre prochain plat préféré",
    dataManagement:         "Gestion des données",
    clearTryList:           "Vider la liste",
    clearTryListSub:        "Supprimer tous les plats sauvegardés",
    clearDisliked:          "Vider les non-aimés",
    clearDislikedSub:       "Supprimer tous les plats rejetés",
    resetSwipeHistory:      "Réinitialiser l'historique",
    resetSwipeHistorySub:   "Les plats glissés réapparaîtront",
    resetEverything:        "Tout réinitialiser",
    resetEverythingSub:     "Supprime toutes les données",
    about:                  "À propos",
    version:                "Version",
    poweredBy:              "Propulsé par TheMealDB",
    clearAll:               "Tout effacer",
    resetHistory:           "Réinitialiser",
    resetAllData:           "Tout réinitialiser",
    clearTryConfirm:        "Vider la liste ?",
    clearDislikedConfirm:   "Vider les non-aimés ?",
    resetSwipeConfirm:      "Réinitialiser l'historique ?",
    resetAllConfirm:        "Réinitialiser toutes les données ?",
    toastSwipeCleared:      "Historique effacé ✓",
    toastTryCleared:        "Liste vidée ✓",
    toastDislikedCleared:   "Non-aimés effacés ✓",
    toastAllReset:          "Toutes les données réinitialisées ✓",
    language:               "Langue",
    languageSub:            "Langue d'affichage",
    tabDiscover:            "Découvrir",
    tabTryList:             "J'aime",
    tabDisliked:            "Pas aimé",
    tabSettings:            "Réglages",
    rateMeal:               "Évaluer ce plat",
    yourRating:             "Votre note",
    overallScore:           "Général",
    tasteScore:             "Goût",
    wouldEatAgain:          "Vous remangeriez ?",
    wouldRecommend:         "Vous recommanderiez ?",
    saveRating:             "Sauvegarder la note",
    editRating:             "Modifier la note",
    sheetDismissHint:       "Appuyez sur × pour fermer · ou glissez vers le bas",
    addedToLiked:           "Ajouté aux favoris",
    goToDetail:             "Voir le détail",
    categoryOther:          "Autre",
    tabMealPlan:            "Plan Repas",
    mealPlanTitle:          "Plan Repas",
    addToPlan:              "Ajouter au Plan",
    selectDate:             "Sélectionner une date",
    planReminderNote:       "Rappel à 8h00 et à 18h00",
    confirmPlan:            "Ajouter au Plan",
    noMealsPlanned:         "Aucun repas planifié",
    noMealsPlannedHint:     "Ouvre un plat et appuie sur l’icône calendrier.",
    mealPlanAdded:          "Ajouté au plan ✓",
    upcomingPlans:          "À venir",
    pastPlans:              "Passés",
    clearMealPlan:          "Vider le Plan Repas",
    clearMealPlanSub:       "Supprimer tous les repas planifiés",
    clearMealPlanConfirm:   "Vider le plan ?",
    toastMealPlanCleared:   "Plan repas vidé ✓",
    notificationsTitle:     "Notifications",
    dailyReminder:          "Rappel quotidien",
    dailyReminderSub:       "Recevez une suggestion de plat chaque jour",
    reminderTime:           "Heure du rappel",
    toastNotifEnabled:      "Rappel quotidien activé ✓",
    toastNotifDisabled:     "Rappel quotidien désactivé ✓",
    planReminders:          "Rappels du Plan",
    planRemindersSub:       "Définissez les heures pour vos repas planifiés",
    morningReminder:        "Matin",
    eveningReminder:        "Soir",
    notifPermissionDenied:  "Activez les notifications dans Réglages",
    addSecondReminder:      "Ajouter un 2e rappel",
    removeSecondReminder:   "Supprimer le 2e rappel",
    themeOnboardingTitle:   "Quel style vous plaît ?",
    themeOnboardingSubtitle: "Choisissez l'apparence qui vous convient. Vous pourrez la modifier dans Réglages.",
    themeLight:             "Clair",
    themeDark:              "Sombre",
    themeContinue:          "Continuer",
    themeChangeHint:        "Vous pouvez changer cela à tout moment dans Réglages → Apparence",
    themeSection:           "Apparence",
    themeSystem:            "Par défaut du système",
    themeRecommended:       "Recommandé",
    filterAll:              "Tous",
    filterCategories:       "Catégories",
    rateApp:                "Noter l'App",
    rateAppSub:             "Partagez votre avis sur l'App Store",
    rateAppPopupTitle:      "Vous appréciez l'app ?",
    rateAppPopupMessage:    "Une note rapide nous aide à grandir et améliorer les recettes.",
    rateNow:                "Noter Maintenant ★",
    notNow:                 "Pas maintenant",
    updateAvailableTitle:   "Mise à Jour Disponible",
    updateAvailableMessage: "La version %@ est disponible.",
    updateCurrentVersion:   "Vous avez la version %@",
    updateNow:              "Mettre à Jour",
    updateLater:            "Plus tard",
    onboardSlide1Title:     "Découvrez de Nouveaux Plats",
    onboardSlide1Sub:       "Faites défiler des centaines de recettes du monde entier. Votre prochain favori est à un glissement.",
    onboardSlide2Title:     "Glissez à Droite pour Garder",
    onboardSlide2Sub:       "Un plat vous plaît ? Glissez à droite, il rejoint votre liste perso, prêt quand vous voulez.",
    onboardSlide3Title:     "Glissez à Gauche pour Passer",
    onboardSlide3Sub:       "Pas envie ? Glissez à gauche et on vous montrera mieux. Rien ne reste éternellement.",
    onboardSlide4Title:     "Planifiez votre Semaine",
    onboardSlide4Sub:       "Ajoutez des plats à votre plan et recevez des rappels. Ne ratez plus un repas fait maison.",
    onboardSlide5Title:     "Recettes dans votre Langue",
    onboardSlide5Sub:       "Tout se traduit dans votre langue, sur l'appareil, en toute confidentialité.",
    onboardGetStarted:      "Commencer",
    onboardNext:            "Suivant",
    onboardSkip:            "Passer"
)

private let italianTranslations = Translations(
    appName:                "Ricette di Cucina",
    appTagline:             "scorri a destra per salvare  ·  a sinistra per saltare",
    mealsLeft:              "rimanenti",
    skip:                   "Salta",
    save:                   "Salva",
    tryStamp:               "PROVA",
    nopeStamp:              "NO",
    savedToTryList:         "Aggiunto alla lista",
    dislikedLabel:          "Non mi piace",
    ingredients:            "Ingredienti",
    howToCook:              "Come cucinare",
    loadingRecipe:          "Caricamento ricetta…",
    watchAndRead:           "Guarda & Leggi",
    watchOnYoutube:         "Guarda su YouTube",
    originalRecipe:         "Ricetta originale",
    viewFullRecipe:         "Vedi ricetta completa",
    moreStepsFormat:        "+%d altri passaggi",
    stepsCountFormat:       "%d passaggi",
    ingredientsCountFormat: "%d ingredienti",
    tryListTitle:           "Mi piace",
    searchSavedPrompt:      "Cerca i preferiti…",
    nothingSavedYet:        "Nessun preferito ancora",
    swipeRightHint:         "Scorri a destra per aggiungere qui.",
    dislikedTitle:          "Non mi piace",
    searchDislikedPrompt:   "Cerca pasti rifiutati…",
    noRejectedMeals:        "Nessun pasto rifiutato",
    swipeLeftHint:          "Scorri a sinistra per spostare qui.",
    settingsTitle:          "Impostazioni",
    appSubtitle:            "Scopri il tuo prossimo pasto preferito",
    dataManagement:         "Gestione dati",
    clearTryList:           "Svuota lista",
    clearTryListSub:        "Rimuovi tutti i pasti salvati",
    clearDisliked:          "Svuota non mi piace",
    clearDislikedSub:       "Rimuovi tutti i pasti rifiutati",
    resetSwipeHistory:      "Reimposta la cronologia",
    resetSwipeHistorySub:   "I pasti scorretti riappariranno",
    resetEverything:        "Reimposta tutto",
    resetEverythingSub:     "Cancella tutti i dati",
    about:                  "Informazioni",
    version:                "Versione",
    poweredBy:              "Offerto da TheMealDB",
    clearAll:               "Cancella tutto",
    resetHistory:           "Reimposta cronologia",
    resetAllData:           "Reimposta tutto",
    clearTryConfirm:        "Svuotare la lista?",
    clearDislikedConfirm:   "Svuotare non mi piace?",
    resetSwipeConfirm:      "Reimpostare la cronologia?",
    resetAllConfirm:        "Reimpostare tutti i dati?",
    toastSwipeCleared:      "Cronologia cancellata ✓",
    toastTryCleared:        "Lista svuotata ✓",
    toastDislikedCleared:   "Non mi piace svuotato ✓",
    toastAllReset:          "Tutti i dati reimpostati ✓",
    language:               "Lingua",
    languageSub:            "Lingua dell'app",
    tabDiscover:            "Scopri",
    tabTryList:             "Mi piace",
    tabDisliked:            "Non mi piace",
    tabSettings:            "Impostazioni",
    rateMeal:               "Valuta questo pasto",
    yourRating:             "La tua valutazione",
    overallScore:           "Generale",
    tasteScore:             "Gusto",
    wouldEatAgain:          "Lo mangeresti di nuovo?",
    wouldRecommend:         "Lo consiglieresti?",
    saveRating:             "Salva valutazione",
    editRating:             "Modifica valutazione",
    sheetDismissHint:       "Tocca × per chiudere · o scorri verso il basso",
    addedToLiked:           "Aggiunto ai preferiti",
    goToDetail:             "Vedi dettaglio",
    categoryOther:          "Altro",
    tabMealPlan:            "Piano Pasti",
    mealPlanTitle:          "Piano Pasti",
    addToPlan:              "Aggiungi al Piano",
    selectDate:             "Seleziona Data",
    planReminderNote:       "Verrai ricordato alle 8:00 e alle 18:00",
    confirmPlan:            "Aggiungi al Piano",
    noMealsPlanned:         "Nessun pasto pianificato",
    noMealsPlannedHint:     "Apri un pasto e tocca l’icona del calendario.",
    mealPlanAdded:          "Aggiunto al piano ✓",
    upcomingPlans:          "In arrivo",
    pastPlans:              "Passati",
    clearMealPlan:          "Svuota Piano Pasti",
    clearMealPlanSub:       "Rimuovi tutti i pasti pianificati",
    clearMealPlanConfirm:   "Svuotare il piano?",
    toastMealPlanCleared:   "Piano pasti svuotato ✓",
    notificationsTitle:     "Notifiche",
    dailyReminder:          "Promemoria giornaliero",
    dailyReminderSub:       "Ricevi un suggerimento di pasto ogni giorno",
    reminderTime:           "Ora del promemoria",
    toastNotifEnabled:      "Promemoria giornaliero attivato ✓",
    toastNotifDisabled:     "Promemoria giornaliero disattivato ✓",
    planReminders:          "Promemoria del Piano",
    planRemindersSub:       "Imposta gli orari per i tuoi pasti pianificati",
    morningReminder:        "Mattina",
    eveningReminder:        "Sera",
    notifPermissionDenied:  "Attiva le notifiche nelle Impostazioni",
    addSecondReminder:      "Aggiungi secondo promemoria",
    removeSecondReminder:   "Rimuovi secondo promemoria",
    themeOnboardingTitle:   "Come preferisci?",
    themeOnboardingSubtitle: "Scegli l'aspetto che preferisci. Potrai cambiarlo nelle Impostazioni.",
    themeLight:             "Chiaro",
    themeDark:              "Scuro",
    themeContinue:          "Continua",
    themeChangeHint:        "Puoi cambiarlo in qualsiasi momento in Impostazioni → Aspetto",
    themeSection:           "Aspetto",
    themeSystem:            "Predefinito di sistema",
    themeRecommended:       "Consigliato",
    filterAll:              "Tutti",
    filterCategories:       "Categorie",
    rateApp:                "Valuta l'App",
    rateAppSub:             "Condividi il tuo parere sull'App Store",
    rateAppPopupTitle:      "Ti piace l'app?",
    rateAppPopupMessage:    "Una valutazione rapida ci aiuta a crescere e migliorare le ricette.",
    rateNow:                "Valuta Ora ★",
    notNow:                 "Non ora",
    updateAvailableTitle:   "Aggiornamento Disponibile",
    updateAvailableMessage: "La versione %@ è disponibile.",
    updateCurrentVersion:   "Hai la versione %@",
    updateNow:              "Aggiorna Ora",
    updateLater:            "Più tardi",
    onboardSlide1Title:     "Scopri Nuovi Pasti",
    onboardSlide1Sub:       "Scorri tra centinaia di ricette da tutto il mondo. Il tuo prossimo preferito è a un tocco.",
    onboardSlide2Title:     "Scorri a Destra per Salvare",
    onboardSlide2Sub:       "Ti piace? Scorri a destra e finisce nella tua lista, pronto quando vuoi.",
    onboardSlide3Title:     "Scorri a Sinistra per Saltare",
    onboardSlide3Sub:       "Non ti convince? Scorri a sinistra e ti mostremo qualcosa di meglio.",
    onboardSlide4Title:     "Pianifica la tua Settimana",
    onboardSlide4Sub:       "Aggiungi pasti al piano settimanale e ricevi promemoria. Mai più un pasto casalingo perso.",
    onboardSlide5Title:     "Ricette nella tua Lingua",
    onboardSlide5Sub:       "Tutto si traduce nella tua lingua, sul dispositivo, in privato. Nessuna connessione necessaria.",
    onboardGetStarted:      "Inizia",
    onboardNext:            "Avanti",
    onboardSkip:            "Salta"
)
