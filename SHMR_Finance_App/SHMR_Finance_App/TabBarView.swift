//
//  TabBarView.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 16.06.2025.
//

import SwiftUI

struct TabBarView: View {
    let bankAccountService: BankAccountsService
    let categoriesService: CategoriesService
    let transactionsService: TransactionsService
    @ObservedObject var networkStatus: AppNetworkStatus
    
    var body: some View {
        ZStack(alignment: .top) {
            TabView {
                Group {
                    TransactionsListView(
                        direction: .outcome,
                        transactionsService: transactionsService,
                        categoriesService: categoriesService,
                        bankAccountService: bankAccountService
                    )
                        .tabItem {
                            Label("Расходы", image: "outcomeTabBarButton")
                        }
                    TransactionsListView(
                        direction: .income,
                        transactionsService: transactionsService,
                        categoriesService: categoriesService,
                        bankAccountService: bankAccountService
                    )
                        .tabItem {
                            Label("Доходы", image: "incomeTabBarButton")
                        }
                    AccountView(viewModel: AccountViewModel(
                        bankAccountService: bankAccountService,
                        transactionsService: transactionsService,
                        categoriesService: categoriesService
                    ))
                        .tabItem {
                            Label("Счет", image: "accountTabBarButton")
                        }
                        .tint(Color.navigation)
                    CategoriesView(viewModel: CategoriesViewModel(
                        categoriesService: categoriesService
                    ))
                        .tabItem {
                            Label("Статьи", image: "categoriesTabBarButton")
                        }
                    SettingsView()
                        .tabItem {
                            Label("Настройки", image: "settingsTabBarButton")
                        }
                }
                .toolbarBackground(.visible, for: .tabBar)
                .toolbarBackground(.background, for: .tabBar)
            }
            .tint(Color.accentColor)
            if networkStatus.isOffline {
                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        Text("Offline mode")
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .font(.system(size: 12, weight: .bold))
                            .cornerRadius(8)
                        Spacer()
                    }
                    .padding(.top, 6)
                    Spacer()
                }
                .zIndex(1)
            }
        }
    }
}

#Preview {
    TabBarView(
        bankAccountService: BankAccountsService(networkClient: NetworkClient(token: "test"), appNetworkStatus: AppNetworkStatus()),
        categoriesService: CategoriesService(networkClient: NetworkClient(token: "test"), appNetworkStatus: AppNetworkStatus()),
        transactionsService: TransactionsService(
            networkClient: NetworkClient(token: "test"),
            appNetworkStatus: AppNetworkStatus(),
            bankAccountsService: BankAccountsService(networkClient: NetworkClient(token: "test"), appNetworkStatus: AppNetworkStatus()),
            categoriesService: CategoriesService(networkClient: NetworkClient(token: "test"), appNetworkStatus: AppNetworkStatus())
        ),
        networkStatus: AppNetworkStatus()
    )
}

