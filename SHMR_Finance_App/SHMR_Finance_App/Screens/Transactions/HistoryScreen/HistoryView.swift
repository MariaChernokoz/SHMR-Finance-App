//
//  HistoryView.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 18.06.2025.
//

import SwiftUI

struct HistoryView: View {
    
    let direction: Direction
    @StateObject var viewModel: HistoryViewModel
    
    init(direction: Direction) {
        self.direction = direction
        _viewModel = StateObject(wrappedValue: HistoryViewModel(direction: direction))
    }
    
    @Environment(\.dismiss) private var dismiss
    
    private var HistoryHeader: some View {
        Section {} header: {
            Text("Моя история")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(.black)
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
                Text(viewModel.amountFormatter(viewModel.totalAmount))
            }

            Section(header: Text("Операции")) {
                ForEach(viewModel.filteredTransactions) { transaction in
                    let category = viewModel.categories.first(where: { $0.id == transaction.categoryId })
                    TransactionRow(
                        transaction: transaction,
                        category: category,
                        direction: viewModel.direction,
                        amountFormatter: viewModel.amountFormatter,
                        style: .tall
                    )
                    .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
                }
            }
        }
        .listSectionSpacing(0)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGray6))
    }

    var body: some View {
        NavigationStack {
            transactionsList
        }
        .tint(Color.accentColor)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: AnalysisViewControllerWrapper(direction: direction, categories: viewModel.categories).edgesIgnoringSafeArea([.top])) {
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
        .errorAlert(errorMessage: $viewModel.errorMessage)
    }
}

#Preview {
    HistoryView(direction: .outcome)
}
