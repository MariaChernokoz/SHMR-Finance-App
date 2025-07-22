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
    private let transactionsService = TransactionsService.shared

    @Published var bankAccount: BankAccount? = nil
    @Published var errorMessage: String? = nil
    
    @Published var transactions: [Transaction] = []
    @Published var balanceHistory: [BalanceHistoryPoint] = []

    func loadAccount() async {
        do {
            let accounts = try await BankAccountsService.shared.getAllAccounts()
            guard let account = accounts.first else { throw AccountError.accountNotFound }
            self.bankAccount = account

            // Загружаем все транзакции аккаунта (лучше за большой период, чтобы корректно посчитать начальный баланс)
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let startDate = calendar.date(byAdding: .day, value: -29, to: today)!
            let interval = DateInterval(start: startDate, end: today)
            let transactions = try await TransactionsService.shared.getTransactionsOfPeriod(interval: interval)
            self.transactions = transactions

            // Считаем сумму транзакций за последние 30 дней
            let sumLast30 = transactions.reduce(0.0) { $0 + (Double(truncating: $1.amount as NSNumber)) }
            let initialBalance = Double(truncating: (account.balance as NSNumber)) - sumLast30

            // Считаем историю баланса
            self.balanceHistory = Self.calculateBalanceHistory(
                transactions: transactions,
                startDate: startDate,
                days: 30,
                initialBalance: Decimal(initialBalance) //Decimal(initialBalance)
            )
            print("________________________________________________")
            for t in transactions {
                print("Дата: \(t.transactionDate), Категория: \(t.categoryId), Сумма: \(t.amount)")
            }
        } catch {
            errorMessage = error.userFriendlyNetworkMessage
        }
    }
    
    static func calculateBalanceHistory(transactions: [Transaction],
                                        startDate: Date, days: Int,
                                        initialBalance: Decimal = 0) -> [BalanceHistoryPoint] {
        
        let calendar = Calendar.current
        var points: [BalanceHistoryPoint] = []
        var runningBalance = initialBalance

        for i in 0..<days {
            let date = calendar.date(byAdding: .day, value: i, to: startDate)!
            let dayTransactions = transactions.filter { calendar.isDate($0.transactionDate, inSameDayAs: date) }
            let daySum = dayTransactions.reduce(Decimal(0)) { $0 + $1.amount }
            runningBalance += daySum
            print("Дата: \(date), Баланс: \(runningBalance), Транзакции: \(daySum)")
            //points.append(BalanceHistoryPoint(date: date, balance: runningBalance))
            points.append(BalanceHistoryPoint(date: date, balance: Decimal(Double(truncating: runningBalance as NSNumber))))
        }
        return points
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

// Для графика
struct BalanceHistoryPoint: Identifiable {
    let id = UUID()
    let date: Date
    let balance: Decimal
}
