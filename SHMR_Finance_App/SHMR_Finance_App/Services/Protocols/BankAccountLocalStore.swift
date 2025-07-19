import Foundation

@MainActor
protocol BankAccountLocalStore {
    func fetchAllAccounts() async throws -> [BankAccount]
    func fetchAccount(by id: Int) async throws -> BankAccount?
    func addAccount(_ account: BankAccount) async throws
    func updateAccount(_ account: BankAccount) async throws
    func deleteAccount(by id: Int) async throws
} 