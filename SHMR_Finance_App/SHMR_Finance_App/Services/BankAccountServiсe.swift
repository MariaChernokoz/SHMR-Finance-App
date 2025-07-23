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
            return localAccounts
            
        } catch {
            // в случае любой другой ошибки - возвращаем из локального хранилища
            let localAccounts = try await localStore.fetchAllAccounts()
            return localAccounts
        }
    }

    // получить аккаунт по id
    func getAccount(by id: Int) async throws -> BankAccount? {
        return try await localStore.fetchAccount(by: id)
    }

    // добавить/обновить аккаунт
    func saveAccount(_ account: BankAccount) async throws {
        // 1. Подготовить тело запроса
        let updateRequest = AccountUpdateRequest(
            name: account.name,
            balance: NSDecimalNumber(decimal: account.balance).stringValue,
            currency: account.currency
        )
        // 2. Сформировать endpoint
        let endpoint = "api/v1/accounts/\(account.id)"
        // 3. Кодируем тело запроса
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let bodyData = try encoder.encode(updateRequest)
        // 4. Отправляем PUT-запрос через универсальный метод request
        let data = try await NetworkClient.shared.request(endpointValue: endpoint, method: "PUT", body: bodyData)
        // 5. Декодируем ответ
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let updatedAccount = try decoder.decode(BankAccount.self, from: data)
        // 6. Обновляем локальное хранилище
        try await localStore.updateAccount(updatedAccount)
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
