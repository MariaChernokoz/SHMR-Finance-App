//
//  TransactionsServise.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 14.06.2025.
//

import Foundation

final class TransactionsService {
     private var mockTransactions: [Transaction] = [
        Transaction(
            id: 1,
            accountId: 1,
            categoryId: 1,
            amount: Decimal(555.55),
            transactionDate: Date(),
            comment: "Оплата за услугу",
            createdAt: Date(),
            updatedAt: Date()
        ),
        Transaction(
            id: 2,
            accountId: 1,
            categoryId: 2,
            amount: Decimal(444.00),
            transactionDate: Date(),
            comment: "Другу за кофе",
            createdAt: Date(),
            updatedAt: Date()
        )
    ]
    
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

