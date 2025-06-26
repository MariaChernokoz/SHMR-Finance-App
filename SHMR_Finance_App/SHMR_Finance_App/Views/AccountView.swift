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

    private var balanceSection: some View {
        Section {
            HStack {
                Text("💰")
                    .padding(.trailing, 10)
                Text("Баланс")
                Spacer()
                if isEditing {
                    TextField("", text: $editingBalance)
                        .keyboardType(.decimalPad)
                        .focused($isBalanceFieldFocused)
                        .onAppear { isBalanceFieldFocused = true }
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.trailing)
                        .onChange(of: editingBalance) { _, newValue in
                            let filtered = newValue.filter { "0123456789, ".contains($0) }
                            if filtered != newValue {
                                editingBalance = filtered
                            }
                        }
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
        .listRowBackground(isEditing ? Color.white : Color.accentColor)
    }
    
    @State private var isCurrencyDialogPresented = false

    private var currencySection: some View {
        Section {
            HStack {
                Text("Валюта")
                Spacer()
                if isEditing {
                    Button(action: {
                        isCurrencyDialogPresented = true
                    }) {
                        HStack {
                            Text(currencySymbol(for: editingCurrency))
                                .foregroundColor(.gray)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                    .confirmationDialog("Валюта", isPresented: $isCurrencyDialogPresented, titleVisibility: .visible) {
                        Button("Российский рубль ₽") { editingCurrency = "RUB" }
                        Button("Американский доллар $") { editingCurrency = "USD" }
                        Button("Евро €") { editingCurrency = "EUR" }
                    }
                    //.foregroundColor(Color.navigation)
                } else {
                    Text(currencySymbol(for: viewModel.bankAccount?.currency ?? "-"))
                }
            }
        }
        .listRowBackground(isEditing ? Color.white : Color.accentColor.opacity(0.2))
    }
    
    func currencySymbol(for code: String) -> String {
        switch code {
        case "RUB": return "₽"
        case "USD": return "$"
        case "EUR": return "€"
        default: return code
        }
    }
    
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
                    balanceSection
                    currencySection
                    //Section(footer: Text(" ")) { EmptyView() }
                }
                .listSectionSpacing(16)
                .scrollDismissesKeyboard(.immediately)
                //.ignoresSafeArea(.keyboard, edges: .bottom)
                .refreshable {
                    await viewModel.loadAccount()
                }
                ShakeDetector {
                    withAnimation {
                        isBalanceHidden.toggle()
                    }
                }
                .allowsHitTesting(false)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Сохранить" : "Редактировать") {
                        if isEditing {
                            Task {
                                await viewModel.saveAccount(newBalance: editingBalance, newCurrency: editingCurrency)
                            }
                        } else {
                            if let acc = viewModel.bankAccount {
                                editingBalance = acc.balance.formatted(.number.precision(.fractionLength(2)))
                                editingCurrency = acc.currency
                                print("editingBalance при входе в режим редактирования:", editingBalance)
                                print("editingCurrency при входе в режим редактирования:", editingCurrency)
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

func currencySymbol(for code: String) -> String {
    switch code {
    case "RUB": return "₽"
    case "EUR": return "€"
    case "USD": return "$"
    default: return code
    }
}

#Preview {
    AccountView()
}
