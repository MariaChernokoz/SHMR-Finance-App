//
//  AnalysisViewModel.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 16.07.2025.
//

import Foundation

class AnalysisViewModel {
    var firstDate: Date
    var secondDate: Date
    var sortType: SortType = .date
    var chosenPeriodSum: Decimal = 0
    var transactions: [Transaction] = []
    let categories: [Category]
    let direction: Direction
    var accountCurrency: String = "RUB" // по умолчанию

    var onDataChanged: (() -> Void)?

    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private let transactionsService: TransactionsService
    private let bankAccountService: BankAccountsService

    init(direction: Direction, categories: [Category], transactionsService: TransactionsService, bankAccountService: BankAccountsService) {
        self.direction = direction
        self.categories = categories
        self.transactionsService = transactionsService
        self.bankAccountService = bankAccountService
        self.firstDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        self.secondDate = Date()
    }

    @MainActor func setStartDate(_ newDate: Date) {
        firstDate = newDate
        if firstDate > secondDate {
            secondDate = firstDate
        }
        loadTransactions()
    }

    @MainActor func setEndDate(_ newDate: Date) {
        secondDate = newDate
        if secondDate < firstDate {
            firstDate = secondDate
        }
        loadTransactions()
    }

    func setSortType(_ type: SortType) {
        sortType = type
        sortTransactions()
        onDataChanged?()
    }

    @MainActor
    func loadTransactions() {
        isLoading = true
        errorMessage = nil // Сбрасываем предыдущие ошибки
        
        Task {
            do {
                let interval = DateInterval(start: firstDate, end: secondDate)
                let allTransactions = try await transactionsService.getTransactionsOfPeriod(interval: interval)
                let accounts = try await bankAccountService.getAllAccounts()
                if let account = accounts.first {
                    accountCurrency = account.currency
                }
                let filtered = (allTransactions).filter { transaction in
                    if let category = categories.first(where: { $0.id == transaction.categoryId }) {
                        return category.direction == direction
                    }
                    return false
                }
                transactions = filtered
                chosenPeriodSum = filtered.reduce(0) { $0 + $1.amount }
                sortTransactions()
                DispatchQueue.main.async {
                    self.onDataChanged?()
                }
            } catch {
                errorMessage = error.userFriendlyNetworkMessage
            }
            
            isLoading = false
        }
    }

    private func sortTransactions() {
        switch sortType {
        case .date:
            transactions.sort { $0.transactionDate > $1.transactionDate }
        case .amount:
            transactions.sort { $0.amount > $1.amount }
        }
    }
}
