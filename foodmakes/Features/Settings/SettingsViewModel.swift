import SwiftUI
import Observation

@MainActor
@Observable
final class SettingsViewModel {

    var showResetConfirm = false
    var showResetAllConfirm = false
    var showClearTryConfirm = false
    var showClearDislikedConfirm = false
    var toastMessage: String?
    var showToast = false

    private let repository: MealRepository

    init(repository: MealRepository) {
        self.repository = repository
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
