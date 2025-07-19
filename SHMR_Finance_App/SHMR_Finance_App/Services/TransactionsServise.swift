//
//  TransactionsServise.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 14.06.2025.
//

import Foundation

@MainActor
final class TransactionsService: ObservableObject {
    static let shared: TransactionsService = {
        let service = TransactionsService()
        return service
    }()

    private let localStore: TransactionsLocalStore
    private let backupStore: TransactionsBackupStore

    // Приватный designated initializer
    private init() {
        do {
            let localStore = try SwiftDataTransactionsLocalStore()
            let backupStore = try SwiftDataTransactionsBackupStore()
            self.localStore = localStore
            self.backupStore = backupStore
        } catch {
            assertionFailure("Failed to initialize storage: \(error)")
            fatalError("Critical: Unable to initialize TransactionsService storages")
        }
    }

    // Синхронизация бэкапа с сервером
    private func syncBackupIfNeeded() async {
        do {
            let backupTransactions = try await backupStore.fetchAllBackupOperations()
            var syncedIds: [Int] = []
            for transaction in backupTransactions {
                do {
                    let request = TransactionRequest(from: transaction)
                    let encoder = JSONEncoder()
                    encoder.dateEncodingStrategy = .iso8601
                    let bodyData = try encoder.encode(request)
                    try await NetworkClient.shared.request(endpointValue: "api/v1/transactions", method: "POST", body: bodyData)
                    syncedIds.append(transaction.id)
                } catch {
                    continue
                }
            }
            if !syncedIds.isEmpty {
                try await backupStore.clearBackupOperations(with: syncedIds)
            }
        } catch {
            // Игнорируем ошибки бэкапа
        }
    }

    // транзакции за период
    func getTransactionsOfPeriod(interval: DateInterval) async throws -> [Transaction] {
        print("🔍 Начинаю загрузку транзакций...")
        do {
            await syncBackupIfNeeded()
            let accounts = try await BankAccountsService.shared.getAllAccounts()
            print("�� Аккаунты загружены: \(accounts.count)")
            guard let account = accounts.first else {
                throw NSError(domain: "TransactionsService", code: 404, userInfo: [NSLocalizedDescriptionKey: "No primary bank account found."])
            }
            let utcFormatter = DateFormatter()
            utcFormatter.dateFormat = "yyyy-MM-dd"
            utcFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            let startDate = utcFormatter.string(from: interval.start)
            let endDate = utcFormatter.string(from: interval.end)
            let endpoint = "api/v1/transactions/account/\(account.id)/period?startDate=\(startDate)&endDate=\(endDate)"
            let responses = try await NetworkClient.shared.fetchDecodeData(endpointValue: endpoint, dataType: TransactionResponse.self)
            let transactions = responses.compactMap { response -> Transaction? in
                let localDate = response.transactionDate.convertFromUTCToLocal()
                return response.toTransaction(with: localDate)
            }
            for transaction in transactions {
                try await localStore.addTransaction(transaction)
            }
            return transactions
        } catch {
            print("❌ Ошибка загрузки: \(error)")
            let period = interval.start...interval.end
            let local = try await localStore.fetchTransactions(for: period)
            let backup = try await backupStore.fetchAllBackupOperations()
            let all = (local + backup).filter { period.contains($0.transactionDate) }
            return all
        }
    }
    
    func createTransaction(_ transaction: Transaction) async throws {
        do {
            let utcTransaction = Transaction(
                id: transaction.id,
                accountId: transaction.accountId,
                categoryId: transaction.categoryId,
                amount: transaction.amount,
                transactionDate: transaction.transactionDate.convertToUTC(),
                comment: transaction.comment,
                createdAt: transaction.createdAt,
                updatedAt: transaction.updatedAt
            )
            let request = TransactionRequest(from: utcTransaction)
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let bodyData = try encoder.encode(request)
            try await NetworkClient.shared.request(endpointValue: "api/v1/transactions", method: "POST", body: bodyData)
            try await localStore.addTransaction(transaction)
            try await backupStore.deleteBackupOperation(by: transaction.id)
        } catch {
            try await backupStore.addBackupOperation(transaction)
            try await localStore.addTransaction(transaction)
        }
    }

    func updateTransaction(_ transaction: Transaction) async throws {
        do {
            let utcTransaction = Transaction(
                id: transaction.id,
                accountId: transaction.accountId,
                categoryId: transaction.categoryId,
                amount: transaction.amount,
                transactionDate: transaction.transactionDate.convertToUTC(),
                comment: transaction.comment,
                createdAt: transaction.createdAt,
                updatedAt: transaction.updatedAt
            )
            let request = TransactionRequest(from: utcTransaction)
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let bodyData = try encoder.encode(request)
            try await NetworkClient.shared.request(endpointValue: "api/v1/transactions/\(transaction.id)", method: "PUT", body: bodyData)
            try await localStore.updateTransaction(transaction)
            try await backupStore.deleteBackupOperation(by: transaction.id)
        } catch {
            try await backupStore.addBackupOperation(transaction)
            try await localStore.updateTransaction(transaction)
        }
    }

    func deleteTransaction(transactionId: Int) async throws {
        do {
            try await NetworkClient.shared.request(endpointValue: "api/v1/transactions/\(transactionId)", method: "DELETE")
            try await localStore.deleteTransaction(by: transactionId)
            try await backupStore.deleteBackupOperation(by: transactionId)
        } catch {
            let transaction = try await localStore.fetchTransaction(by: transactionId)
            if let transaction = transaction {
                try await backupStore.addBackupOperation(transaction)
            }
            try await localStore.deleteTransaction(by: transactionId)
        }
    }

    func nextTransactionId() -> Int {
        return 0
    }

    func todayInterval() -> DateInterval {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let endOfDay = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: startOfDay)!
        return DateInterval(start: startOfDay, end: endOfDay)
    }
    
    func testInterval() -> DateInterval {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let testDate = dateFormatter.date(from: "2025-07-16")!
        let startOfDay = Calendar.current.startOfDay(for: testDate)
        let endOfDay = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: startOfDay)!
        return DateInterval(start: startOfDay, end: endOfDay)
    }
}

enum TransactionServiceError: Error, LocalizedError {
    case transactionNotFound
    case duplicateTransaction
    case invalidTransactionData
    
    var errorDescription: String? {
        switch self {
        case .transactionNotFound: return "Transaction not found"
        case .duplicateTransaction: return "Transaction already exists"
        case .invalidTransactionData: return "Invalid transaction data"
        }
    }
}

