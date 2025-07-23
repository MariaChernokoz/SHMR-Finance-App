//
//  CategoriesServise.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 14.06.2025.
//

import Foundation

@MainActor
final class CategoriesService {
    
    private let localStore: CategoriesLocalStore
    private let networkClient: NetworkClient
    private let appNetworkStatus: AppNetworkStatus

    public init(networkClient: NetworkClient, appNetworkStatus: AppNetworkStatus) {
        self.localStore = try! SwiftDataCategoriesLocalStore()
        self.networkClient = networkClient
        self.appNetworkStatus = appNetworkStatus
    }
    
    func getAllCategories() async throws -> [Category] {
        do {
            let categories = try await networkClient.fetchDecodeData(endpointValue: "api/v1/categories", dataType: Category.self)
            appNetworkStatus.handleSuccessfulRequest()
            return categories
        } catch let error as NetworkError {
            appNetworkStatus.handleNetworkError(error)
            let localCategories = try await localStore.fetchAllCategories()
            if localCategories.isEmpty {
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
                print("[CategoriesService] Возвращаю тестовые категории")
                return testCategories
            }
            return localCategories
        } catch {
            let localCategories = try await localStore.fetchAllCategories()
            if localCategories.isEmpty {
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
                return testCategories
            }
            return localCategories
        }
    }
    
    func getCategory(by id: Int) async throws -> Category? {
        let categories = try await getAllCategories()
        return categories.first { $0.id == id }
    }
}
