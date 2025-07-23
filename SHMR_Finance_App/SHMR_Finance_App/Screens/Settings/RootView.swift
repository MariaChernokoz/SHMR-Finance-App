import SwiftUI

struct RootView: View {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    let bankAccountService: BankAccountsService
    let categoriesService: CategoriesService
    let transactionsService: TransactionsService
    @ObservedObject var networkStatus: AppNetworkStatus

    var body: some View {
        TabBarView(
            bankAccountService: bankAccountService,
            categoriesService: categoriesService,
            transactionsService: transactionsService,
            networkStatus: networkStatus
        )
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
} 
