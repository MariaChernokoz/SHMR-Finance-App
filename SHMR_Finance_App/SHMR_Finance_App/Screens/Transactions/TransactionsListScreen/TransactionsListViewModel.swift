//
//  TransactionsListViewModel.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 20.06.2025.
//

import Foundation
import SwiftUI

@MainActor
final class TransactionsListViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var categories: [Category] = []
    @Published var isCreatingTransaction = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var accountCurrency: String = "RUB" // по умолчанию

    let direction: Direction

    private let transactionsService = TransactionsService.shared
    private let categoriesService = CategoriesService.shared

    init(direction: Direction) {
        self.direction = direction
    }

    var filteredTransactions: [Transaction] {
        transactions.filter { transaction in
            if let category = categories.first(where: { $0.id == transaction.categoryId }) {
                return category.direction == direction
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

    @MainActor
    func loadData() async {
        isLoading = true
        errorMessage = nil // Сбрасываем предыдущие ошибки
        
        do {
            async let transactionsTask = transactionsService.getTodayTransactions()
            async let categoriesTask = categoriesService.getAllCategories()
            async let accountTask = BankAccountsService.shared.getAllAccounts()
            transactions = try await transactionsTask
            categories = try await categoriesTask
            let accounts = try await accountTask
            if let account = accounts.first {
                accountCurrency = account.currency
            }
            isLoading = false
        } catch {
            errorMessage = error.userFriendlyNetworkMessage
            isLoading = false
        }
    }
}
