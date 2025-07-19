import Foundation

@MainActor
protocol TransactionsLocalStore {
    func fetchTransactions(for period: ClosedRange<Date>) async throws -> [Transaction]
    func fetchTransaction(by id: Int) async throws -> Transaction?
    func addTransaction(_ transaction: Transaction) async throws
    func updateTransaction(_ transaction: Transaction) async throws
    func deleteTransaction(by id: Int) async throws
} 