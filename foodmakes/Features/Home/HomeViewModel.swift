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

    // MARK: - Ad tracking (show native ad every 7th swipe)
    private(set) var mealSwipesSinceLastAd: Int = 0
    var isAdTurn: Bool { mealSwipesSinceLastAd >= 6 }   // 6 meals → ad slot

    func dismissAd() {
        mealSwipesSinceLastAd = 0
    }

    // MARK: - Dependencies
    private let service: MealService
    private(set) var repository: MealRepository

    init(service: MealService, repository: MealRepository) {
        self.service = service
        self.repository = repository
    }

    // MARK: - Load Meals
    func loadMeals() async {
        loadState = .loading
        do {
            let swipedIds = Set((try? repository.fetchSwipedIds()) ?? [])
            // Fetch more than needed so we have enough after filtering already-swiped meals
            var batch = try await service.fetchRandomMeals(count: 20)
            batch = batch.filter { !swipedIds.contains($0.id) }

            if batch.isEmpty {
                loadState = .empty
            } else {
                meals = batch
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
        mealSwipesSinceLastAd += 1
    }

    func swipeRight(meal: Meal) {
        persist(meal: meal, direction: .right)
        removeFromDeck(meal)
        mealSwipesSinceLastAd += 1
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
            if direction == .right {
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
