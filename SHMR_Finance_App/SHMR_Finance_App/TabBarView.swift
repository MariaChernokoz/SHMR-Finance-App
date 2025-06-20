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
            .tint(Color.accentColor)
            .tabItem {
                Label("Расходы", image: "outcomeTabBarButton")
            }
            
            NavigationStack {
                TransactionsListView(direction: .income)
            }
            .tint(Color.accentColor)
            .tabItem {
                Label("Доходы", image: "incomeTabBarButton")
            }
                
            NavigationStack {
                AccountView()
            }
            .tint(Color.purple)
            .tabItem {
                Label("Счет", image: "accountTabBarButton")
            }
            
            NavigationStack {
                CategoriesView()
            }
            .tint(Color.purple)
            .tabItem {
                Label("Статьи", image: "categoriesTabBarButton")
            }
            
            NavigationStack {
                SettingsView()
            }
            .tint(Color.purple)
            .tabItem {
                Label("Настройки", image: "settingsTabBarButton")
            }
        }
        .tint(Color.accentColor)
        .padding(.bottom, 8)
    }
}

#Preview {
    TabBarView()
}

