import SwiftUI
import Observation

@MainActor
@Observable
final class DislikedViewModel {

    var meals: [PersistedDislikedMeal] = []
    var searchText = ""
    var selectedMealForDetail: Meal?
    var showDetail = false

    let repository: MealRepository
    private let service: MealService

    init(repository: MealRepository) {
        self.repository = repository
        self.service = MealService()
    }

    var filtered: [PersistedDislikedMeal] {
        if searchText.isEmpty { return meals }
        return meals.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            ($0.category?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }

    func load() {
        meals = (try? repository.fetchDisliked()) ?? []
    }

    func remove(id: String) {
        try? repository.removeFromDisliked(id: id)
        meals.removeAll { $0.id == id }
    }

    func tapMeal(_ persisted: PersistedDislikedMeal) {
        Task {
            if let detail = try? await service.fetchMealDetail(id: persisted.id) {
                selectedMealForDetail = detail
                showDetail = true
            }
        }
    }
}
