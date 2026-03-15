import Foundation
import SwiftData

// MARK: - PersistedTryMeal
@Model
final class PersistedTryMeal {
    @Attribute(.unique) var id: String
    var name: String
    var category: String?
    var area: String?
    var thumbnailURL: String?
    var savedAt: Date

    init(meal: Meal, savedAt: Date = .now) {
        self.id = meal.id
        self.name = meal.name
        self.category = meal.category
        self.area = meal.area
        self.thumbnailURL = meal.thumbnailURL
        self.savedAt = savedAt
    }
}

// MARK: - PersistedDislikedMeal
@Model
final class PersistedDislikedMeal {
    @Attribute(.unique) var id: String
    var name: String
    var category: String?
    var area: String?
    var thumbnailURL: String?
    var savedAt: Date

    init(meal: Meal, savedAt: Date = .now) {
        self.id = meal.id
        self.name = meal.name
        self.category = meal.category
        self.area = meal.area
        self.thumbnailURL = meal.thumbnailURL
        self.savedAt = savedAt
    }
}

// MARK: - SwipedRecord
@Model
final class SwipedRecord {
    @Attribute(.unique) var mealId: String
    var swipedAt: Date
    var directionRaw: String // "left" | "right"

    init(mealId: String, direction: SwipeDirection, swipedAt: Date = .now) {
        self.mealId = mealId
        self.swipedAt = swipedAt
        self.directionRaw = direction == .left ? "left" : "right"
    }

    var direction: SwipeDirection {
        directionRaw == "left" ? .left : .right
    }
}
