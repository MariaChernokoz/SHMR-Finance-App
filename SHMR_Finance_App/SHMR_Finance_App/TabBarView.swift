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
                
                TransactionsListView(direction: .income)
                .tabItem {
                    Label("Доходы", image: "incomeTabBarButton")
                }
                
                AccountView()
                .tabItem {
                    Label("Счет", image: "accountTabBarButton")
                }
                //.ignoresSafeArea(.keyboard, edges: .bottom)
                //.tint(Color.navigation)
                
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
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .tint(Color.accentColor)
        .padding(.bottom, 8)
    }
}

#Preview {
    TabBarView()
}

