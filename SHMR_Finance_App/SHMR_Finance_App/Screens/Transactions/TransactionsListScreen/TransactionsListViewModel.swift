//
//  TransactionsListViewModel.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 20.06.2025.
//

import Foundation
import SwiftUI

class TransactionsListViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var categories: [Category] = []
    @Published var isCreatingTransaction = false

    let direction: Direction

    private let transactionsService = TransactionsService.shared
    private let categoriesService = CategoriesService.shared

    init(direction: Direction) {
        self.direction = direction
    }

    var filteredTransactions: [Transaction] {
        transactions.filter { transaction in
            if let category = categories.first(where: { $0.id == transaction.categoryId }) {
                return category.isIncome == direction
            }
            return false
        }
    }

    var title: String {
        direction == .income ? "Доходы сегодня" : "Расходы сегодня"
    }

    var totalAmount: Decimal {
        filteredTransactions.reduce(0) { $0 + $1.amount }
    }
    
    var accountId: Int {
        // если у тебя один счет, можно захардкодить, либо получить из BankAccountService
        1
    }

    func amountFormatter(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.maximumFractionDigits = 2
        return (formatter.string(for: amount) ?? "0") + " ₽"
    }
    
    @Published var errorMessage: String? = nil

    @MainActor
    func loadData() async {
        do {
            let today = transactionsService.todayInterval()
            async let transactionsTask = transactionsService.getTransactionsOfPeriod(interval: today)
            async let categoriesTask = categoriesService.allCategoriesList()
            transactions = try await transactionsTask
            categories = try await categoriesTask
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
