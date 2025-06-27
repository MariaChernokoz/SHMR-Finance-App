//
//  BalanceSectionView.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 27.06.2025.
//

import SwiftUI

//На экране "Мой счет" добавляем строку с балансом

struct BalanceSectionView: View {
    @Binding var isEditing: Bool
    @Binding var editingBalance: String
    @FocusState.Binding var isBalanceFieldFocused: Bool
    @Binding var isBalanceHidden: Bool
    @ObservedObject var viewModel: AccountViewModel

    var body: some View {
        Section {
            HStack {
                Text("💰")
                    .padding(.trailing, 10)
                Text("Баланс")
                Spacer()
                //Редактирование баланса
                if isEditing {
                    TextField("", text: $editingBalance)
                        //отображаем клавиатуру
                        .keyboardType(.decimalPad)
                        .focused($isBalanceFieldFocused)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.trailing)
                        
                        //фильтровать невалидные для баланса символы
                        .onChange(of: editingBalance) { _, newValue in
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
                                editingBalance = filtered
                            }
                        }
                } else {
                    if isBalanceHidden {
                        Text(
                            viewModel.bankAccount.map { viewModel.formattedBalance($0.balance) } ?? ""
                        )
                            .spoiler(isOn: $isBalanceHidden)
                    } else {
                        Text(viewModel.bankAccount?.balance.formatted(.number.precision(.fractionLength(2))) ?? "-")
                            .transition(.opacity)
                    }
                }
            }
        }
        .listRowBackground(isEditing ? Color.white : Color.accentColor)
    }
}
