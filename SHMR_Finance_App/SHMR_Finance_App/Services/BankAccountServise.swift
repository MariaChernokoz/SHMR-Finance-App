//
//  BankAccountServise.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 14.06.2025.
//

import Foundation

final class BankAccountsService: ObservableObject {
    static let shared = BankAccountsService()
    private init() {}

    // Получить единственный банковский счет пользователя
    func getAccount() async throws -> BankAccount {
        let accounts = try await NetworkClient.shared.fetchDecodeData(endpointValue: "api/v1/accounts", dataType: BankAccount.self)
        guard let first = accounts.first else {
            throw AccountError.accountNotFound
        }
        return first
    }

    // Изменить счет
    func updateAccount(_ account: BankAccount) async throws {
        let balanceString = NSDecimalNumber(decimal: account.balance).stringValue
        let updateRequest = AccountUpdateRequest(name: account.name, balance: balanceString, currency: account.currency)
        let endpoint = "api/v1/accounts/\(account.id)"
        let encoder = JSONEncoder()
        let bodyData = try encoder.encode(updateRequest)
        try await NetworkClient.shared.request(endpointValue: endpoint, method: "PUT", body: bodyData)
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
