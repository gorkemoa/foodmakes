import SwiftUI
import Observation

@MainActor
@Observable
final class MealPlanViewModel {

    var plans: [PersistedMealPlan] = []
    var showClearConfirm = false
    var selectedDate: Date? = nil

    private let repository: MealRepository

    init(repository: MealRepository) {
        self.repository = repository
        refresh()
    }

    func refresh() {
        plans = (try? repository.fetchPlan()) ?? []
    }

    func delete(plan: PersistedMealPlan) {
        if let ids = try? repository.removeFromPlan(planId: plan.planId) {
            NotificationManager.shared.cancelMealPlanNotifications(
                morningId: ids.morningNotifId, eveningId: ids.eveningNotifId
            )
        }
        refresh()
    }

    func clearAll() {
        try? repository.clearMealPlan()
        refresh()
    }

    // MARK: - Calendar helpers

    /// All distinct calendar days that have at least one plan.
    var plannedDaySet: Set<Date> {
        Set(plans.map { Calendar.current.startOfDay(for: $0.plannedDate) })
    }

    /// Plans for the given calendar day.
    func plansForDate(_ date: Date) -> [PersistedMealPlan] {
        plans.filter { Calendar.current.isDate($0.plannedDate, inSameDayAs: date) }
    }

    // MARK: - Grouped sections
    private var grouped: [(date: Date, plans: [PersistedMealPlan])] {
        let cal = Calendar.current
        let dict = Dictionary(grouping: plans) { cal.startOfDay(for: $0.plannedDate) }
        return dict.sorted { $0.key < $1.key }.map { (date: $0.key, plans: $0.value) }
    }

    var upcomingGroups: [(date: Date, plans: [PersistedMealPlan])] {
        let today = Calendar.current.startOfDay(for: Date())
        return grouped.filter { $0.date >= today }
    }

    var pastGroups: [(date: Date, plans: [PersistedMealPlan])] {
        let today = Calendar.current.startOfDay(for: Date())
        return grouped.filter { $0.date < today }
    }
}
