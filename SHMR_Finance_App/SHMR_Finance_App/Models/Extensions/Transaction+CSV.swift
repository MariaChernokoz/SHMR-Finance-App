//
//  Transaction+CSV.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 25.06.2025.
//

import Foundation

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


