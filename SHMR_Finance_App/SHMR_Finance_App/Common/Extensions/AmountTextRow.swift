//
//  AmountTextRow.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 11.07.2025.
//

import Foundation
import SwiftUI

struct AmountTextRow: View {
    let amount: Decimal
    let color: Color
    let currencyCode: String

    var body: some View {
        Text(amount.formattedAmount + " " + currencySymbol(for: currencyCode))
            .foregroundColor(color)
    }
}
