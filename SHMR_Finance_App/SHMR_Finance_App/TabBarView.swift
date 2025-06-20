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
            NavigationStack {
                TransactionsListView(direction: .outcome)
            }
            .tabItem {
                Label("Расходы", image: "outcomeTabBarButton")
            }
            .toolbarBackground(.visible, for: .tabBar)
            .toolbarBackground(Color.white, for: .tabBar)
            
            NavigationStack {
                TransactionsListView(direction: .income)
            }
            .tabItem {
                Label("Доходы", image: "incomeTabBarButton")
            }
            .toolbarBackground(.visible, for: .tabBar)
            .toolbarBackground(Color.white, for: .tabBar)
                
            NavigationStack {
                AccountView()
            }
            .tabItem {
                Label("Счет", image: "accountTabBarButton")
            }
            .toolbarBackground(.visible, for: .tabBar)
            .toolbarBackground(Color.white, for: .tabBar)
            
            NavigationStack {
                CategoriesView()
            }
            .tabItem {
                Label("Статьи", image: "categoriesTabBarButton")
            }
            .toolbarBackground(.visible, for: .tabBar)
            .toolbarBackground(Color.white, for: .tabBar)
            
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Настройки", image: "settingsTabBarButton")
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

