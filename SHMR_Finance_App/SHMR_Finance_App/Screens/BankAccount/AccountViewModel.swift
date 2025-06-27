//
//  AccountViewModel.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 24.06.2025.
//

import Foundation
import SwiftUI

class AccountViewModel: ObservableObject {
    private let bankAccountService = BankAccountsService()

    @Published var bankAccount: BankAccount? = nil
    @Published var errorMessage: String? = nil
       
    @MainActor
    func loadAccount() async {
        do {
            let bankAccount = try await bankAccountService.getAccount()
            self.bankAccount = bankAccount
        } catch {
            errorMessage = error.localizedDescription
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
            try await bankAccountService.updateAccount(account)
            let updatedAccount = account
            await MainActor.run {
                self.bankAccount = updatedAccount
            }
        } catch {
            let errorText = error.localizedDescription
            await MainActor.run {
                errorMessage = errorText
            }
        }
    }
    
    func formattedBalance(_ balance: Decimal) -> String {
        let doubleValue = NSDecimalNumber(decimal: balance).doubleValue
        if doubleValue.truncatingRemainder(dividingBy: 1) == 0 {
            // Целое число
            return String(format: "%.0f", doubleValue)
        } else {
            // С копейками
            return String(format: "%.2f", doubleValue)
        }
    }
}


