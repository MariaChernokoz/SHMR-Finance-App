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
                    Image(systemName: "chart.bar.xaxis")
                    Text("Расходы")
                }
            
            TransactionsListView(direction: .income)
                .tabItem {
                    Image(systemName: "chart.bar.xaxis.ascending")
                    Text("Доходы")
                }
            
            AccountView()
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("Счет")
                }

            CategoriesView()
                .tabItem {
                    Image(systemName: "chart.bar.horizontal.page")
                    Text("Статьи")
                }

            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Настройки")
                }
        }
        .tint(Color.accentColor)
        
        // * добавить белый фон у таб бара * 
    }
}

#Preview {
    TabBarView()
}

