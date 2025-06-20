//
//  HistoryViewModel.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 20.06.2025.
//

import Foundation
import SwiftUI

class HistoryViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var categories: [Category] = []
    @Published var startDate: Date = Calendar.current.date(
        byAdding: .month,
        value: -1,
        to: Calendar.current.startOfDay(for: Date())
    ) ?? Calendar.current.startOfDay(for: Date())
    @Published var endDate: Date = {
        let today = Calendar.current.startOfDay(for: Date())
        return Calendar.current.date(bySettingHour: 23, minute: 59, second: 0, of: today) ?? Date()
    }()
    func applyStartDateFilter() {
        if startDate > endDate {
            endDate = startDate
        }
        Task { await loadData() }
    }
    func applyEndDateFilter() {
        if endDate < startDate {
            startDate = endDate
        }
        Task { await loadData() }
    }
    @Published var sortType: SortType = .date {
        didSet { filterTransactions() }
    }
    @Published var direction: Direction {
        didSet { filterTransactions() }
    }
    init(direction: Direction) {
        self.direction = direction
    }
    @Published var filteredTransactions: [Transaction] = []

    private let transactionsService = TransactionsService()
    private let categoriesService = CategoriesService()
    
    @Published var errorMessage: String? = nil

    @MainActor
    func loadData() async {
        do {
            let interval = DateInterval(start: startDate, end: endDate)
            transactions = try await transactionsService.getTransactionsOfPeriod(interval: interval)
            categories = try await categoriesService.allCategoriesList()
            filterTransactions()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func filterTransactions() {
        let filtered = transactions.filter { transaction in
            if let category = categories.first(where: { $0.id == transaction.categoryId }) {
                return category.isIncome == direction
            }
            return false
        }
        switch sortType {
        case .date:
            filteredTransactions = filtered.sorted { $0.transactionDate > $1.transactionDate }
        case .amount:
            filteredTransactions = filtered.sorted { $0.amount > $1.amount }
        }
    }

    func amountFormatter(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.maximumFractionDigits = 2
        return (formatter.string(for: amount) ?? "0") + " ₽"
    }

    var totalAmount: Decimal {
        filteredTransactions.reduce(0) { $0 + $1.amount }
    }
}
