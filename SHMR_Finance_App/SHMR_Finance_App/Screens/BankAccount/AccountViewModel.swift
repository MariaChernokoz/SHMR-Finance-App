//
//  AccountViewModel.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 24.06.2025.
//

import Foundation
import SwiftUI

@MainActor
class AccountViewModel: ObservableObject {
    private let bankAccountService = BankAccountsService.shared

    @Published var bankAccount: BankAccount? = nil
    @Published var errorMessage: String? = nil

    func loadAccount() async {
        do {
            //let account = try await bankAccountService.getAccount()
            let accounts = try await BankAccountsService.shared.getAllAccounts()
            guard let account = accounts.first else { throw AccountError.accountNotFound }
            self.bankAccount = account
        } catch {
            errorMessage = error.userFriendlyNetworkMessage
        }
    }

    func saveAccount(newBalance: String, newCurrency: String) async {
        guard var account = bankAccount else {
            errorMessage = "Аккаунт не найден"
            return
        }

        let normalizedBalance = newBalance
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "\u{00A0}", with: "") // неразрывные пробелы
            .replacingOccurrences(of: ",", with: ".")

        guard let balance = Decimal(string: normalizedBalance) else {
            errorMessage = "Некорректный баланс"
            return
        }

        account.balance = balance
        account.currency = newCurrency

        do {
            try await bankAccountService.saveAccount(account)
            await MainActor.run {
                self.bankAccount = account
            }
        } catch {
            await MainActor.run {
                errorMessage = error.userFriendlyNetworkMessage
            }
        }
    }
}


