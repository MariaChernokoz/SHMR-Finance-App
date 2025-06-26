//
//  BankAccountServise.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 14.06.2025.
//

import Foundation

final class BankAccountsService {
    
    private var mockAccounts: [BankAccount] = [
        BankAccount(
            id: 1,
            userId: 1,
            name: "Основной счёт",
            balance: 33365.99,
            currency: "RUB",
            createdAt: Date(),
            updatedAt: Date()
        ),
        BankAccount(
            id: 2,
            userId: 1,
            name: "Инфестиционный счёт",
            balance: 33365.99,
            currency: "RUB",
            createdAt: Date(),
            updatedAt: Date()
        ),
        BankAccount(
            id: 3,
            userId: 2,
            name: "Основной счёт",
            balance: 999.00,
            currency: "USD",
            createdAt: Date(),
            updatedAt: Date()
        )
    ]
    
    func getAccount() async throws -> BankAccount {
                
        guard let account = mockAccounts.first else {
            throw AccountError.accountNotFound
        }
        return account
    }
    
    func updateAccount(_ account: BankAccount) async throws {
        
        guard let index = mockAccounts.firstIndex(where: { $0.id == account.id }) else {
            throw AccountError.accountNotFound
        }
        mockAccounts[index] = account
    }
}

enum AccountError: Error, LocalizedError {
    case accountNotFound
    
    var errorDescription: String? {
        switch self {
        case .accountNotFound: return "Account not found"
        }
    }
}
