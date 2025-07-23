//
//  TransactionsServise.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 14.06.2025.
//

import Foundation

@MainActor
final class TransactionsService: ObservableObject {
    // static let shared: TransactionsService = { ... }() // УДАЛЕНО

    private let localStore: TransactionsLocalStore
    private let backupStore: TransactionsBackupStore
    private let networkClient: NetworkClient
    private let appNetworkStatus: AppNetworkStatus
    private let bankAccountsService: BankAccountsService
    private let categoriesService: CategoriesService

    public init(networkClient: NetworkClient, appNetworkStatus: AppNetworkStatus, bankAccountsService: BankAccountsService, categoriesService: CategoriesService) {
        do {
            let localStore = try SwiftDataTransactionsLocalStore()
            let backupStore = try SwiftDataTransactionsBackupStore()
            self.localStore = localStore
            self.backupStore = backupStore
            self.networkClient = networkClient
            self.appNetworkStatus = appNetworkStatus
            self.bankAccountsService = bankAccountsService
            self.categoriesService = categoriesService
        } catch {
            assertionFailure("Failed to initialize storage: \(error)")
            fatalError("Critical: Unable to initialize TransactionsService storages")
        }
    }

    // синхронизация бэкапа с сервером
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
                    try await networkClient.request(endpointValue: "api/v1/transactions", method: "POST", body: bodyData)
                    syncedIds.append(transaction.id)
                } catch {
                    continue
                }
            }
            if !syncedIds.isEmpty {
                try await backupStore.clearBackupOperations(with: syncedIds)
                // Удаляем транзакции из localStore после успешной синхронизации
                for id in syncedIds {
                    try await localStore.deleteTransaction(by: id)
                }
            }
        } catch {
            // ошибки бэкапа
        }
    }

    // транзакции за период
    func getTransactionsOfPeriod(interval: DateInterval) async throws -> [Transaction] {
        do {
            await syncBackupIfNeeded()
            let accounts = try await bankAccountsService.getAllAccounts()
            guard let account = accounts.first else {
                throw NSError(domain: "TransactionsService", code: 404, userInfo: [NSLocalizedDescriptionKey: "No primary bank account found."])
            }
            let utcFormatter = DateFormatter()
            utcFormatter.dateFormat = "yyyy-MM-dd"
            utcFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            let startDate = utcFormatter.string(from: interval.start)
            let endDate = utcFormatter.string(from: interval.end)
            let endpoint = "api/v1/transactions/account/\(account.id)/period?startDate=\(startDate)&endDate=\(endDate)"
            let responses = try await networkClient.fetchDecodeData(endpointValue: endpoint, dataType: TransactionResponse.self)
            let transactions = responses.compactMap { response -> Transaction? in
                let localDate = response.transactionDate.convertFromUTCToLocal()
                return response.toTransaction(with: localDate)
            }
            // очищаем локальное хранилище и добавляем новые данные
            try await localStore.clearTransactions(for: interval)
            for transaction in transactions {
                try await localStore.addTransaction(transaction)
            }
            _ = try await localStore.fetchTransactions(for: interval.start...interval.end)
            return transactions
        } catch {
            appNetworkStatus.handleNetworkError(error)
            let period = interval.start...interval.end
            let local = try await localStore.fetchTransactions(for: period)
            let backup = try await backupStore.fetchAllBackupOperations()
            // объединяем локальные и бэкап транзакции, избегая дублирования по ID
            var allTransactions: [Transaction] = []
            var seenIds: Set<Int> = []
            for transaction in local {
                if !seenIds.contains(transaction.id) {
                    allTransactions.append(transaction)
                    seenIds.insert(transaction.id)
                }
            }
            // добавляем бекап транзакции, которых нет в локальном хранилище
            for transaction in backup {
                if !seenIds.contains(transaction.id) && period.contains(transaction.transactionDate) {
                    allTransactions.append(transaction)
                    seenIds.insert(transaction.id)
                }
            }
            allTransactions.sort { $0.transactionDate > $1.transactionDate }
            return allTransactions
        }
    }
    
    // транзакции только за сегодня
    func getTodayTransactions() async throws -> [Transaction] {
        let todayStart = Calendar.current.startOfDay(for: Date())
        let todayEnd = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: todayStart) ?? todayStart
        
        do {
            await syncBackupIfNeeded()
            let accounts = try await bankAccountsService.getAllAccounts()
            guard let account = accounts.first else {
                throw NSError(domain: "TransactionsService", code: 404, userInfo: [NSLocalizedDescriptionKey: "No primary bank account found."])
            }
            
            let utcFormatter = DateFormatter()
            utcFormatter.dateFormat = "yyyy-MM-dd"
            utcFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            let startDate = utcFormatter.string(from: todayStart)
            let endDate = utcFormatter.string(from: todayEnd)
            let endpoint = "api/v1/transactions/account/\(account.id)/period?startDate=\(startDate)&endDate=\(endDate)"
            let responses = try await networkClient.fetchDecodeData(endpointValue: endpoint, dataType: TransactionResponse.self)
            let transactions = responses.compactMap { response -> Transaction? in
                let localDate = response.transactionDate.convertFromUTCToLocal()
                return response.toTransaction(with: localDate)
            }
            
            // фильтруем только сегодняшние транзакции
            let todayTransactions = transactions.filter { transaction in
                Calendar.current.isDate(transaction.transactionDate, inSameDayAs: todayStart)
            }
            //print("ONLINE: Today's transactions for UI: \(todayTransactions)")
            
            // очищаем локальное хранилище и добавляем новые данные
            let interval = DateInterval(start: todayStart, end: todayEnd)
            try await localStore.clearTransactions(for: interval)
            for transaction in todayTransactions {
                try await localStore.addTransaction(transaction)
            }
            _ = try await localStore.fetchTransactions(for: todayStart...todayEnd)
            //print("ONLINE: Local store after sync: \(localAfter)")
            
            return todayTransactions
        } catch {
            appNetworkStatus.handleNetworkError(error)
            
            //print("_____________Offline mode_____________")
            
            let period = todayStart...todayEnd
            let local = try await localStore.fetchTransactions(for: period)
            let backup = try await backupStore.fetchAllBackupOperations()
            
            // объединяем локальные и бекап транзакции, избегая дублирования по ID
            var allTransactions: [Transaction] = []
            var seenIds: Set<Int> = []
            
            // сначала добавляем локальные транзакции
            for transaction in local {
                if !seenIds.contains(transaction.id) {
                    allTransactions.append(transaction)
                    seenIds.insert(transaction.id)
                }
            }
            
            // затем добавляем бекап транзакции, которых нет в локальном хранилище
            for transaction in backup {
                if !seenIds.contains(transaction.id) && period.contains(transaction.transactionDate) {
                    allTransactions.append(transaction)
                    seenIds.insert(transaction.id)
                }
            }
            
            // фильтруем только сегодняшние транзакции
            let todayTransactions = allTransactions.filter { transaction in
                Calendar.current.isDate(transaction.transactionDate, inSameDayAs: todayStart)
            }
            
            // сортируем по дате (новые сначала)
            return todayTransactions.sorted { $0.transactionDate > $1.transactionDate }
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
            try await networkClient.request(endpointValue: "api/v1/transactions", method: "POST", body: bodyData)
            try await localStore.addTransaction(transaction)
            try await backupStore.deleteBackupOperation(by: transaction.id)
            let todayStart = Calendar.current.startOfDay(for: Date())
            let todayEnd = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: todayStart) ?? todayStart
            _ = try await localStore.fetchTransactions(for: todayStart...todayEnd)
            
            // обновляем баланс счета
            let category = try await categoriesService.getCategory(by: transaction.categoryId)
            let isIncome = category?.isIncome ?? false
            try await bankAccountsService.updateAccountBalance(
                accountId: transaction.accountId,
                amount: transaction.amount,
                isIncome: isIncome
            )
        } catch {
            try await backupStore.addBackupOperation(transaction)
            try await localStore.addTransaction(transaction)
            let todayStart = Calendar.current.startOfDay(for: Date())
            let todayEnd = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: todayStart) ?? todayStart
            _ = try await localStore.fetchTransactions(for: todayStart...todayEnd)
            _ = try await backupStore.fetchAllBackupOperations()
            //print("Local store after offline create: \(localAfter)")
            //print("Backup store after offline create: \(backupAfter)")
            
            // обновляем баланс счета в офлайне
            let category = try await categoriesService.getCategory(by: transaction.categoryId)
            let isIncome = category?.isIncome ?? false
            try await bankAccountsService.updateAccountBalance(
                accountId: transaction.accountId,
                amount: transaction.amount,
                isIncome: isIncome
            )
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
            try await networkClient.request(endpointValue: "api/v1/transactions/\(transaction.id)", method: "PUT", body: bodyData)
            try await localStore.updateTransaction(transaction)
            try await backupStore.deleteBackupOperation(by: transaction.id)
        } catch {
            try await backupStore.addBackupOperation(transaction)
            try await localStore.updateTransaction(transaction)
            //print("Added to backup for update: \(transaction)")
        }
    }

    func deleteTransaction(transactionId: Int) async throws {
        do {
            try await networkClient.request(endpointValue: "api/v1/transactions/\(transactionId)", method: "DELETE")
            try await localStore.deleteTransaction(by: transactionId)
            try await backupStore.deleteBackupOperation(by: transactionId)
        } catch {
            let transaction = try await localStore.fetchTransaction(by: transactionId)
            if let transaction = transaction {
                try await backupStore.addBackupOperation(transaction)
                //print("Added to backup for delete: \(transaction)")
            }
            try await localStore.deleteTransaction(by: transactionId)
        }
    }

    func nextTransactionId() -> Int {
        return 0
    }

    func todayInterval() -> DateInterval {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        guard let endOfDay = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: startOfDay) else {
            let fallbackEnd = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay
            return DateInterval(start: startOfDay, end: fallbackEnd)
        }
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

