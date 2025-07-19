//
//  BankAccountServise.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 14.06.2025.
//

import Foundation

@MainActor
final class BankAccountsService: ObservableObject {
    static let shared: BankAccountsService = {
        let service = BankAccountsService()
        return service
    }()

    private let localStore: BankAccountLocalStore

    private init() {
        do {
            let localStore = try SwiftDataBankAccountLocalStore()
            self.localStore = localStore
        } catch {
            assertionFailure("Failed to initialize BankAccountsService storage: \(error)")
            fatalError("Critical: Unable to initialize BankAccountsService storage")
        }
    }

    // Получить все счета
    func getAllAccounts() async throws -> [BankAccount] {
        do {
            let accounts = try await NetworkClient.shared.fetchDecodeData(endpointValue: "api/v1/accounts", dataType: BankAccount.self)
            
            AppNetworkStatus.shared.handleSuccessfulRequest()
            
            // cохраняем аккаунты в локальное хранилище
            for account in accounts {
                try await localStore.addAccount(account)
            }
            
            return accounts
        } catch let error as NetworkError {
            
            AppNetworkStatus.shared.handleNetworkError(error)
            
            // если запрос не успешный, возвращаем из локального хранилища
            let localAccounts = try await localStore.fetchAllAccounts()
            
//            // если локальное хранилище тоже пустое, создаем тестовый аккаунт
//            if localAccounts.isEmpty {
//                let testAccount = BankAccount(
//                    id: 1,
//                    userId: 1,
//                    name: "Основной счет",
//                    balance: Decimal(100000),
//                    currency: "₽",
//                    createdAt: Date(),
//                    updatedAt: Date()
//                )
//                try await localStore.addAccount(testAccount)
//                return [testAccount]
//            }
            
            return localAccounts
            
        } catch {
            // в случае любой другой ошибки - возвращаем из локального хранилища
            let localAccounts = try await localStore.fetchAllAccounts()
            
//            if localAccounts.isEmpty {
//                let testAccount = BankAccount(
//                    id: 1,
//                    userId: 1,
//                    name: "Основной счет",
//                    balance: Decimal(100000),
//                    currency: "₽",
//                    createdAt: Date(),
//                    updatedAt: Date()
//                )
//                try await localStore.addAccount(testAccount)
//                return [testAccount]
//            }
            
            return localAccounts
        }
    }

    // получить аккаунт по id
    func getAccount(by id: Int) async throws -> BankAccount? {
        return try await localStore.fetchAccount(by: id)
    }

    // добавить/обновить аккаунт
    func saveAccount(_ account: BankAccount) async throws {
        do {
            try await localStore.updateAccount(account)
        } catch {
            try await localStore.updateAccount(account)
        }
    }

    // удалить аккаунт
    func deleteAccount(by id: Int) async throws {
        do {
            try await localStore.deleteAccount(by: id)
        } catch {
            try await localStore.deleteAccount(by: id)
        }
    }
    
    // обновить баланс аккаунта при создании транзакции
    func updateAccountBalance(accountId: Int, amount: Decimal, isIncome: Bool) async throws {
        guard let account = try await localStore.fetchAccount(by: accountId) else {
            throw AccountError.accountNotFound
        }
        
        var updatedAccount = account
        if isIncome {
            updatedAccount.balance += amount
        } else {
            updatedAccount.balance -= amount
        }
        updatedAccount.updatedAt = Date()
        
        try await localStore.updateAccount(updatedAccount)
    }
}

enum AccountError: Error, LocalizedError {
    case accountNotFound
    var errorDescription: String? {
        switch self {
        case .accountNotFound: return "Account not found"
        }
    }
}
