import SwiftUI
import Observation

@MainActor
@Observable
final class TryListViewModel {

    var meals: [PersistedTryMeal] = []
    var searchText = ""
    var selectedMealForDetail: Meal?
    var showDetail = false

    let repository: MealRepository
    private let service: MealService

    init(repository: MealRepository, service: MealService = MealService()) {
        self.repository = repository
        self.service = service
    }

    var filtered: [PersistedTryMeal] {
        if searchText.isEmpty { return meals }
        return meals.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            ($0.category?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }

    func load() {
        meals = (try? repository.fetchTryList()) ?? []
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
