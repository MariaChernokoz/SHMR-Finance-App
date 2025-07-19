import Foundation
import SwiftData

@Model
final class BackupTransactionEntity {
    @Attribute(.unique) var id: Int
    var accountId: Int
    var categoryId: Int
    var amount: Decimal
    var transactionDate: Date
    var comment: String?
    var createdAt: Date
    var updatedAt: Date

    init(id: Int, accountId: Int, categoryId: Int, amount: Decimal, transactionDate: Date, comment: String?, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.accountId = accountId
        self.categoryId = categoryId
        self.amount = amount
        self.transactionDate = transactionDate
        self.comment = comment
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

@MainActor
final class SwiftDataTransactionsBackupStore: TransactionsBackupStore {
    private let container: ModelContainer
    private let context: ModelContext

    init() throws {
        let schema = Schema([TransactionEntity.self, BackupTransactionEntity.self, BankAccountEntity.self, CategoryEntity.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        self.container = try ModelContainer(for: schema, configurations: [configuration])
        self.context = ModelContext(container)
    }

    func fetchAllBackupOperations() async throws -> [Transaction] {
        let entities = try context.fetch(FetchDescriptor<BackupTransactionEntity>())
        return entities.map { $0.toTransaction() }
    }

    func addBackupOperation(_ transaction: Transaction) async throws {
        let entity = transaction.toBackupEntity()
        context.insert(entity)
        try context.save()
    }

    func deleteBackupOperation(by id: Int) async throws {
        let descriptor = FetchDescriptor<BackupTransactionEntity>(predicate: #Predicate { $0.id == id })
        let entities = try context.fetch(descriptor)
        for entity in entities {
            context.delete(entity)
        }
        try context.save()
    }

    func clearBackupOperations(with ids: [Int]) async throws {
        let descriptor = FetchDescriptor<BackupTransactionEntity>(predicate: #Predicate { ids.contains($0.id) })
        let entities = try context.fetch(descriptor)
        for entity in entities {
            context.delete(entity)
        }
        try context.save()
    }
}

// MARK: - Конвертация между Transaction и BackupTransactionEntity

extension BackupTransactionEntity {
    func toTransaction() -> Transaction {
        Transaction(
            id: id,
            accountId: accountId,
            categoryId: categoryId,
            amount: amount,
            transactionDate: transactionDate,
            comment: comment,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

extension Transaction {
    func toBackupEntity() -> BackupTransactionEntity {
        BackupTransactionEntity(
            id: id,
            accountId: accountId,
            categoryId: categoryId,
            amount: amount,
            transactionDate: transactionDate,
            comment: comment,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
} 