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
    private var analysisViewModel: AnalysisViewModel
    
    init(direction: Direction) {
        self.direction = direction
        _viewModel = StateObject(wrappedValue: HistoryViewModel(direction: direction))
    }
    
    init(viewModel: MyHistoryViewModel, analysisViewModel: AnalysisViewModel) {
        self.viewModel = viewModel
        self.analysisViewModel = analysisViewModel
    }
    
    @Environment(\.dismiss) private var dismiss

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
        .tint(Color.accentColor)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    AnalysisView()
                    AnalysisViewControllerWrapper(
                        viewModel: analysisViewModel
                    )
                    .navigationBarBackButtonHidden(true)
                    .ignoresSafeArea()
                } label: {
                    Image(systemName: "document")
                        .foregroundColor(.navigation)
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack {
                        Image(systemName: "chevron.backward")
                        Text(LocalizedStringKey("Back"))
                        //Text("Назад")
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
 /*
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
                    .foregroundColor(Color("AccentColor"))
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
} */

/*
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
                            .fill(Color("AccentColor"))
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
} */

#Preview {
    HistoryView(direction: .outcome)
}
