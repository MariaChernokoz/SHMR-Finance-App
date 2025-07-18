//
//  CategoriesViewModel.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 28.06.2025.
//

import Foundation

class CategoriesViewModel: ObservableObject {
    
    @Published var categories: [Category] = []
    @Published var errorMessage: String? = nil
    @Published var isLoading: Bool = false
    @Published var searchText: String = ""

    var filteredCategories: [Category] {
        if searchText.isEmpty {
            return categories
        } else {
            let threshold = 5 // порог чувствительности (до 5 опечаток)
            return categories.filter { category in
                let distance = levenshtein(searchText.lowercased(), category.name.lowercased())
                return distance <= threshold || category.name.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    func levenshtein(_ a: String, _ b: String) -> Int {
        let a = Array(a)
        let b = Array(b)
        var dp = Array(repeating: Array(repeating: 0, count: b.count + 1), count: a.count + 1) // матрица
        for i in 0...a.count { dp[i][0] = i }
        for j in 0...b.count { dp[0][j] = j }
        for i in 1...a.count {
            for j in 1...b.count {
                if a[i-1] == b[j-1] {
                    dp[i][j] = dp[i-1][j-1] // символы совпадают - берем значение по диагонали
                } else {
                    // замена, вставка, удаление соответственно +1 к стоимости
                    dp[i][j] = min(dp[i-1][j-1], dp[i][j-1], dp[i-1][j]) + 1
                }
            }
        }
        return dp[a.count][b.count]
    }

    private let categoriesService = CategoriesService.shared

    @MainActor
    func loadData() async {
        isLoading = true
        errorMessage = nil // Сбрасываем предыдущие ошибки
        
        do {
            async let categoriesTask = categoriesService.allCategoriesList()
            categories = try await categoriesTask
            isLoading = false
        } catch {
            errorMessage = error.userFriendlyNetworkMessage
            isLoading = false
        }
    }
}
