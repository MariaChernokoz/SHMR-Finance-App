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
    
    var body: some View {
        VStack (alignment: .leading, spacing: 15 ){
            
            Image(systemName: "clock")
                .foregroundColor(.purple)
                .font(.system(size: 22))
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.horizontal, 20)
            
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            //всего
            HStack{
                Text("Всего")
                Spacer()
                Text("100 ₽")
                    .foregroundColor(.gray)
            }
            .padding(15)
            .background(Color(.white))
            .cornerRadius(10)
            .padding(.horizontal, 20)
            
            //операции
            Text("ОПЕРАЦИИ")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.horizontal, 30)
                .padding(.top, 5)
            
            
            List(filteredTransactions) { transaction in
                
                let category = categories.first(where: { $0.id == transaction.categoryId })
                HStack {
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
        .background(Color(.systemGray6))
        .task {

            //получение транзакций за сегодня
            do {
                let today = transactionsService.todayInterval()
                transactions = try await transactionsService.getTransactionsOfPeriod(interval: today)
            } catch {
                
            }
            
            //категории
            do {
                categories = try await categoriesService.allCategoriesList()
            } catch {
                
            }
        }
    }
}

#Preview {
    TransactionsListView(direction: .outcome)
}
