import SwiftUI

struct CreateTransactionView: View {
    @StateObject var viewModel: CreateTransactionViewModel
    let onSave: (() -> Void)? // callback для закрытия/обновления списка после создания/редактирования

    @State private var showAlert = false
    @State private var isLoading = false
    
    @FocusState private var isAmountFocused: Bool
    @State private var showDatePicker = false
    @State private var showTimePicker = false
    @FocusState private var isCommentFocused: Bool

    var filteredCategories: [Category] {
        viewModel.categories.filter { $0.isIncome == viewModel.direction }
    }

    var isEdit: Bool { viewModel.transactionToEdit != nil }
    
    var navTitle: String {
        viewModel.direction == .income ? "Мои доходы" : "Мои расходы"
    }
    var deleteButtonTitle: String {
        viewModel.direction == .income ? "Удалить доход" : "Удалить расход"
    }
    
    // Форматтеры для даты и времени
    var formattedDate: String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "ru_RU")
        df.dateFormat = "d MMMM"
        return df.string(from: viewModel.date)
    }
    var formattedTime: String {
        let tf = DateFormatter()
        tf.locale = Locale(identifier: "ru_RU")
        tf.dateFormat = "HH:mm"
        return tf.string(from: viewModel.date)
    }

    var body: some View {
        NavigationView {
            List {
                Section {} header: {
                    Text(navTitle)
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(.black)
                        .padding(.bottom, -8)
                        .textCase(nil)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                }
                
                // Picker с фильтрацией по direction
                HStack {
                    Text("Статья")
                        .foregroundColor(.primary)
                    Spacer()
                    ZStack {
                        HStack(spacing: 16) {
                            Text(viewModel.selectedCategory?.name ?? "")
                                .foregroundColor(.gray)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 15))
                                .foregroundColor(.gray)
                        }
                        Picker("", selection: $viewModel.selectedCategory) {
                            ForEach(viewModel.filteredCategories) { category in
                                Text(category.name).tag(Optional(category))
                            }
                        }
                        .labelsHidden()
                        .opacity(0) // Picker невидимый, но кликабельный
                        .contentShape(Rectangle())
                    }
                }
                
                // Сумма
                HStack {
                    Text("Сумма")
                    Spacer()
                    ZStack(alignment: .trailing) {
                        if viewModel.amount.isEmpty {
                            Text("0 ₽")
                                .foregroundColor(.gray)
                        } else {
                            let amountDecimal = Decimal(string: viewModel.amount.replacingOccurrences(of: ",", with: ".")) ?? 0
                            Text(amountDecimal.formattedAmount + " ₽")
                                .foregroundColor(.gray)
                        }
                        EditAmountField(
                            amount: $viewModel.amount,
                            isFocused: $isAmountFocused,
                            placeholder: "",
                            textColor: .clear,
                            alignment: .trailing
                        )
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture { isAmountFocused = true }
                
                // Дата и время
                DatePickerRow(title: "Дата", date: $viewModel.date)
                TimePickerRow(title: "Время", date: $viewModel.date)

                // Комментарий
                TextField("Комментарий", text: $viewModel.comment)
                    .foregroundColor(.primary)
                    .keyboardType(.default)
                    .focused($isCommentFocused)
                    .onTapGesture { isCommentFocused = true }
                
                // Удалить (у редактирования)
                Section {
                    if isEdit {
                        Button(deleteButtonTitle) {
                            viewModel.delete(onDelete: {
                                onSave?()
                            })
                        }
                        .foregroundColor(.red)
                        .disabled(viewModel.isLoading)
                    }
                }
                .listSectionSpacing(50)
            }
            .scrollDismissesKeyboard(.immediately)
            .listStyle(.insetGrouped)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        onSave?()
                    }
                    .tint(.navigation)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEdit ? "Сохранить" : "Создать") {
                        if isEdit {
                            viewModel.save(onSave: onSave ?? {})
                        } else {
                            viewModel.create(onSave: onSave ?? {})
                        }
                    }
                    .tint(.navigation)
                    .fontWeight(.regular)
                    .disabled(viewModel.isLoading)
                }
            }
            .alert(isPresented: $viewModel.showAlert) {
                Alert(title: Text("Ошибка"), message: Text("Пожалуйста, заполните все поля корректно"), dismissButton: .default(Text("Ок")))
            }
            .task {
                await viewModel.loadAccount()
            }
        }
    }
}

#Preview {
    let testCategories = [
        Category(id: 1, name: "Продукты", emoji: "🍏", isIncome: .income),
        Category(id: 2, name: "Зарплата", emoji: "💸", isIncome: .outcome)
    ]
    let testTransactions = [
        Transaction(id: 1, accountId: 1, categoryId: 1, amount: 1010, transactionDate: Date(), comment: "test", createdAt: Date(), updatedAt: Date())
    ]
    // создание
    CreateTransactionView(
        viewModel: CreateTransactionViewModel(
            direction: .outcome,
            mainAccountId: 1,
            categories: testCategories,
            transactions: testTransactions
        ),
        onSave: {}
    )
    // редактирование
    CreateTransactionView(
        viewModel: CreateTransactionViewModel(
            direction: .outcome,
            mainAccountId: 1,
            categories: testCategories,
            transactions: testTransactions,
            transactionToEdit: testTransactions[0]
        ),
        onSave: {}
    )
}
