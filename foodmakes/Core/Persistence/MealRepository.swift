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

    // MARK: - Ratings

    func saveRating(mealId: String, mealName: String, thumbnailURL: String?,
                    overallScore: Int, tasteScore: Int,
                    wouldEatAgain: Bool, wouldRecommend: Bool) throws {
        let existing = try fetchRating(mealId: mealId)
        if let r = existing {
            r.overallScore = overallScore
            r.tasteScore = tasteScore
            r.wouldEatAgain = wouldEatAgain
            r.wouldRecommend = wouldRecommend
            r.ratedAt = .now
        } else {
            context.insert(PersistedMealRating(
                mealId: mealId, mealName: mealName, thumbnailURL: thumbnailURL,
                overallScore: overallScore, tasteScore: tasteScore,
                wouldEatAgain: wouldEatAgain, wouldRecommend: wouldRecommend))
        }
        try context.save()
    }

    func fetchRating(mealId: String) throws -> PersistedMealRating? {
        try context.fetch(
            FetchDescriptor<PersistedMealRating>(predicate: #Predicate { $0.mealId == mealId })
        ).first
    }

    func hasRating(mealId: String) -> Bool {
        let desc = FetchDescriptor<PersistedMealRating>(predicate: #Predicate { $0.mealId == mealId })
        return (try? context.fetchCount(desc)) ?? 0 > 0
    }

    func fetchAllRatings() throws -> [PersistedMealRating] {
        try context.fetch(FetchDescriptor<PersistedMealRating>(
            sortBy: [SortDescriptor(\.ratedAt, order: .reverse)]
        ))
    }

    func clearRatings() throws {
        try context.fetch(FetchDescriptor<PersistedMealRating>()).forEach { context.delete($0) }
        try context.save()
    }

    // MARK: - Reset All

    func resetAll() throws {
        try clearTryList()
        try clearDisliked()
        try clearSwipeHistory()
        try clearRatings()
        try clearMealPlan()
    }

    // MARK: - Meal Plan

    func addToPlan(mealId: String, mealName: String, thumbnailURL: String?,
                   plannedDate: Date, morningNotifId: String, eveningNotifId: String) throws {
        let dayStart = Calendar.current.startOfDay(for: plannedDate)
        let dayEnd   = Calendar.current.date(byAdding: .day, value: 1, to: dayStart)!
        let mId = mealId
        let existing = try context.fetch(
            FetchDescriptor<PersistedMealPlan>(
                predicate: #Predicate { $0.mealId == mId && $0.plannedDate >= dayStart && $0.plannedDate < dayEnd }
            )
        )
        guard existing.isEmpty else { return }
        context.insert(PersistedMealPlan(
            mealId: mealId, mealName: mealName, thumbnailURL: thumbnailURL,
            plannedDate: plannedDate, morningNotifId: morningNotifId, eveningNotifId: eveningNotifId
        ))
        try context.save()
    }

    /// Returns the notification IDs that were removed so caller can cancel them.
    @discardableResult
    func removeFromPlan(planId: String) throws -> (morningNotifId: String, eveningNotifId: String)? {
        let pId = planId
        let items = try context.fetch(
            FetchDescriptor<PersistedMealPlan>(predicate: #Predicate { $0.planId == pId })
        )
        guard let item = items.first else { return nil }
        let ids = (item.morningNotifId, item.eveningNotifId)
        context.delete(item)
        try context.save()
        return ids
    }

    func fetchPlan() throws -> [PersistedMealPlan] {
        try context.fetch(FetchDescriptor<PersistedMealPlan>(
            sortBy: [SortDescriptor(\.plannedDate)]
        ))
    }

    func isPlanned(mealId: String) -> Bool {
        let mId = mealId
        let desc = FetchDescriptor<PersistedMealPlan>(predicate: #Predicate { $0.mealId == mId })
        return (try? context.fetchCount(desc)) ?? 0 > 0
    }

    func clearMealPlan() throws {
        let plans = try context.fetch(FetchDescriptor<PersistedMealPlan>())
        let allIds = plans.flatMap { [$0.morningNotifId, $0.eveningNotifId] }
        NotificationManager.shared.cancelNotifications(ids: allIds)
        plans.forEach { context.delete($0) }
        try context.save()
    }
}
