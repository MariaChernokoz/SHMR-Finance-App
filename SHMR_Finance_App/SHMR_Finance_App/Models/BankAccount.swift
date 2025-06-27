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
}

enum Currency: String {
    case RUB = "₽"
    case USD = "$"
    case EUR = "€"
}


