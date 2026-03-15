import Foundation
import UserNotifications

// MARK: - NotificationManager
// Schedules a daily local notification at the user-chosen time.
// Local notifications fire even when the app is fully closed.
@MainActor
final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {

    static let shared = NotificationManager()

    private let center = UNUserNotificationCenter.current()
    private let notificationIdentifier = "fm_daily_reminder"

    // MARK: - Persisted Settings
    var isEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "fm_notif_enabled") }
        set {
            UserDefaults.standard.set(newValue, forKey: "fm_notif_enabled")
            if newValue { scheduleDaily() } else { cancelAll() }
        }
    }

    /// Hour component of the scheduled reminder (0-23). Default: 12
    var reminderHour: Int {
        get {
            let v = UserDefaults.standard.integer(forKey: "fm_notif_hour")
            return v == 0 && !UserDefaults.standard.bool(forKey: "fm_notif_hour_set") ? 12 : v
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "fm_notif_hour")
            UserDefaults.standard.set(true, forKey: "fm_notif_hour_set")
            if isEnabled { scheduleDaily() }
        }
    }

    /// Minute component of the scheduled reminder. Default: 0
    var reminderMinute: Int {
        get { UserDefaults.standard.integer(forKey: "fm_notif_minute") }
        set {
            UserDefaults.standard.set(newValue, forKey: "fm_notif_minute")
            if isEnabled { scheduleDaily() }
        }
    }

    // MARK: - Init
    private override init() {
        super.init()
        center.delegate = self
        // Register defaults so @AppStorage wrappers read the right fallback
        UserDefaults.standard.register(defaults: [
            "fm_plan_notif_hour_m": 8,
            "fm_plan_notif_hour_e": 18
        ])
    }

    // MARK: - Permission
    /// Request authorization. Returns true if granted.
    func requestPermission() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            return false
        }
    }

    func authorizationStatus() async -> UNAuthorizationStatus {
        await center.notificationSettings().authorizationStatus
    }

    // MARK: - Scheduling
    /// Schedule (or reschedule) a repeating daily notification at reminderHour:reminderMinute.
    func scheduleDaily() {
        cancelAll()

        let lang = LanguageManager.shared.current
        let (title, body) = notificationContent(lang: lang)

        let content = UNMutableNotificationContent()
        content.title = title
        content.body  = body
        content.sound = .default

        var dateComponents         = DateComponents()
        dateComponents.hour        = reminderHour
        dateComponents.minute      = reminderMinute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: notificationIdentifier,
                                            content: content,
                                            trigger: trigger)

        center.add(request)
    }

    func cancelAll() {
        center.removePendingNotificationRequests(withIdentifiers: [notificationIdentifier])
    }

    func cancelNotifications(ids: [String]) {
        center.removePendingNotificationRequests(withIdentifiers: ids)
    }

    // MARK: - Plan Hours Settings
    // Stored directly in UserDefaults (defaults set in init) so @AppStorage
    // wrappers in views can observe them reactively.

    /// Hour (0-23) for morning meal plan reminder. Default: 8
    var planMorningHour: Int {
        get { UserDefaults.standard.integer(forKey: "fm_plan_notif_hour_m") }
        set { UserDefaults.standard.set(newValue, forKey: "fm_plan_notif_hour_m") }
    }

    /// Hour (0-23) for evening meal plan reminder. Default: 18
    var planEveningHour: Int {
        get { UserDefaults.standard.integer(forKey: "fm_plan_notif_hour_e") }
        set { UserDefaults.standard.set(newValue, forKey: "fm_plan_notif_hour_e") }
    }

    // MARK: - Meal Plan Notifications
    /// Schedules a morning and evening one-time notification for the planned date using persisted preferences.
    @discardableResult
    func scheduleMealPlanNotifications(mealId: String, mealName: String, date: Date) -> (morningId: String, eveningId: String) {
        let stamp     = Int(date.timeIntervalSince1970)
        let morningId = "fm_plan_m_\(mealId)_\(stamp)"
        let eveningId = "fm_plan_e_\(mealId)_\(stamp)"

        let lang    = LanguageManager.shared.current
        let baseDay = Calendar.current.dateComponents([.year, .month, .day], from: date)

        var morningComps = baseDay; morningComps.hour = planMorningHour; morningComps.minute = 0
        var eveningComps = baseDay; eveningComps.hour = planEveningHour; eveningComps.minute = 0

        schedulePlanNotif(id: morningId,
                          title: planMorningTitle(lang: lang, name: mealName),
                          body:  planMorningBody(lang: lang),
                          components: morningComps)
        schedulePlanNotif(id: eveningId,
                          title: planEveningTitle(lang: lang, name: mealName),
                          body:  planEveningBody(lang: lang),
                          components: eveningComps)

        return (morningId, eveningId)
    }

    func cancelMealPlanNotifications(morningId: String, eveningId: String) {
        center.removePendingNotificationRequests(withIdentifiers: [morningId, eveningId])
    }

    private func schedulePlanNotif(id: String, title: String, body: String, components: DateComponents) {
        let content   = UNMutableNotificationContent()
        content.title = title
        content.body  = body
        content.sound = .default
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        center.add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
    }

    // MARK: - Meal Plan Notification Content
    private func planMorningTitle(lang: AppLanguage, name: String) -> String {
        switch lang {
        case .turkish: return "Bugün akşam \(name) yapıyorsun! 🍳"
        case .spanish: return "¡Hoy cocinas \(name)! 🍳"
        case .french:  return "Ce soir tu cuisines \(name) ! 🍳"
        case .italian: return "Stasera cucini \(name)! 🍳"
        case .english: return "Tonight you're making \(name)! 🍳"
        }
    }
    private func planMorningBody(lang: AppLanguage) -> String {
        switch lang {
        case .turkish: return "Malzemeleri hazırlamayı unutma."
        case .spanish: return "No olvides preparar los ingredientes."
        case .french:  return "N'oublie pas de préparer les ingrédients."
        case .italian: return "Non dimenticare di preparare gli ingredienti."
        case .english: return "Don't forget to prep your ingredients."
        }
    }
    private func planEveningTitle(lang: AppLanguage, name: String) -> String {
        switch lang {
        case .turkish: return "Akşam yemeği zamanı! 🍽️"
        case .spanish: return "¡Hora de cenar! 🍽️"
        case .french:  return "C'est l'heure du dîner ! 🍽️"
        case .italian: return "È ora di cena! 🍽️"
        case .english: return "Dinner time! 🍽️"
        }
    }
    private func planEveningBody(lang: AppLanguage) -> String {
        switch lang {
        case .turkish: return "Hazır mısın? Tarife bir göz at."
        case .spanish: return "¿Listo? Echa un vistazo a la receta."
        case .french:  return "Prêt ? Consulte la recette."
        case .italian: return "Pronto? Dai un'occhiata alla ricetta."
        case .english: return "Ready? Take a look at the recipe."
        }
    }

    // MARK: - Foreground delivery
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }

    // MARK: - Content per language
    private func notificationContent(lang: AppLanguage) -> (title: String, body: String) {
        switch lang {
        case .turkish:
            return ("Ne yesek bugün? 🍽️", "Yeni bir yemek keşfetmek için uygulama açık!")
        case .spanish:
            return ("¿Qué comemos hoy? 🍽️", "¡Abre la app para descubrir una nueva receta!")
        case .french:
            return ("Qu'est-ce qu'on mange ? 🍽️", "Ouvre l'app pour découvrir un nouveau plat !")
        case .italian:
            return ("Cosa mangiamo oggi? 🍽️", "Apri l'app per scoprire un nuovo piatto!")
        case .english:
            return ("What's for dinner? 🍽️", "Open the app to discover a new meal today!")
        }
    }
}
