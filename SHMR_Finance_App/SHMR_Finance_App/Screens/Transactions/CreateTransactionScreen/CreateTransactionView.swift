import SwiftUI

struct CreateTransactionView: View {
    @ObservedObject var viewModel: CreateTransactionViewModel
    let onSave: (() -> Void)?

    @FocusState private var isAmountFocused: Bool
    @FocusState private var isCommentFocused: Bool

    var isEdit: Bool { viewModel.transactionToEdit != nil }
    var navTitle: String {
        viewModel.direction == .income ? "Мои доходы" : "Мои расходы"
    }
    var deleteButtonTitle: String {
        viewModel.direction == .income ? "Удалить доход" : "Удалить расход"
    }
    
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationView {
            List {
                Section {} header: {
                    Text(navTitle)
                        .font(.system(size: 34, weight: .bold))
                        //.foregroundStyle(.black)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .padding(.bottom, -8)
                        .textCase(nil)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                }
                // Категория
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
                                Text(category.name).tag(category as Category?)
                            }
                        }
                        .labelsHidden()
                        .opacity(0)
                        .contentShape(Rectangle())
                    }
                }
                // Сумма
                HStack {
                    Text("Сумма")
                    Spacer()
                    ZStack(alignment: .trailing) {
                        if viewModel.amount.isEmpty {
                            Text("0 " + currencySymbol(for: viewModel.accountCurrency)).foregroundColor(.gray)
                        } else {
                            let amountDecimal = Decimal(string: viewModel.amount.replacingOccurrences(of: ",", with: ".")) ?? 0
                            Text(amountDecimal.formattedAmount + " " + currencySymbol(for: viewModel.accountCurrency)).foregroundColor(.gray)
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
        Category(id: 1, name: "Продукты", emoji: "🍏", isIncome: true),
        Category(id: 2, name: "Зарплата", emoji: "💸", isIncome: false)
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
            transactions: testTransactions,
            transactionsService: TransactionsService(
                networkClient: NetworkClient(token: "test"),
                appNetworkStatus: AppNetworkStatus(),
                bankAccountsService: BankAccountsService(networkClient: NetworkClient(token: "test"), appNetworkStatus: AppNetworkStatus()),
                categoriesService: CategoriesService(networkClient: NetworkClient(token: "test"), appNetworkStatus: AppNetworkStatus())
            ),
            bankAccountService: BankAccountsService(networkClient: NetworkClient(token: "test"), appNetworkStatus: AppNetworkStatus())
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
            transactionToEdit: testTransactions[0],
            transactionsService: TransactionsService(
                networkClient: NetworkClient(token: "test"),
                appNetworkStatus: AppNetworkStatus(),
                bankAccountsService: BankAccountsService(networkClient: NetworkClient(token: "test"), appNetworkStatus: AppNetworkStatus()),
                categoriesService: CategoriesService(networkClient: NetworkClient(token: "test"), appNetworkStatus: AppNetworkStatus())
            ),
            bankAccountService: BankAccountsService(networkClient: NetworkClient(token: "test"), appNetworkStatus: AppNetworkStatus())
        ),
        onSave: {}
    )
}
