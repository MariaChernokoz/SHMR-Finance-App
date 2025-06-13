//
//  CategoriesServise.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 14.06.2025.
//

import Foundation

final class CategoriesService {
    private let mockCategories: [Category] = [
        Category(
            id: 1,
            name: "Зарплата",
            emoji: "💰",
            isIncome: .income
        ),
        Category(
            id: 2,
            name: "Маркетплейсы",
            emoji: "🛍",
            isIncome: .outcome
        ),
        Category(
            id: 3,
            name: "Бензин",
            emoji: "🚗",
            isIncome: .outcome
        ),
        Category(
            id: 4,
            name: "Инвестиции",
            emoji: "📈",
            isIncome: .income
        )
    ]
    
    func allCategoriesList() async throws -> [Category] {
        
        return mockCategories
    }

    func categories(direction: Direction) async throws -> [Category] {
        
        return mockCategories.filter { $0.isIncome == direction }
    }
}

