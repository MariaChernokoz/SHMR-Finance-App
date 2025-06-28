//
//  TabBarView.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 16.06.2025.
//

import SwiftUI

struct TabBarView: View {
    
    
    var body: some View {
        TabView {
            TransactionsListView(direction: .outcome)
            .tabItem {
                Label("Расходы", image: "outcomeTabBarButton")
            }
            .toolbarBackground(.visible, for: .tabBar)
            .toolbarBackground(.background, for: .tabBar)
            
            TransactionsListView(direction: .income)
            .tabItem {
                Label("Доходы", image: "incomeTabBarButton")
            }
            .toolbarBackground(.visible, for: .tabBar)
            .toolbarBackground(.background, for: .tabBar)
            
            AccountView()
            .tabItem {
                Label("Счет", image: "accountTabBarButton")
            }
            .tint(Color.navigation)
            .toolbarBackground(.visible, for: .tabBar)
            .toolbarBackground(.background, for: .tabBar)
            
            CategoriesView(viewModel: CategoriesViewModel())
            .tabItem {
                Label("Статьи", image: "categoriesTabBarButton")
            }
            .toolbarBackground(.visible, for: .tabBar)
            .toolbarBackground(.background, for: .tabBar)
            
            SettingsView()
            .tabItem {
                Label("Настройки", image: "settingsTabBarButton")
            }
            .toolbarBackground(.visible, for: .tabBar)
            .toolbarBackground(.background, for: .tabBar)
        }
        .tint(Color.accentColor)
    }
}

#Preview {
    TabBarView()
}

