import Foundation
import SwiftData

@MainActor
final class SwiftDataTransactionsLocalStore: TransactionsLocalStore {
    private let container: ModelContainer
    private let context: ModelContext

    init() throws {
        let schema = Schema([TransactionEntity.self, BackupTransactionEntity.self, BankAccountEntity.self, CategoryEntity.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        self.container = try ModelContainer(for: schema, configurations: [configuration])
        self.context = ModelContext(container)
    }

    func fetchTransactions(for period: ClosedRange<Date>) async throws -> [Transaction] {
        let descriptor = FetchDescriptor<TransactionEntity>(
            predicate: #Predicate { $0.transactionDate >= period.lowerBound && $0.transactionDate <= period.upperBound },
            sortBy: [SortDescriptor(\TransactionEntity.transactionDate, order: .reverse)]
        )
        let entities = try context.fetch(descriptor)
        return entities.map { $0.toTransaction() }
    }

    func fetchTransaction(by id: Int) async throws -> Transaction? {
        let descriptor = FetchDescriptor<TransactionEntity>(predicate: #Predicate { $0.id == id })
        let entities = try context.fetch(descriptor)
        return entities.first?.toTransaction()
    }

    func addTransaction(_ transaction: Transaction) async throws {
        let entity = transaction.toEntity()
        context.insert(entity)
        try context.save()
    }

    func updateTransaction(_ transaction: Transaction) async throws {
        let descriptor = FetchDescriptor<TransactionEntity>(predicate: #Predicate { $0.id == transaction.id })
        guard let entity = try context.fetch(descriptor).first else { return }
        entity.accountId = transaction.accountId
        entity.categoryId = transaction.categoryId
        entity.amount = transaction.amount
        entity.transactionDate = transaction.transactionDate
        entity.comment = transaction.comment
        entity.createdAt = transaction.createdAt
        entity.updatedAt = transaction.updatedAt
        try context.save()
    }

    func deleteTransaction(by id: Int) async throws {
        let descriptor = FetchDescriptor<TransactionEntity>(predicate: #Predicate { $0.id == id })
        let entities = try context.fetch(descriptor)
        for entity in entities {
            context.delete(entity)
        }
        try context.save()
    }
    
    func clearTransactions(for interval: DateInterval) async throws {
        let descriptor = FetchDescriptor<TransactionEntity>(
            predicate: #Predicate { $0.transactionDate >= interval.start && $0.transactionDate <= interval.end }
        )
        let entities = try context.fetch(descriptor)
        for entity in entities {
            context.delete(entity)
        }
        try context.save()
    }
}

// конвертация между Transaction и TransactionEntity

extension TransactionEntity {
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
    func toEntity() -> TransactionEntity {
        TransactionEntity(
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
