//
//  TransactionsServise.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 14.06.2025.
//

import Foundation

final class TransactionsService: ObservableObject {
    static let shared = TransactionsService()
    
    private init() {}

    // транзакции за период
    func getTransactionsOfPeriod(interval: DateInterval) async throws -> [Transaction] {
        // Получаем основной аккаунт для получения его ID
        let account = try await BankAccountsService.shared.getAccount()
        print("Getting transactions for account ID: \(account.id)")
        
        // Конвертируем даты в UTC для отправки на сервер
        let utcFormatter = DateFormatter()
        utcFormatter.dateFormat = "yyyy-MM-dd"
        utcFormatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC
        let startDate = utcFormatter.string(from: interval.start)
        let endDate = utcFormatter.string(from: interval.end)
        print("Period (UTC): \(startDate) to \(endDate)")
        
        // Используем правильный эндпоинт с параметрами
        let endpoint = "api/v1/transactions/account/\(account.id)/period?startDate=\(startDate)&endDate=\(endDate)"
        print("Requesting endpoint: \(endpoint)")
        
        let responses = try await NetworkClient.shared.fetchDecodeData(endpointValue: endpoint, dataType: TransactionResponse.self)
        print("Received \(responses.count) transaction responses")
        
        // конвертируем в Transaction, предполагая что сервер возвращает UTC
        let transactions = responses.compactMap { response -> Transaction? in
            // Если сервер возвращает UTC, конвертируем в локальное время
            let localDate = response.transactionDate.convertFromUTCToLocal()
            return response.toTransaction(with: localDate)
        }
        print("Successfully converted \(transactions.count) transactions")
        
        return transactions
    }
    
    // создание
    func createTransaction(_ transaction: Transaction) async throws {
        // Конвертируем дату в UTC для отправки на сервер
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
    }

    // редактирование 
    func updateTransaction(_ transaction: Transaction) async throws {
        // Конвертируем дату в UTC для отправки на сервер
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
    }

    // Удалить транзакцию
    func deleteTransaction(transactionId: Int) async throws {
        try await NetworkClient.shared.request(endpointValue: "api/v1/transactions/\(transactionId)", method: "DELETE")
    }

    // Получить следующий ID для новой транзакции
    func nextTransactionId() -> Int {
        // Для сетевого API ID генерируется сервером, поэтому возвращаем 0
        // или можно сделать запрос для получения максимального ID
        return 0
    }

    // Вспомогательный метод для получения интервала "сегодня"
    func todayInterval() -> DateInterval {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let endOfDay = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: startOfDay)!
        return DateInterval(start: startOfDay, end: endOfDay)
    }
    
    // Временный метод для тестирования с конкретной датой
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

