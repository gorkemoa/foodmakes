import SwiftUI
import Observation

@MainActor
@Observable
final class TryListViewModel {

    var meals: [PersistedTryMeal] = []
    var ratings: [String: Int] = [:]  // mealId → overallScore
    var searchText = ""
    var selectedMealForDetail: Meal?
    var showDetail = false

    let repository: MealRepository
    private let service: MealService

    init(repository: MealRepository) {
        self.repository = repository
        self.service = MealService()
    }

    var filtered: [PersistedTryMeal] {
        if searchText.isEmpty { return meals }
        return meals.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            ($0.category?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }

    /// Meals grouped by category, sorted alphabetically. Nil-category meals go last under key "".
    var groupedFiltered: [(key: String, meals: [PersistedTryMeal])] {
        let source = filtered
        var dict: [String: [PersistedTryMeal]] = [:]
        for meal in source {
            let key = meal.category ?? ""
            dict[key, default: []].append(meal)
        }
        return dict
            .sorted { a, b in
                if a.key.isEmpty { return false }
                if b.key.isEmpty { return true }
                return a.key < b.key
            }
            .map { (key: $0.key, meals: $0.value) }
    }

    func load() {
        meals = (try? repository.fetchTryList()) ?? []
        let allRatings = (try? repository.fetchAllRatings()) ?? []
        ratings = Dictionary(uniqueKeysWithValues: allRatings.map { ($0.mealId, $0.overallScore) })
    }

    func remove(id: String) {
        try? repository.removeFromTryList(id: id)
        meals.removeAll { $0.id == id }
    }

    func tapMeal(_ persisted: PersistedTryMeal) {
        Task {
            if let detail = try? await service.fetchMealDetail(id: persisted.id) {
                selectedMealForDetail = detail
                showDetail = true
            }
        }
    }
}
