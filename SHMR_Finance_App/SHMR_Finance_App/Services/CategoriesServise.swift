//
//  CategoriesServise.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 14.06.2025.
//

import Foundation

final class CategoriesService: ObservableObject {
    @Published private var mockCategories: [Category] = [
        Category(
            id: 1,
            name: "Аренда квартиры",
            emoji: "🏡",
            isIncome: .outcome
        ),
        Category(
            id: 2,
            name: "Одежда",
            emoji: "🛍",
            isIncome: .outcome
        ),
        Category(
            id: 3,
            name: "На собачку",
            emoji: "🐕",
            isIncome: .outcome
        ),
        Category(
            id: 4,
            name: "Ремонт квартиры",
            emoji: "🛠",
            isIncome: .outcome
        ),
        Category(
            id: 5,
            name: "Продукты",
            emoji: "🛒",
            isIncome: .outcome
        ),
        Category(
            id: 6,
            name: "Спортзал",
            emoji: "🤸",
            isIncome: .outcome
        ),
        Category(
            id: 7,
            name: "Медицина",
            emoji: "💊",
            isIncome: .outcome
        ),
        Category(
            id: 8,
            name: "Машина",
            emoji: "🚗",
            isIncome: .outcome
        ),
        Category(
            id: 9,
            name: "Зарплата",
            emoji: "💊",
            isIncome: .income
        ),
        Category(
            id: 10,
            name: "Подработка",
            emoji: "🚗",
            isIncome: .income
        ),
        Category(
            id: 11,
            name: "Подарок",
            emoji: "🚗",
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

