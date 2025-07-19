//
//  TabBarView.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 16.06.2025.
//

import SwiftUI

struct TabBarView: View {
    @ObservedObject private var networkStatus = AppNetworkStatus.shared
    
    var body: some View {
        ZStack(alignment: .top) {
            TabView {
                Group {
                    TransactionsListView(direction: .outcome)
                        .tabItem {
                            Label("Расходы", image: "outcomeTabBarButton")
                        }
                    TransactionsListView(direction: .income)
                        .tabItem {
                            Label("Доходы", image: "incomeTabBarButton")
                        }
                    AccountView()
                        .tabItem {
                            Label("Счет", image: "accountTabBarButton")
                        }
                        .tint(Color.navigation)
                    CategoriesView(viewModel: CategoriesViewModel())
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
                    Text("Offline mode")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .bold))
                        .transition(.move(edge: .top))
                    Spacer()
                }
                .zIndex(1)
            }
        }
    }
}

#Preview {
    TabBarView()
}

