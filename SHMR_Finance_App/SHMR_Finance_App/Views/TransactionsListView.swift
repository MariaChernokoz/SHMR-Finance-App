//
//  TransactionsListView.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 17.06.2025.
//

import SwiftUI

struct TransactionsListView: View {
    @StateObject var viewModel: TransactionsListViewModel

    init(direction: Direction) {
        _viewModel = StateObject(wrappedValue: TransactionsListViewModel(direction: direction))
    }

    @ViewBuilder
    func totalAmountSection() -> some View {
        HStack {
            Text("Сумма")
            Spacer()
            Text(viewModel.amountFormatter(viewModel.totalAmount))
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(alignment: .leading, spacing: 5) {
                    List {
                        Section {} header: {
                            Text(viewModel.title)
                                .font(.system(size: 34, weight: .bold))
                                .foregroundStyle(.black)
                                .padding(.bottom, 12)
                                .textCase(nil)
                                .listRowBackground(Color.clear)
                                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        }
                        totalAmountSection()

                        Section(header: Text("Операции")) {
                            ForEach(viewModel.filteredTransactions) { transaction in
                                let category = viewModel.categories.first(where: { $0.id == transaction.categoryId })

                                TransactionRow(
                                    transaction: transaction,
                                    category: category,
                                    direction: viewModel.direction,
                                    amountFormatter: viewModel.amountFormatter,
                                    style: .regular
                                )
                            }
                        }
                    }
                    .listSectionSpacing(10)
                }
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            viewModel.isCreatingTransaction = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 60, weight: .thin))
                                .foregroundColor(.accentColor)
                                .padding()
                        }
                    }
                    .padding(.bottom, 8)
                    .padding(.trailing, -2)
                }
            }
            .navigationDestination(isPresented: $viewModel.isCreatingTransaction) {
                CreateTransactionView()
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: HistoryView(direction: viewModel.direction)) {
                    Image(systemName: "clock")
                        .foregroundColor(.navigation)
                }
            }
        }
        .task {
            await viewModel.loadData()
        }
        .alert(isPresented: Binding<Bool>(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Alert(
                title: Text("Ошибка"),
                message: Text(viewModel.errorMessage ?? ""),
                dismissButton: .default(Text("OK"))
            )
        }
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
    let amountFormatter: (Decimal) -> String
    var style: TransactionRowStyle

    var body: some View {
        let rowContent = HStack {
            if direction == .outcome {
                Circle()
                    .fill(Color.accentColor.opacity(0.2))
                    .frame(width: 22, height: 22)
                    .overlay(Text(String(category?.emoji ?? "❓"))
                        .font(.system(size: 12))
                    )
                    .padding(.trailing, 8)
            }
            VStack(alignment: .leading, spacing: style == .tall ? 3 : 0) {
                Text(category?.name ?? "неизвестная категория")
                
                if let comment = transaction.comment {
                    Text(comment)
                        .font(.system(size: style == .tall ? 15 : 13))
                        .foregroundColor(.gray)
                }
            }
            Spacer()
            VStack (alignment: .trailing){
                Text(amountFormatter(transaction.amount))
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
    TransactionsListView(direction: .outcome)
}
