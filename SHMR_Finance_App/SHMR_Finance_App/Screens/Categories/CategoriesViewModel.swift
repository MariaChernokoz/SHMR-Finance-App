//
//  CategoriesViewModel.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 28.06.2025.
//

import Foundation
import SwiftUI

class CategoriesViewModel: ObservableObject {
    
    @Published var categories: [Category] = []
    @Published var errorMessage: String? = nil
    @Published var searchText: String = ""

    var filteredCategories: [Category] {
        if searchText.isEmpty {
            return categories
        } else {
            return categories.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }

    private let categoriesService = CategoriesService()

    @MainActor
    func loadData() async {
        do {
            //let today = transactionsService.todayInterval()
            //async let transactionsTask = transactionsService.getTransactionsOfPeriod(interval: today)
            async let categoriesTask = categoriesService.allCategoriesList()
            //transactions = try await transactionsTask
            categories = try await categoriesTask
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
