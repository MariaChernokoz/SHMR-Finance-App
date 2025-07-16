//
//  Category.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 14.06.2025.
//

import Foundation

struct Category: Identifiable, Hashable, Codable {
    let id: Int
    let name: String //Character
    let emoji: String
    let isIncome: Bool
    
    var direction: Direction {
        return isIncome ? .income : .outcome
    }
}

enum Direction: String, Codable {
    case income
    case outcome
}
