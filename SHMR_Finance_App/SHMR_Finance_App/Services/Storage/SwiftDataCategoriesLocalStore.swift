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

    func addCategory(_ category: Category) async throws {
        let entity = category.toEntity()
        context.insert(entity)
        try context.save()
    }

    func updateCategory(_ category: Category) async throws {
        let descriptor = FetchDescriptor<CategoryEntity>(predicate: #Predicate { $0.id == category.id })
        guard let entity = try context.fetch(descriptor).first else { return }
        entity.name = category.name
        entity.emoji = category.emoji
        entity.isIncome = category.isIncome
        try context.save()
    }

    func deleteCategory(by id: Int) async throws {
        let descriptor = FetchDescriptor<CategoryEntity>(predicate: #Predicate { $0.id == id })
        let entities = try context.fetch(descriptor)
        for entity in entities {
            context.delete(entity)
        }
        try context.save()
    }
}

// MARK: - Конвертация между Category и CategoryEntity

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