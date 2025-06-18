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
        var sum: Decimal = 0
        for transaction in filteredTransactions {
            sum += transaction.amount
        }
        return sum
    }
    
    //красивое отображение суммы (с пробелом)
    var totalAmountString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.maximumFractionDigits = 2
        return (formatter.string(for: totalAmount) ?? "0") + " ₽"
    }
    
    
    var body: some View {
        NavigationStack {
            
            VStack (alignment: .leading, spacing: 5 ){
                NavigationLink(destination: HistoryView()) {
                    Image(systemName: "clock")
                        .foregroundColor(.purple)
                        .font(.system(size: 22))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.horizontal, 20)
                }
                
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.horizontal, 20)
                
                // List по умолчанию лениво загружают ячейки (?)
                List {
                    HStack{
                        Text("Всего")
                        Spacer()
                        Text(totalAmountString)
                            .foregroundColor(.gray)
                        
                        // * разобраться с валютой (?) *
                    }
                    
                    Section(header: Text("Операции")) {
                        ForEach(filteredTransactions) { transaction in
                            
                            let category = categories.first(where: { $0.id == transaction.categoryId })
                            
                            // * можно вынести в отдельную функцию *
                            HStack {
                                // * сделать чтобы эмодзи не отображались в доходах *
                                // эмодзи
                                Circle()
                                    .fill(Color.green.opacity(0.25))
                                    .frame(width: 22, height: 22)
                                    .overlay(Text(String(category?.emoji ?? "❓"))
                                        .font(.caption)
                                    )
                                
                                VStack(alignment: .leading, spacing: 0) {
                                    Text(category?.name ?? "Категория \(transaction.categoryId)")
                                        .fontWeight(.medium)
                                    if let comment = transaction.comment {
                                        Text(comment)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                                
                                Spacer()
                                Text("\(transaction.amount) ₽")
                                    .fontWeight(.medium)
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                        }
                    }
                }
                .listSectionSpacing(10)
            }
            .background(Color(.systemGray6))
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
        }
        .tint(Color.purple)
    }
}

#Preview {
    TransactionsListView(direction: .outcome)
}
