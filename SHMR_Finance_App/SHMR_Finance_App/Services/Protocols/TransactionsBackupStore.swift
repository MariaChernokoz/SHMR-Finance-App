import Foundation

@MainActor
protocol TransactionsBackupStore {
    func fetchAllBackupOperations() async throws -> [Transaction]
    func addBackupOperation(_ transaction: Transaction) async throws
    func deleteBackupOperation(by id: Int) async throws
    func clearBackupOperations(with ids: [Int]) async throws
} 