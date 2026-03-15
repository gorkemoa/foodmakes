import SwiftUI
import Observation

@MainActor
@Observable
final class MealDetailViewModel {

    var meal: Meal
    var isInTryList: Bool = false
    var isDisliked: Bool = false
    var loadedFullDetail: Meal?
    var isLoadingDetail = false

    private let repository: MealRepository
    private let service: MealService

    init(meal: Meal, repository: MealRepository, service: MealService = MealService()) {
        self.meal = meal
        self.repository = repository
        self.service = service
        refreshStatus()
    }

    func loadDetailIfNeeded() async {
        guard meal.instructions == nil else { return }
        isLoadingDetail = true
        defer { isLoadingDetail = false }
        if let detail = try? await service.fetchMealDetail(id: meal.id) {
            meal = detail
            loadedFullDetail = detail
        }
    }

    func refreshStatus() {
        isInTryList = repository.isInTryList(id: meal.id)
        isDisliked = repository.isDisliked(id: meal.id)
    }

    func toggleTryList() {
        do {
            if isInTryList {
                try repository.removeFromTryList(id: meal.id)
            } else {
                try repository.addToTryList(meal: meal)
            }
            refreshStatus()
        } catch { print("[MealDetailVM] toggleTryList error: \(error)") }
    }
}
