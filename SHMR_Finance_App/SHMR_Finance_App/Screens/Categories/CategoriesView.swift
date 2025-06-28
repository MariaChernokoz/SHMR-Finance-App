//
//  CategoriesView.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 16.06.2025.
//

import SwiftUI

struct CategoriesView: View {
    @StateObject var viewModel: CategoriesViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(alignment: .leading, spacing: 5) {
                    List {
                        Section {} header: {
                            Text("Мои статьи")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundStyle(.black)
                                .textCase(nil)
                                .listRowBackground(Color.clear)
                                .listRowInsets(EdgeInsets(top: 40, leading: 0, bottom: 10, trailing: 0))
                        }
                        //секция поиска
                        Section {
                            Text("поиск")
                        }
                        
                        Section(header: Text("Статьи")) {
                            ForEach(viewModel.categories) { category in
                                CategoriesRow(category: category)
                            }
                        }
                    }
                    .listSectionSpacing(0)
                }
            }
        }
        .task {
            await viewModel.loadData()
        }
        .errorAlert(errorMessage: $viewModel.errorMessage)
    }
}

// отображение статей
struct CategoriesRow: View {
    let category: Category?
    
    var body: some View {
        HStack {
            Circle()
                .fill(Color.accentColor.opacity(0.2))
                .frame(width: 22, height: 22)
                .overlay(Text(String(category?.emoji ?? "❓"))
                    .font(.system(size: 12))
                )
                .padding(.trailing, 8)
            
            VStack(alignment: .leading, spacing: 0) {
                Text(category?.name ?? "неизвестная категория")
            }
        }
    }
}

#Preview {
    CategoriesView(viewModel: CategoriesViewModel())
}
