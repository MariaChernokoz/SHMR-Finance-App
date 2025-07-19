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
    // private let backupStore: BankAccountBackupStore (если потребуется)

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
            // Сетевой запрос для получения аккаунтов
            let accounts = try await NetworkClient.shared.fetchDecodeData(endpointValue: "api/v1/accounts", dataType: BankAccount.self)
            
            // Уведомляем об успешном запросе
            AppNetworkStatus.shared.handleSuccessfulRequest()
            
            // Сохраняем аккаунты в локальное хранилище
            for account in accounts {
                try await localStore.addAccount(account)
            }
            
            return accounts
        } catch let error as NetworkError {
            print("❌ Сетевая ошибка загрузки аккаунтов: \(error.userFriendlyMessage)")
            
            // Уведомляем о сетевой ошибке
            AppNetworkStatus.shared.handleNetworkError(error)
            
            // Если сетевой запрос не удался, возвращаем из локального хранилища
            let localAccounts = try await localStore.fetchAllAccounts()
            
            // Если локальное хранилище тоже пустое, создаем тестовый аккаунт
            if localAccounts.isEmpty {
                print("🔍 Создаю тестовый аккаунт...")
                let testAccount = BankAccount(
                    id: 1,
                    userId: 1,
                    name: "Основной счет",
                    balance: Decimal(100000),
                    currency: "₽",
                    createdAt: Date(),
                    updatedAt: Date()
                )
                try await localStore.addAccount(testAccount)
                return [testAccount]
            }
            
            return localAccounts
        } catch {
            print("❌ Неожиданная ошибка загрузки аккаунтов: \(error)")
            
            // В случае любой другой ошибки также возвращаем из локального хранилища
            let localAccounts = try await localStore.fetchAllAccounts()
            
            if localAccounts.isEmpty {
                print("🔍 Создаю тестовый аккаунт...")
                let testAccount = BankAccount(
                    id: 1,
                    userId: 1,
                    name: "Основной счет",
                    balance: Decimal(100000),
                    currency: "₽",
                    createdAt: Date(),
                    updatedAt: Date()
                )
                try await localStore.addAccount(testAccount)
                return [testAccount]
            }
            
            return localAccounts
        }
    }

    // Получить счет по id
    func getAccount(by id: Int) async throws -> BankAccount? {
        return try await localStore.fetchAccount(by: id)
    }

    // Добавить/обновить счет
    func saveAccount(_ account: BankAccount) async throws {
        do {
            // let request = ... // подготовить сетевой запрос
            // try await NetworkClient.shared.request(...)
            try await localStore.updateAccount(account)
            // Если успех — удалить из бэкапа
        } catch {
            // При ошибке — добавить в бэкап (если потребуется)
            try await localStore.updateAccount(account)
        }
    }

    // Удалить счет
    func deleteAccount(by id: Int) async throws {
        do {
            // try await NetworkClient.shared.request(...)
            try await localStore.deleteAccount(by: id)
            // Если успех — удалить из бэкапа
        } catch {
            // При ошибке — добавить в бэкап (если потребуется)
            try await localStore.deleteAccount(by: id)
        }
    }
    
    // Обновить баланс счета при создании транзакции
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
