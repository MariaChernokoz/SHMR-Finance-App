//
//  HistoryViewModel.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 20.06.2025.
//

import Foundation
import SwiftUI

@MainActor
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
    func validateDates() {
        if startDate > endDate {
            endDate = startDate
        }
        if endDate < startDate {
            startDate = endDate
        }
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
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private let transactionsService = TransactionsService.shared
    private let categoriesService = CategoriesService.shared
    
    @MainActor
    func loadData() async {
        isLoading = true
        errorMessage = nil // Сбрасываем предыдущие ошибки
        
        do {
            let interval = DateInterval(start: startDate, end: endDate)
            async let transactionsTask = transactionsService.getTransactionsOfPeriod(interval: interval)
            async let categoriesTask = categoriesService.getAllCategories()
            transactions = try await transactionsTask
            categories = try await categoriesTask
            filterTransactions()
            isLoading = false
        } catch {
            errorMessage = error.userFriendlyNetworkMessage
            isLoading = false
        }
    }

    func filterTransactions() {
        let filtered = transactions.filter { transaction in
            if let category = categories.first(where: { $0.id == transaction.categoryId }) {
                return category.direction == direction
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

    var totalAmount: Decimal {
        filteredTransactions.reduce(0) { $0 + $1.amount }
    }

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

    func triggerTestError() {
        errorMessage = "Тестовая ошибка для проверки алерта"
    }

    @MainActor
    func deleteTransactions(at offsets: IndexSet) async {
        let transactionsToDelete = offsets.map { filteredTransactions[$0] }
        for transaction in transactionsToDelete {
            do {
                try await transactionsService.deleteTransaction(transactionId: transaction.id)
            } catch {
                errorMessage = error.userFriendlyNetworkMessage
            }
        }
        await loadData()
    }
}
