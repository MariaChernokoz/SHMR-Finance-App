import Foundation

@MainActor
protocol CategoriesLocalStore {
    func fetchAllCategories() async throws -> [Category]
} 