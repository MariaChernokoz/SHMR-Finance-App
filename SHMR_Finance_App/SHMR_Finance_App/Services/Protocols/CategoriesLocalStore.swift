import Foundation

@MainActor
protocol CategoriesLocalStore {
    func fetchAllCategories() async throws -> [Category]
    func addCategory(_ category: Category) async throws
    func updateCategory(_ category: Category) async throws
    func deleteCategory(by id: Int) async throws
} 