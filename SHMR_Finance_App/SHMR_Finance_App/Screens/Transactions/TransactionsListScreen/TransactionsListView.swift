//
//  TransactionsListView.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 17.06.2025.
//

import SwiftUI

struct TransactionsListView: View {
    @StateObject var viewModel: TransactionsListViewModel

    init(direction: Direction, transactionsService: TransactionsService, categoriesService: CategoriesService, bankAccountService: BankAccountsService) {
        _viewModel = StateObject(wrappedValue: TransactionsListViewModel(
            direction: direction,
            transactionsService: transactionsService,
            categoriesService: categoriesService,
            bankAccountService: bankAccountService
        ))
    }

    @ViewBuilder
    func totalAmountSection() -> some View {
        HStack {
            Text("Сумма")
            Spacer()
            AmountTextRow(amount: viewModel.totalAmount, color: .primary, currencyCode: viewModel.accountCurrency)
        }
    }
    
    @State private var showCreateTransaction = false
    @State private var editingTransaction: Transaction? = nil
    @Environment(\.colorScheme) var colorScheme
    
    private var titleSection: some View {
        Section {} header: {
            Text(viewModel.title)
                .font(.system(size: 34, weight: .bold))
                //.foregroundStyle(.black)
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .padding(.bottom, 12)
                .textCase(nil)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        }
    }
    
    private var operationsSection: some View {
        Section(header: Text("Операции")) {
            ForEach(viewModel.filteredTransactions) { transaction in
                let category = viewModel.categories.first(where: { $0.id == transaction.categoryId })

                TransactionRow(
                    transaction: transaction,
                    category: category,
                    direction: viewModel.direction,
                    style: .regular,
                    currencyCode: viewModel.accountCurrency
                )
                .onTapGesture {
                    editingTransaction = transaction
                }
            }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading && viewModel.filteredTransactions.isEmpty {
                    ProgressView()
                        .tint(.navigation)
                } else {
                    VStack(alignment: .leading, spacing: 5) {
                        List {
                            titleSection
                            totalAmountSection()
                            operationsSection
                        }
                        .listSectionSpacing(10)
                    }
                }
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            //viewModel.isCreatingTransaction = true
                            showCreateTransaction = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 60, weight: .thin))
                                .foregroundColor(Color("AccentColor"))
                                .padding()
                        }
                    }
                    .padding(.bottom, 8)
                    .padding(.trailing, -2)
                }
            }
            // Отображать экран модально: 
            // создание
            .fullScreenCover(isPresented: $showCreateTransaction) {
                CreateTransactionView(
                    viewModel: CreateTransactionViewModel(
                        direction: viewModel.direction,
                        mainAccountId: viewModel.accountId,
                        categories: viewModel.categories,
                        transactions: viewModel.transactions,
                        transactionsService: viewModel.transactionsService,
                        bankAccountService: viewModel.bankAccountService
                    ),
                    onSave: {
                        showCreateTransaction = false
                        Task {
                            await viewModel.loadData()
                        }
                    }
                )
            }
            // редактирование
            .fullScreenCover(item: $editingTransaction) { transaction in
                CreateTransactionView(
                    viewModel: CreateTransactionViewModel(
                        direction: viewModel.direction,
                        mainAccountId: viewModel.accountId,
                        categories: viewModel.categories,
                        transactions: viewModel.transactions,
                        transactionToEdit: transaction,
                        transactionsService: viewModel.transactionsService,
                        bankAccountService: viewModel.bankAccountService
                    ),
                    onSave: {
                        editingTransaction = nil
                        Task {
                            await viewModel.loadData()
                        }
                    }
                )
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: HistoryView(
                        direction: viewModel.direction,
                        viewModel: HistoryViewModel(
                            direction: viewModel.direction,
                            transactionsService: viewModel.transactionsService,
                            categoriesService: viewModel.categoriesService,
                            bankAccountService: viewModel.bankAccountService
                        )
                    )) {
                        Image(systemName: "clock")
                            .foregroundColor(.navigation)
                    }
                }
            }
        }
        .task {
            await viewModel.loadData()
        }
        .errorAlert(errorMessage: $viewModel.errorMessage)
    }
}

enum TransactionRowStyle {
    case regular
    case tall
}

// отображение транзакции (с rawTall и raw)
struct TransactionRow: View {
    let transaction: Transaction
    let category: Category?
    let direction: Direction
    var style: TransactionRowStyle
    let currencyCode: String

    var body: some View {
        let rowContent = HStack {
            if direction == .outcome {
                Circle()
                    .fill(Color("AccentColor").opacity(0.2))
                    .frame(width: 22, height: 22)
                    .overlay(Text(String(category?.emoji ?? "❓"))
                        .font(.system(size: 12))
                    )
                    .padding(.trailing, 8)
            }
            VStack(alignment: .leading, spacing: style == .tall ? 3 : 0) {
                if let comment = transaction.comment, !comment.isEmpty {
                    VStack(alignment: .leading, spacing: style == .tall ? 3 : 0) {
                        Text(category?.name ?? "неизвестная категория")
                        Text(comment)
                            .font(.system(size: style == .tall ? 15 : 13))
                            .foregroundColor(.gray)
                    }
                } else {
                    // Центрируем по высоте, если комментария нет
                    Text(category?.name ?? "неизвестная категория")
                        .frame(maxHeight: .infinity, alignment: .center)
                }
            }
            Spacer()
            VStack (alignment: .trailing){
                AmountTextRow(amount: transaction.amount, color: .primary, currencyCode: currencyCode)
                if style == .tall {
                    Text(transaction.transactionDate, style: .time)
                }
            }
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.caption)
        }
        if style == .tall {
            rowContent
                .frame(height: 40)
        } else { rowContent }
    }
}

#Preview {
    let networkClient = NetworkClient(token: "test")
    let appNetworkStatus = AppNetworkStatus()
    let bankAccountService = BankAccountsService(networkClient: networkClient, appNetworkStatus: appNetworkStatus)
    let categoriesService = CategoriesService(networkClient: networkClient, appNetworkStatus: appNetworkStatus)
    let transactionsService = TransactionsService(
        networkClient: networkClient,
        appNetworkStatus: appNetworkStatus,
        bankAccountsService: bankAccountService,
        categoriesService: categoriesService
    )
    return TransactionsListView(
        direction: .outcome,
        transactionsService: transactionsService,
        categoriesService: categoriesService,
        bankAccountService: bankAccountService
    )
}
