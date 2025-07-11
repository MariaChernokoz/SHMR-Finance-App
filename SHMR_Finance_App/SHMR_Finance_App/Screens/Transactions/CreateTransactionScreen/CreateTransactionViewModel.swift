//
//  CreateTransactionViewModel.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 11.07.2025.
//

import Foundation
import SwiftUI

final class CreateTransactionViewModel: ObservableObject {
    @Published var amount: String = ""
    @Published var date: Date = Date()
    @Published var selectedCategory: Category?
    @Published var comment: String = ""
    @Published var isLoading = false
    @Published var showAlert = false
    //@Published var mainAccount: BankAccount?

    let direction: Direction
    var mainAccountId: Int
    let categories: [Category]
    let transactions: [Transaction]
    let transactionToEdit: Transaction?

    var isEdit: Bool { transactionToEdit != nil }

    var filteredCategories: [Category] {
        categories.filter { $0.isIncome == direction }
    }

    init(
        direction: Direction,
        mainAccountId: Int,
        categories: [Category],
        transactions: [Transaction],
        transactionToEdit: Transaction? = nil
    ) {
        self.direction = direction
        self.mainAccountId = mainAccountId
        self.categories = categories
        self.transactions = transactions
        self.transactionToEdit = transactionToEdit

        if let transaction = transactionToEdit {
            self.amount = transaction.amount.formattedAmount
            self.date = transaction.transactionDate
            self.selectedCategory = categories.first(where: { $0.id == transaction.categoryId })
            self.comment = transaction.comment ?? ""
        }
    }

    func save(onSave: @escaping () -> Void) {
        //отладка валидации
        print("selectedCategory:", selectedCategory as Any)
        print("amount:", amount)
        print("amountDecimal:", Decimal(string: amount.replacingOccurrences(of: ",", with: ".")) as Any)
        guard let selectedCategory = selectedCategory,
              let amountDecimal = Decimal(string: amount.replacingOccurrences(of: ",", with: ".")),
              !amount.isEmpty,
              let transaction = transactionToEdit
        else {
            showAlert = true
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
                try await TransactionsService().updateTransaction(updatedTransaction)
                isLoading = false
                onSave()
            } catch {
                isLoading = false
                showAlert = true
            }
        }
    }

    func create(onSave: @escaping () -> Void) {
        //отладка валидации
        print("selectedCategory:", selectedCategory as Any)
        print("amount:", amount)
        print("amountDecimal:", Decimal(string: amount.replacingOccurrences(of: ",", with: ".")) as Any)
        guard let selectedCategory = selectedCategory,
              let amountDecimal = Decimal(string: amount.replacingOccurrences(of: ",", with: ".")),
              !amount.isEmpty
        else {
            showAlert = true
            return
        }
        isLoading = true
        let newId = (transactions.map { $0.id }.max() ?? 0) + 1
        let newTransaction = Transaction(
            id: newId,
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
                try await TransactionsService().createTransaction(newTransaction)
                isLoading = false
                onSave()
            } catch {
                isLoading = false
                showAlert = true
            }
        }
    }
    
//    func saveOrCreate(onSave: @escaping () -> Void) {
//        guard let selectedCategory = selectedCategory,
//              let amountDecimal = Decimal(string: amount.replacingOccurrences(of: ",", with: ".")),
//              !amount.isEmpty
//        else {
//            showAlert = true
//            return
//        }
//
//        isLoading = true
//
//        if isEdit, let transaction = transactionToEdit {
//            // Редактирование
//            let updatedTransaction = Transaction(
//                id: transaction.id,
//                accountId: transaction.accountId,
//                categoryId: selectedCategory.id,
//                amount: amountDecimal,
//                transactionDate: date,
//                comment: comment,
//                createdAt: transaction.createdAt,
//                updatedAt: Date()
//            )
//            Task {
//                do {
//                    try await TransactionsService().updateTransaction(updatedTransaction)
//                    isLoading = false
//                    onSave()
//                } catch {
//                    isLoading = false
//                    showAlert = true
//                }
//            }
//        } else {
//            // Создание
//            let newId = (transactions.map { $0.id }.max() ?? 0) + 1
//            let newTransaction = Transaction(
//                id: newId,
//                accountId: mainAccountId,
//                categoryId: selectedCategory.id,
//                amount: amountDecimal,
//                transactionDate: date,
//                comment: comment,
//                createdAt: Date(),
//                updatedAt: Date()
//            )
//            Task {
//                do {
//                    try await TransactionsService().createTransaction(newTransaction)
//                    isLoading = false
//                    onSave()
//                } catch {
//                    isLoading = false
//                    showAlert = true
//                }
//            }
//        }
//    }
    
    func delete(onDelete: @escaping () -> Void) {
        guard let transaction = transactionToEdit else { return }
        isLoading = true
        Task {
            do {
                try await TransactionsService().deleteTransaction(transactionId: transaction.id)
                isLoading = false
                onDelete()
            } catch {
                isLoading = false
                showAlert = true
            }
        }
    }
    
    func loadAccount() async {
        do {
            let account = try await BankAccountsService().getAccount()
            DispatchQueue.main.async {
                self.mainAccountId = account.id
                //self.accountCurrency = account.currency
            }
        } catch {
            // обработка ошибки
        }
    }
}
