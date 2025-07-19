import Foundation
import SwiftData

@MainActor
final class SwiftDataCategoriesLocalStore: CategoriesLocalStore {
    private let container: ModelContainer
    private let context: ModelContext

    init() throws {
        let schema = Schema([TransactionEntity.self, BackupTransactionEntity.self, BankAccountEntity.self, CategoryEntity.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        self.container = try ModelContainer(for: schema, configurations: [configuration])
        self.context = ModelContext(container)
    }

    func fetchAllCategories() async throws -> [Category] {
        let entities = try context.fetch(FetchDescriptor<CategoryEntity>())
        return entities.map { $0.toCategory() }
    }
}

// конвертация между Category и CategoryEntity

extension CategoryEntity {
    func toCategory() -> Category {
        Category(
            id: id,
            name: name,
            emoji: emoji,
            isIncome: isIncome
        )
    }
}

extension Category {
    func toEntity() -> CategoryEntity {
        CategoryEntity(
            id: id,
            name: name,
            emoji: emoji,
            isIncome: isIncome
        )
    }
} 
