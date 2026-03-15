import SwiftUI
import Observation
import UserNotifications

@MainActor
@Observable
final class SettingsViewModel {

    var showResetConfirm = false
    var showResetAllConfirm = false
    var showClearTryConfirm = false
    var showClearDislikedConfirm = false
    var showClearPlanConfirm = false
    var toastMessage: String?
    var showToast = false

    // MARK: - Notification state (mirrors NotificationManager)
    var notificationsEnabled: Bool = NotificationManager.shared.isEnabled
    var reminderDate: Date = {
        let h = NotificationManager.shared.reminderHour
        let m = NotificationManager.shared.reminderMinute
        var comps     = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        comps.hour    = h
        comps.minute  = m
        return Calendar.current.date(from: comps) ?? Date()
    }()

    var planMorningDate: Date = {
        let h = NotificationManager.shared.planMorningHour
        var comps = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        comps.hour = h; comps.minute = 0
        return Calendar.current.date(from: comps) ?? Date()
    }()

    var planEveningDate: Date = {
        let h = NotificationManager.shared.planEveningHour
        var comps = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        comps.hour = h; comps.minute = 0
        return Calendar.current.date(from: comps) ?? Date()
    }()

    private let repository: MealRepository

    init(repository: MealRepository) {
        self.repository = repository
    }

    // MARK: - Notification actions
    func toggleNotifications() async {
        let nm = NotificationManager.shared
        let status = await nm.authorizationStatus()
        if status == .denied {
            showToast(message: LanguageManager.shared.t.notifPermissionDenied)
            return
        }
        if status == .notDetermined {
            let granted = await nm.requestPermission()
            guard granted else {
                showToast(message: LanguageManager.shared.t.notifPermissionDenied)
                return
            }
        }
        nm.isEnabled = !nm.isEnabled
        notificationsEnabled = nm.isEnabled
        let msg = nm.isEnabled
            ? LanguageManager.shared.t.toastNotifEnabled
            : LanguageManager.shared.t.toastNotifDisabled
        showToast(message: msg)
    }

    func updateReminderTime(_ date: Date) {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: date)
        NotificationManager.shared.reminderHour   = comps.hour   ?? 12
        NotificationManager.shared.reminderMinute = comps.minute ?? 0
        reminderDate = date
    }

    func updatePlanMorningTime(_ date: Date) {
        let h = Calendar.current.component(.hour, from: date)
        NotificationManager.shared.planMorningHour = h
        planMorningDate = date
    }

    func updatePlanEveningTime(_ date: Date) {
        let h = Calendar.current.component(.hour, from: date)
        NotificationManager.shared.planEveningHour = h
        planEveningDate = date
    }

    func resetSwipeHistory() {
        do {
            try repository.clearSwipeHistory()
            showToast(message: LanguageManager.shared.t.toastSwipeCleared)
        } catch { showToast(message: "Error: \(error.localizedDescription)") }
    }

    func clearTryList() {
        do {
            try repository.clearTryList()
            showToast(message: LanguageManager.shared.t.toastTryCleared)
        } catch { showToast(message: "Error: \(error.localizedDescription)") }
    }

    func clearMealPlan() {
        do {
            try repository.clearMealPlan()
            showToast(message: LanguageManager.shared.t.toastMealPlanCleared)
        } catch { showToast(message: "Error: \(error.localizedDescription)") }
    }

    func clearDisliked() {
        do {
            try repository.clearDisliked()
            showToast(message: LanguageManager.shared.t.toastDislikedCleared)
        } catch { showToast(message: "Error: \(error.localizedDescription)") }
    }

    func resetAll() {
        do {
            try repository.resetAll()
            showToast(message: LanguageManager.shared.t.toastAllReset)
        } catch { showToast(message: "Error: \(error.localizedDescription)") }
    }

    private func showToast(message: String) {
        toastMessage = message
        showToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            withAnimation { self?.showToast = false }
        }
    }
}
