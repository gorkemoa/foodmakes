import SwiftUI
import Observation

@MainActor
@Observable
final class HomeViewModel {

    // MARK: - State
    var meals: [Meal] = []
    var loadState: LoadState<[Meal]> = .idle
    var selectedMeal: Meal?
    var showDetail = false

    // MARK: - Dependencies
    private let service: MealService
    private(set) var repository: MealRepository

    // MARK: - Categories to cycle through
    private let categories = ["Seafood", "Chicken", "Beef", "Vegetarian", "Pasta", "Dessert", "Lamb"]
    private var categoryIndex = 0

    init(service: MealService, repository: MealRepository) {
        self.service = service
        self.repository = repository
    }

    // MARK: - Load Meals
    func loadMeals() async {
        loadState = .loading
        do {
            let swipedIds = (try? repository.fetchSwipedIds()) ?? []
            let category = categories[categoryIndex % categories.count]
            categoryIndex += 1
            let fetched = try await service.fetchMeals(category: category)
            let filtered = fetched.filter { !swipedIds.contains($0.id) }
            if filtered.isEmpty {
                loadState = .empty
            } else {
                meals = filtered.shuffled()
                loadState = .loaded(meals)
            }
        } catch {
            loadState = .failed(error.localizedDescription)
        }
    }

    // MARK: - Swipe Actions
    func swipeLeft(meal: Meal) {
        persist(meal: meal, direction: .left)
        removeFromDeck(meal)
    }

    func swipeRight(meal: Meal) {
        persist(meal: meal, direction: .right)
        removeFromDeck(meal)
    }

    func tapCard(_ meal: Meal) {
        selectedMeal = meal
        showDetail = true
    }

    // MARK: - Private
    private func removeFromDeck(_ meal: Meal) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            meals.removeAll { $0.id == meal.id }
            if meals.isEmpty { loadState = .empty }
        }
    }

    private func persist(meal: Meal, direction: SwipeDirection) {
        do {
            try repository.recordSwipe(meal: meal, direction: direction)
            if direction == .left {
                try repository.addToTryList(meal: meal)
            } else {
                try repository.addToDisliked(meal: meal)
            }
        } catch {
            // Non-fatal persistence error — silently log in production
            print("[HomeViewModel] Persistence error: \(error)")
        }
    }
}
