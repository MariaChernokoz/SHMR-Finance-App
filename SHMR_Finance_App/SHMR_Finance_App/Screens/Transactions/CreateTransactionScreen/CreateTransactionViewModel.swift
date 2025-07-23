//
//  CreateTransactionViewModel.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 11.07.2025.
//

import Foundation
import SwiftUI

@MainActor
final class CreateTransactionViewModel: ObservableObject {
    @Published var amount: String = ""
    @Published var date: Date = Date()
    @Published var selectedCategory: Category?
    @Published var comment: String = ""
    @Published var isLoading = false
    @Published var showAlert = false
    @Published var errorMessage: String? = nil
    @Published var accountCurrency: String = "₽" // По умолчанию

    let direction: Direction
    var mainAccountId: Int
    let categories: [Category]
    let transactions: [Transaction]
    let transactionToEdit: Transaction?

    let transactionsService: TransactionsService
    let bankAccountService: BankAccountsService

    var isEdit: Bool { transactionToEdit != nil }

    var filteredCategories: [Category] {
        categories.filter { $0.direction == direction }
    }

    init(
        direction: Direction,
        mainAccountId: Int,
        categories: [Category],
        transactions: [Transaction],
        transactionToEdit: Transaction? = nil,
        transactionsService: TransactionsService,
        bankAccountService: BankAccountsService
    ) {
        self.direction = direction
        self.mainAccountId = mainAccountId
        self.categories = categories
        self.transactions = transactions
        self.transactionToEdit = transactionToEdit
        self.transactionsService = transactionsService
        self.bankAccountService = bankAccountService
        if let transaction = transactionToEdit {
            // Для поля ввода суммы используем сырой Decimal → String с точкой
            self.amount = NSDecimalNumber(decimal: transaction.amount).stringValue
            self.date = transaction.transactionDate
            self.selectedCategory = categories.first(where: { $0.id == transaction.categoryId })
            self.comment = transaction.comment ?? ""
        } else {
            // Устанавливаем первую подходящую категорию по умолчанию
            let filteredCategories = categories.filter { $0.direction == direction }
            self.selectedCategory = filteredCategories.first
        }
        // Загружаем актуальный accountId
        Task {
            await loadAccount()
        }
    }

    func save(onSave: @escaping () -> Void) {
        let cleanedAmount = amount.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: ",", with: ".")
        let amountDecimal = Decimal(string: cleanedAmount)
        guard let selectedCategory = selectedCategory,
              let amountDecimal = amountDecimal,
              amountDecimal > 0,
              let transaction = transactionToEdit
        else {
            Task { @MainActor in showAlert = true }
            return
        }
        isLoading = true
        let updatedTransaction = Transaction(
            id: transaction.id,
            accountId: transaction.accountId,
            categoryId: selectedCategory.id,
            amount: amountDecimal,
            transactionDate: date,
            comment: comment,
            createdAt: transaction.createdAt,
            updatedAt: Date()
        )
        Task {
            do {
                try await transactionsService.updateTransaction(updatedTransaction)
                await MainActor.run {
                    isLoading = false
                    onSave()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.userFriendlyNetworkMessage
                    showAlert = true
                }
            }
        }
    }

    func create(onSave: @escaping () -> Void) {
        let cleanedAmount = amount.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: ",", with: ".")
        let amountDecimal = Decimal(string: cleanedAmount)
        guard let selectedCategory = selectedCategory,
              let amountDecimal = amountDecimal,
              amountDecimal > 0
        else {
            Task { @MainActor in showAlert = true }
            return
        }
        isLoading = true
        
        let newTransaction = Transaction(
            id: 0, // Временный ID, сервер заменит на реальный
            accountId: mainAccountId,
            categoryId: selectedCategory.id,
            amount: amountDecimal,
            transactionDate: date,
            comment: comment,
            createdAt: Date(),
            updatedAt: Date()
        )
        Task {
            do {
                try await transactionsService.createTransaction(newTransaction)
                await MainActor.run {
                    isLoading = false
                    onSave()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.userFriendlyNetworkMessage
                    showAlert = true
                }
            }
        }
    }
    
    func delete(onDelete: @escaping () -> Void) {
        guard let transaction = transactionToEdit else { return }
        isLoading = true
        Task {
            do {
                try await transactionsService.deleteTransaction(transactionId: transaction.id)
                await MainActor.run {
                    isLoading = false
                    onDelete()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.userFriendlyNetworkMessage
                    showAlert = true
                }
            }
        }
    }
    
    func loadAccount() async {
        do {
            let accounts = try await bankAccountService.getAllAccounts()
            guard let account = accounts.first else { throw AccountError.accountNotFound }
            await MainActor.run {
                self.mainAccountId = account.id
                self.accountCurrency = account.currency
            }
        } catch {
            // Ошибка загрузки аккаунта
        }
    }
}
