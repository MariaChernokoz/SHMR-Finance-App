//
//  TransactionsServise.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 14.06.2025.
//

import Foundation

final class TransactionsService: ObservableObject {
     @Published private var mockTransactions: [Transaction] = [
        Transaction(
            id: 1,
            accountId: 1,
            categoryId: 3,
            amount: Decimal(555.55),
            transactionDate: Date(),
            comment: "Бобик",
            createdAt: Date(),
            updatedAt: Date()
        ),
        Transaction(
            id: 2,
            accountId: 1,
            categoryId: 5,
            amount: Decimal(444.00),
            transactionDate: Date(),
            comment: "Другу за кофе",
            createdAt: Date(),
            updatedAt: Date()
        ),
        Transaction(
            id: 3,
            accountId: 1,
            categoryId: 3,
            amount: Decimal(1200.00),
            transactionDate: Date(),
            comment: "Бублик",
            createdAt: Date(),
            updatedAt: Date()
        ),
        Transaction(
            id: 4,
            accountId: 1,
            categoryId: 6,
            amount: Decimal(9999.99),
            transactionDate: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
            comment: "Абонемент",
            createdAt: Date(),
            updatedAt: Date()
        ),
        Transaction(
            id: 5,
            accountId: 1,
            categoryId: 6,
            amount: Decimal(10000.00),
            transactionDate: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(),
            comment: "Пилатес",
            createdAt: Date(),
            updatedAt: Date()
        ),
        Transaction(
            id: 6,
            accountId: 1,
            categoryId: 6,
            amount: Decimal(10000.00),
            transactionDate: Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? Date(),
            comment: "Йога",
            createdAt: Date(),
            updatedAt: Date()
        ),
        Transaction(
            id: 7,
            accountId: 1,
            categoryId: 8,
            amount: Decimal(3500.00),
            transactionDate: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(),
            comment: nil,
            createdAt: Date(),
            updatedAt: Date()
        ),
        Transaction(
            id: 8,
            accountId: 1,
            categoryId: 9,
            amount: Decimal(180000.00),
            transactionDate: Date(),
            comment: nil,
            createdAt: Date(),
            updatedAt: Date()
        ),
        Transaction(
            id: 9,
            accountId: 1,
            categoryId: 10,
            amount: Decimal(9999.99),
            transactionDate: Date(),
            comment: "Продажа картины",
            createdAt: Date(),
            updatedAt: Date()
        ),
        Transaction(
            id: 10,
            accountId: 1,
            categoryId: 10,
            amount: Decimal(15000.00),
            transactionDate: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(),
            comment: nil,
            createdAt: Date(),
            updatedAt: Date()
        ),
        Transaction(
            id: 11,
            accountId: 1,
            categoryId: 11,
            amount: Decimal(25000.00),
            transactionDate: Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date(),
            comment: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        
    ]
    
    func todayInterval() -> DateInterval {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        return DateInterval(start: startOfDay, end: endOfDay)
    }
    
    func getTransactionsOfPeriod(interval: DateInterval) async throws -> [Transaction] {
        
        return mockTransactions.filter { transaction in
            interval.contains(transaction.transactionDate)
        }
    }
    
    func createTransaction(_ transaction: Transaction) async throws {
        
        guard !mockTransactions.contains(where: { $0.id == transaction.id }) else {
            throw TransactionServiceError.duplicateTransaction
        }
        mockTransactions.append(transaction)
    }
    
    func updateTransaction(_ transaction: Transaction) async throws {
        
        guard let index = mockTransactions.firstIndex(where: { $0.id == transaction.id }) else {
            throw TransactionServiceError.transactionNotFound
        }
        mockTransactions[index] = transaction
    }
    
    func deleteTransaction(transactionId: Int) async throws {
        
        let initialCount = mockTransactions.count
        mockTransactions.removeAll { $0.id == transactionId }
            
        if mockTransactions.count == initialCount {
            throw TransactionServiceError.transactionNotFound
        }
    }
}

enum TransactionServiceError: Error, LocalizedError {
    case transactionNotFound
    case duplicateTransaction
    
    var errorDescription: String? {
        switch self {
        case .transactionNotFound: return "Transaction not found"
        case .duplicateTransaction: return "Transaction already exists"
        }
    }
}

