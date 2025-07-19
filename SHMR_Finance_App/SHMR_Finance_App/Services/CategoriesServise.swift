//
//  CategoriesServise.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 14.06.2025.
//

import Foundation

@MainActor
final class CategoriesService: ObservableObject {
    static let shared: CategoriesService = {
        let service = CategoriesService()
        return service
    }()

    private let localStore: CategoriesLocalStore

    private init() {
        do {
            let localStore = try SwiftDataCategoriesLocalStore()
            self.localStore = localStore
        } catch {
            assertionFailure("Failed to initialize CategoriesService storage: \(error)")
            fatalError("Critical: Unable to initialize CategoriesService storage")
        }
    }

    // Получить все категории
    func getAllCategories() async throws -> [Category] {
        do {
            // Сетевой запрос для получения категорий
            let categories = try await NetworkClient.shared.fetchDecodeData(endpointValue: "api/v1/categories", dataType: Category.self)
            
            // Уведомляем об успешном запросе
            AppNetworkStatus.shared.handleSuccessfulRequest()
            
            // Сохраняем категории в локальное хранилище
            for category in categories {
                try await localStore.addCategory(category)
            }
            
            return categories
        } catch let error as NetworkError {
            print("❌ Сетевая ошибка загрузки категорий: \(error.userFriendlyMessage)")
            
            // Уведомляем о сетевой ошибке
            AppNetworkStatus.shared.handleNetworkError(error)
            
            // Если сетевой запрос не удался, возвращаем из локального хранилища
            let localCategories = try await localStore.fetchAllCategories()
            
            // Если локальное хранилище тоже пустое, создаем тестовые категории
            if localCategories.isEmpty {
                print("🔍 Создаю тестовые категории...")
                let testCategories = [
                    Category(id: 1, name: "Продукты", emoji: "🛒", isIncome: false),
                    Category(id: 2, name: "Транспорт", emoji: "🚗", isIncome: false),
                    Category(id: 3, name: "Развлечения", emoji: "🎮", isIncome: false),
                    Category(id: 4, name: "Зарплата", emoji: "💰", isIncome: true),
                    Category(id: 5, name: "Подарки", emoji: "🎁", isIncome: true),
                    Category(id: 6, name: "Здоровье", emoji: "🏥", isIncome: false),
                    Category(id: 7, name: "Красота", emoji: "💄", isIncome: false),
                    Category(id: 8, name: "Образование", emoji: "📚", isIncome: false),
                    Category(id: 9, name: "Хобби", emoji: "🎨", isIncome: false),
                    Category(id: 10, name: "Домашние животные", emoji: "🐾", isIncome: false),
                    Category(id: 11, name: "Рестораны", emoji: "🍽️", isIncome: false)
                ]
                
                for category in testCategories {
                    try await localStore.addCategory(category)
                }
                
                return testCategories
            }
            
            return localCategories
        } catch {
            print("❌ Неожиданная ошибка загрузки категорий: \(error)")
            
            // В случае любой другой ошибки также возвращаем из локального хранилища
            let localCategories = try await localStore.fetchAllCategories()
            
            if localCategories.isEmpty {
                print("🔍 Создаю тестовые категории...")
                let testCategories = [
                    Category(id: 1, name: "Продукты", emoji: "🛒", isIncome: false),
                    Category(id: 2, name: "Транспорт", emoji: "🚗", isIncome: false),
                    Category(id: 3, name: "Развлечения", emoji: "🎮", isIncome: false),
                    Category(id: 4, name: "Зарплата", emoji: "💰", isIncome: true),
                    Category(id: 5, name: "Подарки", emoji: "🎁", isIncome: true),
                    Category(id: 6, name: "Здоровье", emoji: "🏥", isIncome: false),
                    Category(id: 7, name: "Красота", emoji: "💄", isIncome: false),
                    Category(id: 8, name: "Образование", emoji: "📚", isIncome: false),
                    Category(id: 9, name: "Хобби", emoji: "🎨", isIncome: false),
                    Category(id: 10, name: "Домашние животные", emoji: "🐾", isIncome: false),
                    Category(id: 11, name: "Рестораны", emoji: "🍽️", isIncome: false)
                ]
                
                for category in testCategories {
                    try await localStore.addCategory(category)
                }
                
                return testCategories
            }
            
            return localCategories
        }
    }

    // Добавить/обновить категорию
    func saveCategory(_ category: Category) async throws {
        do {
            // let request = ... // подготовить сетевой запрос
            // try await NetworkClient.shared.request(...)
            try await localStore.updateCategory(category)
        } catch {
            try await localStore.updateCategory(category)
        }
    }

    // Удалить категорию
    func deleteCategory(by id: Int) async throws {
        do {
            // try await NetworkClient.shared.request(...)
            try await localStore.deleteCategory(by: id)
        } catch {
            try await localStore.deleteCategory(by: id)
        }
    }
    
    // Получить категорию по ID
    func getCategory(by id: Int) async throws -> Category? {
        let categories = try await getAllCategories()
        return categories.first { $0.id == id }
    }
}
