//
//  Category.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 14.06.2025.
//

import Foundation

struct Category {
    let id: Int
    let name: String
    let emoji: Character
    let isIncome: Direction
}

enum Direction: String, Codable {
    case income
    case outcome
}
