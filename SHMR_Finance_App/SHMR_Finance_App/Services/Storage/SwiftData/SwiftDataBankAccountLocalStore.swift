import Foundation
import SwiftData

@MainActor
final class SwiftDataBankAccountLocalStore: BankAccountLocalStore {
    private let container: ModelContainer
    private let context: ModelContext

    init() throws {
        let schema = Schema([TransactionEntity.self, BackupTransactionEntity.self, BankAccountEntity.self, CategoryEntity.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        self.container = try ModelContainer(for: schema, configurations: [configuration])
        self.context = ModelContext(container)
    }

    func fetchAllAccounts() async throws -> [BankAccount] {
        let entities = try context.fetch(FetchDescriptor<BankAccountEntity>())
        return entities.map { $0.toBankAccount() }
    }

    func fetchAccount(by id: Int) async throws -> BankAccount? {
        let descriptor = FetchDescriptor<BankAccountEntity>(predicate: #Predicate { $0.id == id })
        let entities = try context.fetch(descriptor)
        return entities.first?.toBankAccount()
    }

    func addAccount(_ account: BankAccount) async throws {
        let entity = account.toEntity()
        context.insert(entity)
        try context.save()
    }

    func updateAccount(_ account: BankAccount) async throws {
        let descriptor = FetchDescriptor<BankAccountEntity>(predicate: #Predicate { $0.id == account.id })
        guard let entity = try context.fetch(descriptor).first else { return }
        entity.userId = account.userId
        entity.name = account.name
        entity.balance = account.balance
        entity.currency = account.currency
        entity.createdAt = account.createdAt
        entity.updatedAt = account.updatedAt
        try context.save()
    }

    func deleteAccount(by id: Int) async throws {
        let descriptor = FetchDescriptor<BankAccountEntity>(predicate: #Predicate { $0.id == id })
        let entities = try context.fetch(descriptor)
        for entity in entities {
            context.delete(entity)
        }
        try context.save()
    }
}

// конвертация между BankAccount и BankAccountEntity

extension BankAccountEntity {
    func toBankAccount() -> BankAccount {
        BankAccount(
            id: id,
            userId: userId,
            name: name,
            balance: balance,
            currency: currency,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

extension BankAccount {
    func toEntity() -> BankAccountEntity {
        BankAccountEntity(
            id: id,
            userId: userId,
            name: name,
            balance: balance,
            currency: currency,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
} 
