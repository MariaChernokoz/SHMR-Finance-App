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

// MARK: * - реализовать расширение Transaction для разбора формата СSV

extension Transaction {
    
    static func parse(csvLine: String) -> Transaction? {

        let components = csvLine.components(separatedBy: ",")

        guard components.count >= 8 else { return nil }

        guard
            let id = Int(components[0]),
            let accountId = Int(components[1]),
            let categoryId = Int(components[2]),
            let amount = Decimal(string: components[3])
        else { return nil }

        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard
            let transactionDate = isoFormatter.date(from: components[4]),
            let createdAt = isoFormatter.date(from: components[6]),
            let updatedAt = isoFormatter.date(from: components[7])
        else { return nil }

        let comment = (components[5].isEmpty ? nil : components[5])

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

    static func parse(csv: String) -> [Transaction] {

        let lines = csv.components(separatedBy: .newlines)
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        return lines.compactMap { parse(csvLine: $0) }
    }
}


