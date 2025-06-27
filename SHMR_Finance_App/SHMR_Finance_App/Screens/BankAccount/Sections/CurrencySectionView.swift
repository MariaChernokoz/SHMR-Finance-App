//
//  CurrencySectionView.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 27.06.2025.
//

import SwiftUI

//На экране "Мой счет" добавляем строку с валютой

struct CurrencySectionView: View {
    @Binding var isEditing: Bool
    @Binding var editingCurrency: String
    @Binding var isCurrencyDialogPresented: Bool
    @FocusState.Binding var isBalanceFieldFocused: Bool
    @ObservedObject var viewModel: AccountViewModel

    var body: some View {
        Section {
            HStack {
                Text("Валюта")
                Spacer()
                //Редактирование валюты
                if isEditing {
                    Button(action: {
                        isBalanceFieldFocused = false
                        isCurrencyDialogPresented = true
                    }) {
                        HStack {
                            Text(currencySymbol(for: editingCurrency))
                                .foregroundColor(.gray)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    //попап со списком валют
                    .confirmationDialog("Валюта", isPresented: $isCurrencyDialogPresented, titleVisibility: .visible) {
                        Button("Российский рубль ₽") {
                            if editingCurrency != "RUB" { editingCurrency = "RUB" }
                        }
                        Button("Американский доллар $") {
                            if editingCurrency != "USD" { editingCurrency = "USD" }
                        }
                        Button("Евро €") {
                            if editingCurrency != "EUR" { editingCurrency = "EUR" }
                        }
                    }
                } else {
                    Text(currencySymbol(for: viewModel.bankAccount?.currency ?? "-"))
                }
            }
        }
        .listRowBackground(isEditing ? Color.white : Color("AccentColor").opacity(0.2))
    }

    private func currencySymbol(for code: String) -> String {
        switch code {
        case "RUB": return "₽"
        case "USD": return "$"
        case "EUR": return "€"
        default: return code
        }
    }
}
