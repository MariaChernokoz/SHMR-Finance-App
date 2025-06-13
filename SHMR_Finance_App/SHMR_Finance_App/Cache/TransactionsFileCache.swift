//
//  TransactionsFileCache.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 14.06.2025.
//

import Foundation

class TransactionsFileCache {
    
    private(set) var transactions: [Transaction] = []
    let baseURL: URL

    init(directoryName: String = "TransactionsCache") {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.baseURL = documentsDirectory.appendingPathComponent(directoryName)
        try? FileManager.default.createDirectory(at: baseURL, withIntermediateDirectories: true)
    }

    func addTransaction(_ transaction: Transaction) throws {
        guard !transactions.contains(where: { $0.id == transaction.id }) else {
            throw CacheError.duplicateTransaction
        }
        transactions.append(transaction)
    }

    func removeTransaction(withId id: Int) {
        transactions.removeAll { $0.id == id }
    }

    func saveToFile(named fileName: String = "transactions.json") throws {
        let fileURL = baseURL.appendingPathComponent(fileName)
        let jsonObjects = transactions.compactMap { $0.jsonObject }
        let data = try JSONSerialization.data(withJSONObject: jsonObjects, options: .prettyPrinted)
        try data.write(to: fileURL, options: .atomic)
    }

    func loadFromFile(named fileName: String = "transactions.json") throws {
        let fileURL = baseURL.appendingPathComponent(fileName)
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            throw CacheError.fileNotFound
        }
        let data = try Data(contentsOf: fileURL)
        let jsonObjects = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] ?? []
        transactions = jsonObjects.compactMap { Transaction.parse(jsonObject: $0) }
    }

    enum CacheError: Error, LocalizedError {
        case duplicateTransaction
        case fileNotFound
        case invalidData

        var errorDescription: String? {
            switch self {
            case .duplicateTransaction: return "Transaction already exists in cache."
            case .fileNotFound: return "Cache file not found."
            case .invalidData: return "Invalid data format for cache file."
            }
        }
    }
}
