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
                            SearchBar(text: $viewModel.searchText)
                                .listRowInsets(EdgeInsets())
                                .listRowBackground(Color.clear)
                        }
                        //отображение статей
                        Section(header: Text("Статьи")) {
                            ForEach(viewModel.filteredCategories) { category in
                                CategoriesRow(category: category)
                            }
                        }
                    }
                    .listSectionSpacing(0)
                    .scrollDismissesKeyboard(.immediately)
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

struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color(.systemGray))
            ZStack(alignment: .leading) {
                    if text.isEmpty {
                        Text("Search")
                            .foregroundColor(Color(.systemGray))
                    }
                    TextField("", text: $text)
                        .foregroundColor(.primary)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
            //микрофончик?
        }
        .padding(8)
        .background(Color(.systemGray5))
        .cornerRadius(10)
    }
}

#Preview {
    CategoriesView(viewModel: CategoriesViewModel())
}
