//
//  TabBarView.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 16.06.2025.
//

import SwiftUI

struct TabBarView: View {
    init() {
        UITabBar.appearance().backgroundColor = UIColor.white
        UITabBar.appearance().unselectedItemTintColor = UIColor.gray
    }
    
    var body: some View {
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
                
                CategoriesView()
                .tabItem {
                    Label("Статьи", image: "categoriesTabBarButton")
                }
                
                SettingsView()
                .tabItem {
                    Label("Настройки", image: "settingsTabBarButton")
                }
            }
            .toolbarBackground(.visible, for: .tabBar)
            .toolbarBackground(Color.white, for: .tabBar)
        }
        .tint(Color.accentColor)
        .padding(.bottom, 8)
    }
}

#Preview {
    TabBarView()
}

