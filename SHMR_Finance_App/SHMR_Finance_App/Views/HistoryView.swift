//
//  HistoryView.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 18.06.2025.
//

import SwiftUI

struct HistoryView: View {
    @Environment(\.dismiss) private var dismiss
    
    let direction: Direction
    
    //месяц назад, 00:00
    @State private var startDate: Date = Calendar.current.date(
        byAdding: .month,
        value: -1,
        to: Calendar.current.startOfDay(for: Date())
    ) ?? Calendar.current.startOfDay(for: Date())
    
    //сегодня, 23:59
    @State private var endDate: Date = {
        let today = Calendar.current.startOfDay(for: Date())
        return Calendar.current.date(bySettingHour: 23, minute: 59, second: 0, of: today) ?? Date()
    }()
    
    @StateObject var transactionsService = TransactionsService()
    @State private var transactions: [Transaction] = []
    
    @StateObject var categoriesService = CategoriesService()
    @State private var categories: [Category] = []
    
    var filteredTransactionss: [Transaction] {
        transactions.filter { transaction in
            if let category = categories.first(where: { $0.id == transaction.categoryId }) {
                return category.isIncome == direction
            }
            return false
        }
    }
    
    var filteredTransactions: [Transaction] {
        let filtered = transactions.filter { transaction in
            if let category = categories.first(where: { $0.id == transaction.categoryId }) {
                return category.isIncome == direction
            }
            return false
        }
        switch sortType {
        case .date:
            return filtered.sorted { $0.transactionDate > $1.transactionDate }
        case .amount:
            return filtered.sorted { $0.amount > $1.amount }
        }
    }
    
    var totalAmount: Decimal {
        var sum: Decimal = 0
        for transaction in filteredTransactions {
            sum += transaction.amount
        }
        return sum
    }
    
    var totalAmountString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.maximumFractionDigits = 2
        return (formatter.string(for: totalAmount) ?? "0") + " ₽"
    }
    
    enum SortType: String, CaseIterable, Identifiable {
        case date = "По дате"
        case amount = "По сумме"
        var id: String { self.rawValue }
    }

    @State private var sortType: SortType = .date
    
    
    var body: some View {
        NavigationStack {
            
            VStack (alignment: .leading, spacing: 5 ){ 
                
                List {
                    Section {} header: {
                        Text("Моя история")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundStyle(.black)
                            .padding(.bottom, 9)
                            .textCase(nil)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        
                    }
                    
                    HStack {
                        Text("Начало")
                        Spacer()
                        HStack {
                            Text(startDate.formatted(.dateTime.day().month().year()))
                        }
                        .padding(.horizontal, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .foregroundColor(.accentColor)
                                .opacity(0.2)
                                .padding(.vertical, -7))
                        
                        .overlay {
                            DatePicker(selection: $startDate, displayedComponents: .date) {}
                                .labelsHidden()
                                .colorMultiply(.clear)
                        }
                    }
                    
                    HStack {
                        Text("Конец")
                        Spacer()
                        HStack {
                            Text(endDate.formatted(.dateTime.day().month().year()))
                        }
                        .padding(.horizontal, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .foregroundColor(.accentColor)
                                .opacity(0.2)
                                .padding(.vertical, -7))
                        
                        .overlay {
                            DatePicker(selection: $endDate, displayedComponents: .date) {}
                                .labelsHidden()
                                .colorMultiply(.clear)
                        }
                    }
                    
                    HStack {
                        Text("Сортировка")
                        Spacer()
                        ZStack {
                            Text(sortType.rawValue)
                                .font(.system(size: 17, weight: .regular))
                                .foregroundColor(.black)
                                .padding(.horizontal, 15)
                                .padding(.vertical, 7)
                                .background(
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .fill(Color.accentColor)
                                        .opacity(0.2)
                                )
                            Picker("", selection: $sortType) {
                                ForEach(SortType.allCases) { type in
                                    Text(type.rawValue).tag(type)
                                }
                            }
                            .labelsHidden()
                            .blendMode(.destinationOver)
                            .contentShape(Rectangle())
                        }
                    }
                    HStack {
                        Text("Сумма")
                        Spacer()
                        Text(totalAmountString)
                    }
                    
                    Section(header: Text("Операции")) {
                        ForEach(filteredTransactions) { transaction in
                            
                            let category = categories.first(where: { $0.id == transaction.categoryId })
                            
                            // * можно вынести в отдельную функцию *
                            HStack {
                                // * сделать чтобы эмодзи не отображались в доходах *
                                if direction == .outcome {
                                    Circle()
                                        .fill(Color.accentColor.opacity(0.2))
                                        .frame(width: 22, height: 22)
                                        .overlay(Text(String(category?.emoji ?? "❓"))
                                            .font(.system(size: 12))
                                        )
                                        .padding(.trailing, 8)
                                }
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
                .listSectionSpacing(0)
            }
            .background(Color(.systemGray6))
            .task {
                
                do {
                    let interval = DateInterval(start: startDate, end: endDate)
                    transactions = try await transactionsService.getTransactionsOfPeriod(interval: interval)
                } catch {
                    
                }
                
                do {
                    categories = try await categoriesService.allCategoriesList()
                } catch {
                    
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: AnalysisView()) {
                    Image(systemName: "document")
                        .foregroundColor(.purple)
                }
            }
        }
        .tint(Color.accentColor)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack {
                        Image(systemName: "chevron.backward")
                        Text("Назад")
                    }
                    .tint(Color.purple)
                }
            }
        }
    }
}

#Preview {
    HistoryView(direction: .outcome)
}
