//
//  Transaction+JSON.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 25.06.2025.
//

import Foundation

// MARK: 2) Конвертирование Transaction в json object и обратно

extension Transaction {
    
    var jsonObject: Any {    //сериализация
        
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let dict: [String: Any] = [
            "id": id,
            "accountId": accountId,
            "categoryId": categoryId,
            "amount": (amount as NSDecimalNumber).stringValue,
            "transactionDate": dateFormatter.string(from: transactionDate),
            "comment": comment as Any? ?? NSNull(),
            "createdAt": dateFormatter.string(from: createdAt),
            "updatedAt": dateFormatter.string(from: updatedAt)
        ]
        
        return dict
    }
    
    
    static func parse(jsonObject: Any) -> Transaction? {    //десериализация
        
        guard let dict = jsonObject as? [String: Any] else {
            return nil
        }
        
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let id = dict["id"] as? Int,
              let accountId = dict["accountId"] as? Int,
              let categoryId = dict["categoryId"] as? Int,
              let amountString = dict["amount"] as? String,
              let amount = Decimal(string: amountString),
              let transactionDateString = dict["transactionDate"] as? String,
              let transactionDate = dateFormatter.date(from: transactionDateString),
              let createdAtString = dict["createdAt"] as? String,
              let createdAt = dateFormatter.date(from: createdAtString),
              let updatedAtString = dict["updatedAt"] as? String,
              let updatedAt = dateFormatter.date(from: updatedAtString) else {
            print("Некорретный формат JSON")
            return nil
        }
        
        let comment = dict["comment"] as? String
        
        return Transaction(
            id: id,
            accountId: accountId,
            categoryId: categoryId,
            amount: amount,
            transactionDate: transactionDate,
            comment: comment,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
