import Foundation
import SwiftData

// MARK: - MealRepository
@MainActor
final class MealRepository {

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    // MARK: - Try List

    func addToTryList(meal: Meal) throws {
        guard !isInTryList(id: meal.id) else { return }
        context.insert(PersistedTryMeal(meal: meal))
        try context.save()
    }

    func removeFromTryList(id: String) throws {
        let items = try context.fetch(FetchDescriptor<PersistedTryMeal>(
            predicate: #Predicate { $0.id == id }
        ))
        items.forEach { context.delete($0) }
        try context.save()
    }

    func fetchTryList() throws -> [PersistedTryMeal] {
        try context.fetch(FetchDescriptor<PersistedTryMeal>(
            sortBy: [SortDescriptor(\.savedAt, order: .reverse)]
        ))
    }

    func isInTryList(id: String) -> Bool {
        let desc = FetchDescriptor<PersistedTryMeal>(predicate: #Predicate { $0.id == id })
        return (try? context.fetchCount(desc)) ?? 0 > 0
    }

    func clearTryList() throws {
        try context.fetch(FetchDescriptor<PersistedTryMeal>()).forEach { context.delete($0) }
        try context.save()
    }

    // MARK: - Disliked

    func addToDisliked(meal: Meal) throws {
        guard !isDisliked(id: meal.id) else { return }
        context.insert(PersistedDislikedMeal(meal: meal))
        try context.save()
    }

    func removeFromDisliked(id: String) throws {
        let items = try context.fetch(FetchDescriptor<PersistedDislikedMeal>(
            predicate: #Predicate { $0.id == id }
        ))
        items.forEach { context.delete($0) }
        try context.save()
    }

    func fetchDisliked() throws -> [PersistedDislikedMeal] {
        try context.fetch(FetchDescriptor<PersistedDislikedMeal>(
            sortBy: [SortDescriptor(\.savedAt, order: .reverse)]
        ))
    }

    func isDisliked(id: String) -> Bool {
        let desc = FetchDescriptor<PersistedDislikedMeal>(predicate: #Predicate { $0.id == id })
        return (try? context.fetchCount(desc)) ?? 0 > 0
    }

    func clearDisliked() throws {
        try context.fetch(FetchDescriptor<PersistedDislikedMeal>()).forEach { context.delete($0) }
        try context.save()
    }

    // MARK: - Swiped History

    func recordSwipe(meal: Meal, direction: SwipeDirection) throws {
        guard !hasSwiped(id: meal.id) else { return }
        context.insert(SwipedRecord(mealId: meal.id, direction: direction))
        try context.save()
    }

    func hasSwiped(id: String) -> Bool {
        let desc = FetchDescriptor<SwipedRecord>(predicate: #Predicate { $0.mealId == id })
        return (try? context.fetchCount(desc)) ?? 0 > 0
    }

    func fetchSwipedIds() throws -> Set<String> {
        let records = try context.fetch(FetchDescriptor<SwipedRecord>())
        return Set(records.map(\.mealId))
    }

    func clearSwipeHistory() throws {
        try context.fetch(FetchDescriptor<SwipedRecord>()).forEach { context.delete($0) }
        try context.save()
    }

    // MARK: - Reset All

    func resetAll() throws {
        try clearTryList()
        try clearDisliked()
        try clearSwipeHistory()
    }
}
