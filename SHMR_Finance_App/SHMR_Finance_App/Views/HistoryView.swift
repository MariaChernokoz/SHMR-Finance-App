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
    
    @State private var sortType: SortType = .date
    
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
        filteredTransactions.reduce(0) { $0 + $1.amount }
    }
    
    func amountFormatter (_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.maximumFractionDigits = 2
        return (formatter.string(for: amount) ?? "0") + " ₽"
    }
    
    var body: some View {
        NavigationStack {
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
                
                DatePickerRow(title: "Начало", date: $startDate)
                DatePickerRow(title: "Конец", date: $endDate)
                SortPickerRow(title: "Сортировка", sortType: $sortType)
                
                HStack {
                    Text("Сумма")
                    Spacer()
                    Text(amountFormatter(totalAmount))
                }
                
                Section(header: Text("Операции")) {
                    ForEach(filteredTransactions) { transaction in
                        
                        let category = categories.first(where: { $0.id == transaction.categoryId })
                        
                        TransactionRow(
                            transaction: transaction,
                            category: category,
                            direction: direction,
                            amountFormatter: amountFormatter,
                            style: .tall
                        )
                        .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
                    }
                }
            }
            .listSectionSpacing(0)
            .scrollContentBackground(.hidden)
            .background(Color(.systemGray6))
            .onChange(of: startDate) {
                // время начала на 00:00:00
                let correctedStartDate = Calendar.current.startOfDay(for: startDate)
                if startDate != correctedStartDate {
                    startDate = correctedStartDate
                }

                // если начало > конца, двигаем конец
                if correctedStartDate > endDate {
                    let endOfNewDay = Calendar.current.date(bySettingHour: 23, minute: 59, second: 0, of: correctedStartDate) ?? correctedStartDate
                    endDate = endOfNewDay
                }
            }
            .onChange(of: endDate) {
                // время конца на 23:59:00
                let startOfDay = Calendar.current.startOfDay(for: endDate)
                let correctedEndDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 0, of: startOfDay) ?? endDate
                if endDate != correctedEndDate {
                    endDate = correctedEndDate
                }

                // если конец < начала, двигаем начало
                if correctedEndDate < startDate {
                    startDate = Calendar.current.startOfDay(for: correctedEndDate)
                }
            }
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
        .tint(Color.accentColor)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: AnalysisView()) {
                    Image(systemName: "document")
                        .foregroundColor(.navigation)
                }
            }
            // back button
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack {
                        Image(systemName: "chevron.backward")
                        Text("Назад")
                    }
                    .tint(.navigation)
                }
            }
        }
    }
}

struct DatePickerRow: View {
    let title: String
    @Binding var date: Date
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            HStack {
                Text(date.formatted(.dateTime.day().month().year()))
            }
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .foregroundColor(.accentColor)
                    .opacity(0.2)
                    .padding(.vertical, -7)
            )
            .overlay {
                DatePicker(selection: $date, displayedComponents: .date) {}
                    .labelsHidden()
                    .colorMultiply(.clear)
            }
        }
    }
}

enum SortType: String, CaseIterable, Identifiable {
    case date = "По дате"
    case amount = "По сумме"
    var id: String { self.rawValue }
}

struct SortPickerRow: View {
    let title: String
    @Binding var sortType: SortType
    
    var body: some View {
        HStack {
            Text(title)
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
    }
}

#Preview {
    HistoryView(direction: .outcome)
}
