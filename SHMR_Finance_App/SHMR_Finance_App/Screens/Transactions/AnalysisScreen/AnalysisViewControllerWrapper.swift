//
//  AnalysisViewControllerWrapper.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 12.07.2025.
//

import SwiftUI

struct AnalysisViewControllerWrapper: UIViewControllerRepresentable {
    let direction: Direction
    let categories: [Category]
    let transactionsService: TransactionsService
    let bankAccountService: BankAccountsService

    init(direction: Direction, categories: [Category], transactionsService: TransactionsService, bankAccountService: BankAccountsService) {
        self.direction = direction
        self.categories = categories
        self.transactionsService = transactionsService
        self.bankAccountService = bankAccountService
    }
    
    func makeUIViewController(context: Context) -> AnalysisViewController {
        return AnalysisViewController(direction: direction, categories: categories, transactionsService: transactionsService, bankAccountService: bankAccountService)
    }

    func updateUIViewController(_ uiViewController: AnalysisViewController, context: Context) {}
}
