//
//  HistoryView.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 18.06.2025.
//

import SwiftUI

struct HistoryView: View {
    var body: some View {
        NavigationStack {
            
            VStack (alignment: .leading, spacing: 15 ){
                NavigationLink(destination: AnalysisView()) {
                    Image(systemName: "document")
                        .foregroundColor(.purple)
                        .font(.system(size: 22))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.horizontal, 20)
                }
                
                Text("Моя история")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.horizontal, 20)
                
                //всего
                List {
                    HStack {
                        Text("Начало")
                        Spacer()
                        Text("00:00")
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.15))
                            .cornerRadius(8)
                    }
                    HStack {
                        Text("Конец")
                        Spacer()
                        Text("23:59")
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.15))
                            .cornerRadius(8)
                    }
                    HStack {
                        Text("Сумма")
                        Spacer()
                        Text("100 ₽")
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }
}

#Preview {
    HistoryView()
}
