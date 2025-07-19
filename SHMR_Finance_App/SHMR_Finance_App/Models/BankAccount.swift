//
//  BankAccount.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 14.06.2025.
//

import Foundation

struct BankAccount: Codable, Identifiable {
    let id: Int
    let userId: Int
    let name: String
    var balance: Decimal
    var currency: String
    let createdAt: Date
    let updatedAt: Date

    // Обычный инициализатор для конвертации из BankAccountEntity
    init(id: Int, userId: Int, name: String, balance: Decimal, currency: String, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.userId = userId
        self.name = name
        self.balance = balance
        self.currency = currency
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    enum CodingKeys: String, CodingKey {
        case id, userId, name, balance, currency, createdAt, updatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        userId = try container.decode(Int.self, forKey: .userId)
        name = try container.decode(String.self, forKey: .name)
        let balanceString = try container.decode(String.self, forKey: .balance)
        guard let balanceDecimal = Decimal(string: balanceString) else {
            throw DecodingError.dataCorruptedError(forKey: .balance, in: container, debugDescription: "Cannot decode balance as Decimal")
        }
        balance = balanceDecimal
        currency = try container.decode(String.self, forKey: .currency)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(userId, forKey: .userId)
        try container.encode(name, forKey: .name)
        // Преобразуем Decimal в строку для отправки на сервер
        try container.encode(NSDecimalNumber(decimal: balance).stringValue, forKey: .balance)
        try container.encode(currency, forKey: .currency)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
    }
}

struct AccountUpdateRequest: Codable {
    let name: String
    let balance: String
    let currency: String
}

//struct AccountUpdateRequest: Codable {
//    let name: String
//    let balance: String
//    let currency: String
//}

//enum AccountError: Error, LocalizedError {
//    case accountNotFound
//    
//    var errorDescription: String? {
//        switch self {
//        case .accountNotFound: return "Account not found"
//        }
//    }
//}

enum Currency: String {
    case RUB = "₽"
    case USD = "$"
    case EUR = "€"
}


