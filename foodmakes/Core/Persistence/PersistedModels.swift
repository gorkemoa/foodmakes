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

// MARK: - PersistedMealPlan
@Model
final class PersistedMealPlan {
    var planId: String          // unique UUID
    var mealId: String
    var mealName: String
    var thumbnailURL: String?
    var plannedDate: Date
    var morningNotifId: String
    var eveningNotifId: String
    var addedAt: Date

    init(mealId: String, mealName: String, thumbnailURL: String?,
         plannedDate: Date, morningNotifId: String, eveningNotifId: String) {
        self.planId        = UUID().uuidString
        self.mealId        = mealId
        self.mealName      = mealName
        self.thumbnailURL  = thumbnailURL
        self.plannedDate   = plannedDate
        self.morningNotifId = morningNotifId
        self.eveningNotifId = eveningNotifId
        self.addedAt       = .now
    }
}

// MARK: - PersistedMealRating
@Model
final class PersistedMealRating {
    @Attribute(.unique) var mealId: String
    var mealName: String
    var thumbnailURL: String?
    var overallScore: Int   // 1–5  (genel puan)
    var tasteScore: Int     // 1–5  (lezzet)
    var wouldEatAgain: Bool // tekrar yer mi
    var wouldRecommend: Bool // önerir mi
    var ratedAt: Date

    init(mealId: String, mealName: String, thumbnailURL: String? = nil,
         overallScore: Int, tasteScore: Int,
         wouldEatAgain: Bool, wouldRecommend: Bool) {
        self.mealId = mealId
        self.mealName = mealName
        self.thumbnailURL = thumbnailURL
        self.overallScore = overallScore
        self.tasteScore = tasteScore
        self.wouldEatAgain = wouldEatAgain
        self.wouldRecommend = wouldRecommend
        self.ratedAt = .now
    }
}
