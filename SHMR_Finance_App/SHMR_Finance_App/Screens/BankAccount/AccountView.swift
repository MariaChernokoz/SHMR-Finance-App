//
//  AccountView.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 16.06.2025.
//

import SwiftUI

struct AccountView: View {
    @StateObject var viewModel = AccountViewModel()
    @State var isEditing = false
    @State var editingBalance: String = ""
    @State var editingCurrency: String = ""
    @FocusState var isBalanceFieldFocused: Bool
    @State private var isBalanceHidden = false
    @State private var isCurrencyDialogPresented = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    Section {} header: {
                        Text("Мой счет")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundStyle(.black)
                            .padding(.bottom, 12)
                            .textCase(nil)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 2, leading: 0, bottom: -5, trailing: 0))
                    }
                    //На экране "Мой счет" добавляем строку с балансом
                    BalanceSectionView(
                        isEditing: $isEditing,
                        editingBalance: $editingBalance,
                        isBalanceFieldFocused: $isBalanceFieldFocused,
                        isBalanceHidden: $isBalanceHidden,
                        viewModel: viewModel
                    )

                    //На экране "Мой счет" добавляем строку с валютой
                    CurrencySectionView(
                        isEditing: $isEditing,
                        editingCurrency: $editingCurrency,
                        isCurrencyDialogPresented: $isCurrencyDialogPresented,
                        isBalanceFieldFocused: $isBalanceFieldFocused,
                        viewModel: viewModel
                    )
                }
                .listSectionSpacing(16)
                //Клавиатура скрывается при свайпе по экрану
                .scrollDismissesKeyboard(.immediately)
                //Pull to refresh (*)
                .refreshable {
                    await viewModel.loadAccount()
                }
                //Скрытие/отображение баланса по тряске (**)
                ShakeDetector {
                    withAnimation {
                        isBalanceHidden.toggle()
                    }
                }
                .allowsHitTesting(false)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    //Кнопка "Редактировать" в навбаре
                    Button(isEditing ? "Сохранить" : "Редактировать") {
                        //режим редактирования
                        if isEditing {
                            Task {
                                await viewModel.saveAccount(newBalance: editingBalance, newCurrency: editingCurrency)
                            }
                        //обычный режим (просмотр)
                        } else {
                            if let acc = viewModel.bankAccount {
                                editingBalance = acc.balance.formatted(.number.precision(.fractionLength(2)))
                                editingCurrency = acc.currency
                            }
                        }
                        isEditing.toggle()
                    }
                    .foregroundColor(.navigation)
                }
            }
            .task {
                await viewModel.loadAccount()
            }
        }
    }
}

#Preview {
    AccountView()
}
