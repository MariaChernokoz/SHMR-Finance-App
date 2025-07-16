//
//  CategoriesServise.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 14.06.2025.
//

import Foundation

final class CategoriesService: ObservableObject {
    static let shared = CategoriesService()
    //private let networkClient = NetworkClient()
    var categories: [Category] = []
    
    @Published private var mockCategories: [Category] = [
        Category(
            id: 1,
            name: "Аренда квартиры",
            emoji: "🏡",
            isIncome: false
        ),
        Category(
            id: 2,
            name: "Одежда",
            emoji: "🛍",
            isIncome: false
        ),
        Category(
            id: 3,
            name: "На собачку",
            emoji: "🐕",
            isIncome: false
        ),
        Category(
            id: 4,
            name: "Ремонт квартиры",
            emoji: "🛠",
            isIncome: false
        ),
        Category(
            id: 5,
            name: "Продукты",
            emoji: "🛒",
            isIncome: false
        ),
        Category(
            id: 6,
            name: "Спортзал",
            emoji: "🤸",
            isIncome: false
        ),
        Category(
            id: 7,
            name: "Медицина",
            emoji: "💊",
            isIncome: false
        ),
        Category(
            id: 8,
            name: "Машина",
            emoji: "🚗",
            isIncome: false
        ),
        Category(
            id: 9,
            name: "Зарплата",
            emoji: "🤑",
            isIncome: true
        ),
        Category(
            id: 10,
            name: "Подработка",
            emoji: "💸",
            isIncome: true
        ),
        Category(
            id: 11,
            name: "Подарок",
            emoji: "🎁",
            isIncome: true
        )
    ]
    
    private init() {}
    
    func allCategoriesList() async throws -> [Category] {
        do {
            let data = try await NetworkClient.shared.request(endpointValue: "/api/v1/categories")
            let decoder = JSONDecoder()
            let fetchedCategories = try decoder.decode([Category].self, from: data)
            categories = fetchedCategories
            return categories
        } catch {
            print("Error loading categories: \(error)")
            throw error
        }
    }

    func categories(direction: Direction) async throws -> [Category] {
        
        return mockCategories.filter { $0.direction == direction }
    }
}
