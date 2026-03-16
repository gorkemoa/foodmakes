import Foundation

// MARK: - Raw API Response: Meal List
struct MealListResponse: Decodable {
    let meals: [MealSummaryDTO]?
}

struct MealSummaryDTO: Decodable {
    let idMeal: String
    let strMeal: String
    let strMealThumb: String?
}

// MARK: - Raw API Response: Meal Detail
struct MealDetailResponse: Decodable {
    let meals: [MealDetailDTO]?
}

struct MealDetailDTO: Decodable {
    let idMeal: String
    let strMeal: String
    let strCategory: String?
    let strArea: String?
    let strInstructions: String?
    let strMealThumb: String?
    let strYoutube: String?
    let strSource: String?

    // Ingredient/Measure pairs (API has up to 20)
    let strIngredient1: String?;  let strMeasure1: String?
    let strIngredient2: String?;  let strMeasure2: String?
    let strIngredient3: String?;  let strMeasure3: String?
    let strIngredient4: String?;  let strMeasure4: String?
    let strIngredient5: String?;  let strMeasure5: String?
    let strIngredient6: String?;  let strMeasure6: String?
    let strIngredient7: String?;  let strMeasure7: String?
    let strIngredient8: String?;  let strMeasure8: String?
    let strIngredient9: String?;  let strMeasure9: String?
    let strIngredient10: String?; let strMeasure10: String?
    let strIngredient11: String?; let strMeasure11: String?
    let strIngredient12: String?; let strMeasure12: String?
    let strIngredient13: String?; let strMeasure13: String?
    let strIngredient14: String?; let strMeasure14: String?
    let strIngredient15: String?; let strMeasure15: String?
    let strIngredient16: String?; let strMeasure16: String?
    let strIngredient17: String?; let strMeasure17: String?
    let strIngredient18: String?; let strMeasure18: String?
    let strIngredient19: String?; let strMeasure19: String?
    let strIngredient20: String?; let strMeasure20: String?

    // MARK: - Parse to domain model
    nonisolated func toDomain() -> Meal {
        let rawPairs: [(String?, String?)] = [
            (strIngredient1, strMeasure1), (strIngredient2, strMeasure2),
            (strIngredient3, strMeasure3), (strIngredient4, strMeasure4),
            (strIngredient5, strMeasure5), (strIngredient6, strMeasure6),
            (strIngredient7, strMeasure7), (strIngredient8, strMeasure8),
            (strIngredient9, strMeasure9), (strIngredient10, strMeasure10),
            (strIngredient11, strMeasure11), (strIngredient12, strMeasure12),
            (strIngredient13, strMeasure13), (strIngredient14, strMeasure14),
            (strIngredient15, strMeasure15), (strIngredient16, strMeasure16),
            (strIngredient17, strMeasure17), (strIngredient18, strMeasure18),
            (strIngredient19, strMeasure19), (strIngredient20, strMeasure20)
        ]

        let ingredients = rawPairs
            .compactMap { pair -> IngredientItem? in
                guard let name = pair.0, !name.trimmingCharacters(in: .whitespaces).isEmpty else { return nil }
                let measure = pair.1?.trimmingCharacters(in: .whitespaces) ?? ""
                return IngredientItem(name: name.trimmingCharacters(in: .whitespaces), measure: measure)
            }

        return Meal(
            id: idMeal,
            name: strMeal,
            category: strCategory,
            area: strArea,
            instructions: strInstructions,
            thumbnailURL: strMealThumb,
            youtubeURL: strYoutube,
            sourceURL: strSource,
            ingredients: ingredients
        )
    }
}
