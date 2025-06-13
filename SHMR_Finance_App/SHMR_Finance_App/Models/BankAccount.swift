//
//  BankAccount.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 14.06.2025.
//

import Foundation

struct BankAccount {
    let id: Int
    let userId: Int
    let name: String
    var balance: Decimal
    let currency: String
    let createdAt: Date
    let updatedAt: Date
}
