//
//  TransactionsListView.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 17.06.2025.
//

import SwiftUI

struct TransactionsListView: View {
    let direction: Direction
    
    @StateObject var transactionsService = TransactionsService()
    @State private var transactions: [Transaction] = []
    
    @StateObject var categoriesService = CategoriesService()
    @State private var categories: [Category] = []
    
    @State private var isCreatingTransaction = false
    
    var filteredTransactions: [Transaction] {
        transactions.filter { transaction in
            if let category = categories.first(where: { $0.id == transaction.categoryId }) {
                return category.isIncome == direction
            }
            return false
        }
    }
    
    var title: String {
        direction == .income ? "Доходы сегодня" : "Расходы сегодня"
    }
    
    var totalAmount: Decimal {
        filteredTransactions.reduce(0) { $0 + $1.amount }
    }
    
    @ViewBuilder
    func totalAmountSection() -> some View {
        HStack {
            Text("Сумма")
            Spacer()
            Text(amountFormatter(totalAmount))
        }
    }
    
    func amountFormatter(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.maximumFractionDigits = 2
        return (formatter.string(for: amount) ?? "0") + " ₽"
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack (alignment: .leading, spacing: 5 ){
                    List {
                        Section {} header: {
                            Text(title)
                                .font(.system(size: 34, weight: .bold))
                                .foregroundStyle(.black)
                                .padding(.bottom, 12)
                                .textCase(nil)
                                .listRowBackground(Color.clear)
                                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        }
                        totalAmountSection()
                        
                        Section(header: Text("Операции")) {
                            ForEach(filteredTransactions) { transaction in
                                
                                let category = categories.first(where: { $0.id == transaction.categoryId })
                                
                                TransactionRow(
                                    transaction: transaction,
                                    category: category,
                                    direction: direction,
                                    amountFormatter: amountFormatter,
                                    style: .regular
                                )
                            }
                        }
                    }
                    .listSectionSpacing(10)
                    .background(Color(.systemGray6))
                    
                }
                //.background(Color(.systemGray6))
                .task {
                    
                    do {
                        let today = transactionsService.todayInterval()
                        transactions = try await transactionsService.getTransactionsOfPeriod(interval: today)
                    } catch {
                        
                    }
                    
                    do {
                        categories = try await categoriesService.allCategoriesList()
                    } catch {
                        
                    }
                }
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            isCreatingTransaction = true
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
            .navigationDestination(isPresented: $isCreatingTransaction) {
                CreateTransactionView()
            }
            //.background(Color(.systemGray6))
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: HistoryView(direction: direction)) {
                    Image(systemName: "clock")
                        .foregroundColor(.navigation)
                }
            }
        }
    }
}

enum TransactionRowStyle {
    case regular
    case tall
}

// отображение транзакции (rawTall и raw)
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
                    if style == .tall {
                        Text(comment)
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                    } else {
                        Text(comment)
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                    }
                }
            }
            Spacer()
            Text(amountFormatter(transaction.amount))
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
