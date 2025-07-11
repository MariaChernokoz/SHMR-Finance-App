//
//  EditAmountField.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 11.07.2025.
//

import SwiftUI

struct EditAmountField: View {
    @Binding var amount: String
    @FocusState.Binding var isFocused: Bool
    var placeholder: String = ""
    var textColor: Color = .gray
    var alignment: TextAlignment = .trailing

    var body: some View {
        TextField(placeholder, text: $amount)
            .keyboardType(.decimalPad)
            .focused($isFocused)
            .foregroundColor(textColor)
            .multilineTextAlignment(alignment)
            //фильтровать невалидные символы
            .onChange(of: amount) { newValue in
                // Оставляем только цифры, запятую и пробелы
                var filtered = newValue.filter { "0123456789, ".contains($0) }
                // Проверяем, что не больше одной запятой
                let components = filtered.components(separatedBy: ",")
                if components.count > 2 {
                    filtered = components[0] + "," + components[1]
                }
                // Ограничиваем количество знаков после запятой до 2
                if components.count == 2, let fractional = components.last {
                    let limitedFractional = String(fractional.prefix(2))
                    filtered = components[0] + "," + limitedFractional
                }
                if filtered != newValue {
                    amount = filtered
                }
            }
    }
}
