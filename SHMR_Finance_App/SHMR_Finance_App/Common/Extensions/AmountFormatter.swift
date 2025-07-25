//
//  AmountFormatter.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 11.07.2025.
//

import Foundation

extension Formatter {
    static let amount: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.maximumFractionDigits = 2
        return formatter
    }()
}

extension Double {
    var formattedAmount: String {
        Formatter.amount.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

extension Decimal {
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.maximumFractionDigits = 2
        return formatter.string(for: self) ?? "0"
    }
}

func currencySymbol(for code: String) -> String {
    switch code.uppercased() {
    case "RUB": return "₽"
    case "USD": return "$"
    case "EUR": return "€"
    default: return code
    }
}
