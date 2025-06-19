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
            .tint(Color.purple)
            .tabItem {
                Image(systemName: "chart.bar.xaxis")
                Text("Расходы")
            }
            .padding(.bottom, 8)
            
            NavigationStack {
                TransactionsListView(direction: .income)
            }
            .tint(Color.purple)
            .tabItem {
                Image(systemName: "chart.bar.xaxis.ascending")
                Text("Доходы")
            }
            .padding(.bottom, 8)
                
            NavigationStack {
                AccountView()
            }
            .tint(Color.purple)
            .tabItem {
                Image(systemName: "person.crop.circle")
                Text("Счет")
            }
            .padding(.bottom, 8)
            
            NavigationStack {
                CategoriesView()
            }
            .tint(Color.purple)
            .tabItem {
                Image(systemName: "chart.bar.horizontal.page")
                Text("Статьи")
            }
            .padding(.bottom, 8)
            
            NavigationStack {
                SettingsView()
            }
            .tint(Color.purple)
            .tabItem {
                Image(systemName: "gearshape.fill")
                Text("Настройки")
            }
            .padding(.bottom, 8)
        }
        .tint(Color.accentColor)
        .padding(.bottom, 12)
    }
}

#Preview {
    TabBarView()
}

