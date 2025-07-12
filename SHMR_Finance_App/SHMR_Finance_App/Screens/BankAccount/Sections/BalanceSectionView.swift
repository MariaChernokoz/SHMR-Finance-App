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
                    EditAmountField(
                            amount: $editingBalance,
                            isFocused: $isBalanceFieldFocused,
                            placeholder: "",
                            textColor: .gray,
                            alignment: .trailing
                        )
                } else {
                    if isBalanceHidden {
                        Text(viewModel.bankAccount?.balance.formatted(.number.precision(.fractionLength(2))) ?? "-")
                            .spoiler(isOn: $isBalanceHidden)
                    } else {
                        Text(viewModel.bankAccount?.balance.formatted(.number.precision(.fractionLength(2))) ?? "-")
                            .transition(.opacity)
                    }
                }
            }
        }
        .listRowBackground(isEditing ? Color.white : Color("AccentColor"))
    }
}
