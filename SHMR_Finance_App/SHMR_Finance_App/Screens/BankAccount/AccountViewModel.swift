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
    @Published var categories: [Category] = []

    func loadAccount() async {
        do {
            let accounts = try await BankAccountsService.shared.getAllAccounts()
            guard let account = accounts.first else { throw AccountError.accountNotFound }
            self.bankAccount = account

            // Загрузить категории
            let loadedCategories = try await CategoriesService.shared.getAllCategories()
            self.categories = loadedCategories

            // Загрузи все транзакции аккаунта (лучше за большой период)
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let startDate = calendar.date(byAdding: .day, value: -29, to: today)!
            let allInterval = DateInterval(start: calendar.date(byAdding: .year, value: -1, to: today)!, end: today)
            let allTransactions = try await TransactionsService.shared.getTransactionsOfPeriod(interval: allInterval)

            // Для графика нужны только последние 30 дней
            let transactionsForChart = allTransactions.filter { $0.transactionDate >= startDate }

            // Сумма доходов и расходов по категориям
            let sumIncomes = transactionsForChart.filter { tx in
                if let cat = self.categories.first(where: { $0.id == tx.categoryId }) {
                    return cat.isIncome
                }
                return false
            }.reduce(0.0) { $0 + (Double(truncating: $1.amount as NSNumber)) }

            let sumOutcomes = transactionsForChart.filter { tx in
                if let cat = self.categories.first(where: { $0.id == tx.categoryId }) {
                    return !cat.isIncome
                }
                return false
            }.reduce(0.0) { $0 + (Double(truncating: $1.amount as NSNumber)) }

            // Баланс на начало периода
            let initialBalance = Double(truncating: (account.balance as NSNumber)) - sumIncomes + sumOutcomes

            //print("Баланс на начало периода (\(startDate)): \(initialBalance)")

            self.balanceHistory = Self.calculateBalanceHistory(
                transactions: transactionsForChart,
                startDate: startDate,
                days: 30,
                initialBalance: Decimal(initialBalance),
                categories: self.categories
            )
        } catch {
            errorMessage = error.userFriendlyNetworkMessage
        }
    }
    
    static func calculateBalanceHistory(transactions: [Transaction],
                                        startDate: Date, days: Int,
                                        initialBalance: Decimal = 0,
                                        categories: [Category]) -> [BalanceHistoryPoint] {
        
        let calendar = Calendar.current
        var points: [BalanceHistoryPoint] = []
        var runningBalance = initialBalance

        for i in 0..<days {
                let date = calendar.date(byAdding: .day, value: i, to: startDate)!
                let dayTransactions = transactions.filter { calendar.isDate($0.transactionDate, inSameDayAs: date) }
                let daySum = dayTransactions.reduce(Decimal(0)) { sum, tx in
                    if let cat = categories.first(where: { $0.id == tx.categoryId }) {
                        return sum + (cat.isIncome ? tx.amount : -tx.amount)
                    } else {
                        return sum
                    }
                }
                runningBalance += daySum
            
            // MARK: для отладки (оставляю для проверяющих)
                //print("Дата: \(date), Баланс: \(runningBalance), Транзакции: \(daySum)")
            
                points.append(BalanceHistoryPoint(date: date, balance: runningBalance))
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
