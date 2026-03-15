import Foundation

// MARK: - Meal (domain model - in-memory display)
struct Meal: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let category: String?
    let area: String?
    let instructions: String?
    let thumbnailURL: String?
    let youtubeURL: String?
    let sourceURL: String?
    let ingredients: [IngredientItem]

    var thumbnailLink: URL? { thumbnailURL.flatMap(URL.init) }
    var youtubeLink: URL? { youtubeURL.flatMap(URL.init) }
    var sourceLink: URL? { sourceURL.flatMap(URL.init) }

    // Short ingredient preview (first 3 items)
    var ingredientPreview: String {
        ingredients.prefix(3).map(\.name).joined(separator: " · ")
    }
}

// MARK: - IngredientItem
struct IngredientItem: Identifiable, Hashable, Codable {
    var id: String { "\(name)-\(measure)" }
    let name: String
    let measure: String
}

// MARK: - Swipe Direction
enum SwipeDirection {
    case left   // Disliked
    case right  // Liked (Try List)
}

// MARK: - Meal List States
enum LoadState<T> {
    case idle
    case loading
    case loaded(T)
    case empty
    case failed(String)
}
