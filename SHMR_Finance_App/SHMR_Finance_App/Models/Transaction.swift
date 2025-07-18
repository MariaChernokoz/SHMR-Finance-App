//
//  Transaction.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 14.06.2025.
//

import Foundation

struct Transaction: Codable, Identifiable {
    let id: Int
    let accountId: Int
    let categoryId: Int
    let amount: Decimal
    let transactionDate: Date
    let comment: String?
    let createdAt: Date
    let updatedAt: Date
}

struct TransactionRequest: Codable {
    let accountId: Int
    let categoryId: Int
    let amount: String
    let transactionDate: Date
    let comment: String?
    
    init(from transaction: Transaction) {
        self.accountId = transaction.accountId
        self.categoryId = transaction.categoryId
        self.amount = NSDecimalNumber(decimal: transaction.amount).stringValue
        self.transactionDate = transaction.transactionDate
        self.comment = transaction.comment
    }
}

struct TransactionResponse: Codable {
    let id: Int
    let account: AccountBrief
    let category: Category
    let amount: String
    let transactionDate: Date
    let comment: String?
    let createdAt: Date
    let updatedAt: Date
    
    // конвертация в основную модель Transaction
    func toTransaction() -> Transaction? {
        return toTransaction(with: transactionDate)
    }
    
    // конвертация в основную модель Transaction с указанной датой
    func toTransaction(with date: Date) -> Transaction? {
        // Безопасная конвертация строки в Decimal
        let cleanedAmount = amount.replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: ",", with: ".")
        
        guard let amountDecimal = Decimal(string: cleanedAmount) else {
            print("Failed to convert amount string '\(amount)' to Decimal")
            return nil
        }
        
        // Проверяем, что Decimal валидный (не NaN)
        guard !amountDecimal.isNaN else {
            print("Amount is NaN: \(amount)")
            return nil
        }
        
        return Transaction(
            id: id,
            accountId: account.id,
            categoryId: category.id,
            amount: amountDecimal,
            transactionDate: date,
            comment: comment,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

struct AccountBrief: Codable {
    let id: Int
    let name: String
    let balance: String
    let currency: String
}
