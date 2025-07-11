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
            Group {
                TransactionsListView(direction: .outcome)
                    .tabItem {
                        Label("Расходы", image: "outcomeTabBarButton")
                    }
                    //.tint(Color.navigation)
                
                TransactionsListView(direction: .income)
                    .tabItem {
                        Label("Доходы", image: "incomeTabBarButton")
                    }
                    //.tint(Color.navigation)
                
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
    }
}

#Preview {
    TabBarView()
}

