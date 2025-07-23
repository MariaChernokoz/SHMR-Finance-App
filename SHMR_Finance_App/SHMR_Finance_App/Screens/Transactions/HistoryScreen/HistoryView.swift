//
//  HistoryView.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 18.06.2025.
//

import SwiftUI

struct HistoryView: View {
    
    let direction: Direction
    @ObservedObject var viewModel: HistoryViewModel
    
    init(direction: Direction, viewModel: HistoryViewModel) {
        self.direction = direction
        self.viewModel = viewModel
    }
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    private var HistoryHeader: some View {
        Section {} header: {
            Text("Моя история")
                .font(.system(size: 34, weight: .bold))
                //.foregroundStyle(.black)
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .padding(.bottom, 9)
                .textCase(nil)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        }
    }
    
    private var transactionsList: some View {
        List {
            HistoryHeader

            DatePickerRow(title: "Начало", date: $viewModel.startDate)
                .onChange(of: viewModel.startDate) {
                    viewModel.applyStartDateFilter()
                }
            DatePickerRow(title: "Конец", date: $viewModel.endDate)
                .onChange(of: viewModel.endDate) {
                    viewModel.applyEndDateFilter()
                }
            SortPickerRow(title: "Сортировка", sortType: $viewModel.sortType)

            HStack {
                Text("Сумма")
                Spacer()
                AmountTextRow(amount: viewModel.totalAmount, color: .primary, currencyCode: viewModel.accountCurrency)
            }

            Section(header: Text("Операции")) {
                ForEach(viewModel.filteredTransactions) { transaction in
                    let category = viewModel.categories.first(where: { $0.id == transaction.categoryId })
                    TransactionRow(
                        transaction: transaction,
                        category: category,
                        direction: viewModel.direction,
                        style: .tall,
                        currencyCode: viewModel.accountCurrency
                    )
                    .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
                }
                .onDelete { indexSet in
                    Task {
                        await viewModel.deleteTransactions(at: indexSet)
                    }
                }
            }
        }
        .listSectionSpacing(0)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGray6))
    }

    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading && viewModel.filteredTransactions.isEmpty {
                    ProgressView()
                        .tint(.navigation)
                } else {
                    transactionsList
                }
            }
            .errorAlert(errorMessage: $viewModel.errorMessage)
        }
        .tint(Color.accentColor)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: AnalysisViewControllerWrapper(
                    direction: direction,
                    categories: viewModel.categories,
                    transactionsService: viewModel.transactionsService,
                    bankAccountService: viewModel.bankAccountService
                ).edgesIgnoringSafeArea([.top])) {
                    Image(systemName: "document")
                        .foregroundColor(.navigation)
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack {
                        Image(systemName: "chevron.backward")
                        Text(LocalizedStringKey("Back"))
                    }
                    .tint(.navigation)
                }
            }
        }
        .task {
            await viewModel.loadData()
        }
    }
}

#Preview {
    HistoryView(direction: .outcome, viewModel: HistoryViewModel(
        direction: .outcome,
        transactionsService: TransactionsService(
            networkClient: NetworkClient(token: "test"),
            appNetworkStatus: AppNetworkStatus(),
            bankAccountsService: BankAccountsService(networkClient: NetworkClient(token: "test"), appNetworkStatus: AppNetworkStatus()),
            categoriesService: CategoriesService(networkClient: NetworkClient(token: "test"), appNetworkStatus: AppNetworkStatus())
        ),
        categoriesService: CategoriesService(networkClient: NetworkClient(token: "test"), appNetworkStatus: AppNetworkStatus()),
        bankAccountService: BankAccountsService(networkClient: NetworkClient(token: "test"), appNetworkStatus: AppNetworkStatus())
    ))
}
