import Foundation

// MARK: - API Endpoints
enum MealEndpoint {
    static let baseURL = "https://www.themealdb.com/api/json/v1/1"

    case listByCategory(String)
    case search(String)
    case random
    case detail(id: String)
    case categories

    var url: URL? {
        switch self {
        case .listByCategory(let cat):
            return URL(string: "\(MealEndpoint.baseURL)/filter.php?c=\(cat.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? cat)")
        case .search(let query):
            return URL(string: "\(MealEndpoint.baseURL)/search.php?s=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query)")
        case .random:
            return URL(string: "\(MealEndpoint.baseURL)/random.php")
        case .detail(let id):
            return URL(string: "\(MealEndpoint.baseURL)/lookup.php?i=\(id)")
        case .categories:
            return URL(string: "\(MealEndpoint.baseURL)/categories.php")
        }
    }
}

// MARK: - Network Errors
enum NetworkError: LocalizedError {
    case invalidURL
    case decodingFailed(Error)
    case serverError(Int)
    case noData
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:           return "Invalid URL."
        case .decodingFailed:       return "Failed to parse server response."
        case .serverError(let c):   return "Server returned error \(c)."
        case .noData:               return "No data received."
        case .unknown(let e):       return e.localizedDescription
        }
    }
}

// MARK: - MealService Protocol
protocol MealServiceProtocol {
    func fetchMeals(category: String) async throws -> [Meal]
    func fetchMealDetail(id: String) async throws -> Meal
    func fetchRandomMeals(count: Int) async throws -> [Meal]
}

// MARK: - MealService Implementation
final class MealService: MealServiceProtocol {

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    // Fetch list of meals by category (returns summary only — no ingredients)
    func fetchMeals(category: String) async throws -> [Meal] {
        guard let url = MealEndpoint.listByCategory(category).url else {
            throw NetworkError.invalidURL
        }
        let (data, response) = try await session.data(from: url)
        try validateResponse(response)
        let dto = try decode(MealListResponse.self, from: data)
        let summaries = dto.meals ?? []
        // Fetch full details for all summaries in parallel
        return try await withThrowingTaskGroup(of: Meal.self) { group in
            for summary in summaries {
                group.addTask { [weak self] in
                    guard let self else { throw NetworkError.noData }
                    return try await self.fetchMealDetail(id: summary.idMeal)
                }
            }
            var results: [Meal] = []
            for try await meal in group {
                results.append(meal)
            }
            return results
        }
    }

    // Fetch full meal detail by ID
    func fetchMealDetail(id: String) async throws -> Meal {
        guard let url = MealEndpoint.detail(id: id).url else {
            throw NetworkError.invalidURL
        }
        let (data, response) = try await session.data(from: url)
        try validateResponse(response)
        let dto = try decode(MealDetailResponse.self, from: data)
        guard let detail = dto.meals?.first else { throw NetworkError.noData }
        return detail.toDomain()
    }

    // Fetch N random meals (each call returns 1 random meal from API)
    func fetchRandomMeals(count: Int) async throws -> [Meal] {
        try await withThrowingTaskGroup(of: Meal.self) { group in
            for _ in 0..<count {
                group.addTask { [weak self] in
                    guard let self,
                          let url = MealEndpoint.random.url else { throw NetworkError.invalidURL }
                    let (data, response) = try await self.session.data(from: url)
                    try self.validateResponse(response)
                    let dto = try self.decode(MealDetailResponse.self, from: data)
                    guard let detail = dto.meals?.first else { throw NetworkError.noData }
                    return detail.toDomain()
                }
            }
            var results: [Meal] = []
            var seen = Set<String>()
            for try await meal in group {
                if seen.insert(meal.id).inserted {
                    results.append(meal)
                }
            }
            return results
        }
    }

    // MARK: - Private Helpers
    private func validateResponse(_ response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else { return }
        guard (200..<300).contains(http.statusCode) else {
            throw NetworkError.serverError(http.statusCode)
        }
    }

    private func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }
}
