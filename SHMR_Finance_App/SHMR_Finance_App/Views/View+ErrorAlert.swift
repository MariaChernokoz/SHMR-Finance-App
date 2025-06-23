//
//  View+ErrorAlert.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 23.06.2025.
//

import SwiftUI

extension View {
    func errorAlert(errorMessage: Binding<String?>) -> some View {
        alert(isPresented: Binding(
            get: { errorMessage.wrappedValue != nil },
            set: { if !$0 { errorMessage.wrappedValue = nil } }
        )) {
            Alert(
                title: Text("Ошибка"),
                message: Text(errorMessage.wrappedValue ?? ""),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}
