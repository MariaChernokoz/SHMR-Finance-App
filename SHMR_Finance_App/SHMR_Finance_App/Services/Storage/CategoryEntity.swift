import Foundation
import SwiftData

@Model
final class CategoryEntity {
    @Attribute(.unique) var id: Int
    var name: String
    var emoji: String
    var isIncome: Bool

    init(id: Int, name: String, emoji: String, isIncome: Bool) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.isIncome = isIncome
    }
} 