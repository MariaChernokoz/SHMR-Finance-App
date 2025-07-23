//
//  AccountView.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 16.06.2025.
//

import SwiftUI
import Charts

struct AccountView: View {
    @StateObject var viewModel = AccountViewModel()
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
                        isEditing: $viewModel.isEditing,
                        editingBalance: $viewModel.editingBalance,
                        isBalanceFieldFocused: $isBalanceFieldFocused,
                        isBalanceHidden: $isBalanceHidden,
                        viewModel: viewModel
                    )

                    //На экране "Мой счет" добавляем строку с валютой
                    CurrencySectionView(
                        isEditing: $viewModel.isEditing,
                        editingCurrency: $viewModel.editingCurrency,
                        isCurrencyDialogPresented: $isCurrencyDialogPresented,
                        isBalanceFieldFocused: $isBalanceFieldFocused,
                        viewModel: viewModel
                    )
                    
                    // График
                    if !viewModel.isEditing {
                        Section {
                            BalanceChartView(
                                historyDay: viewModel.balanceHistory,
                                historyMonth: viewModel.balanceHistoryMonth)
                                //.frame(height: 200)
                                .listRowBackground(Color.clear)
                        }
                        .padding(.top, 20)
                    }
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
                    Button(viewModel.isEditing ? "Сохранить" : "Редактировать") {
                        //режим редактирования
                        if viewModel.isEditing {
                            Task {
                                await viewModel.saveAccount(newBalance: viewModel.editingBalance, newCurrency: viewModel.editingCurrency)
                                // После сохранения обновляем поля для отображения
                                if let acc = viewModel.bankAccount {
                                    viewModel.editingBalance = acc.balance.formatted(.number.precision(.fractionLength(2)))
                                    viewModel.editingCurrency = acc.currency
                                }
                            }
                        //обычный режим (просмотр)
                        } else {
                            if let acc = viewModel.bankAccount {
                                viewModel.editingBalance = acc.balance.formatted(.number.precision(.fractionLength(2)))
                                viewModel.editingCurrency = acc.currency
                            }
                        }
                        viewModel.isEditing.toggle()
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
