//
//  TimePickerRow.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 11.07.2025.
//

import Foundation
import SwiftUI

struct TimePickerRow: View {
    let title: String
    @Binding var date: Date

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            HStack {
                Text(date.formatted(.dateTime.hour().minute()))
            }
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .foregroundColor(Color("AccentColor"))
                    .opacity(0.2)
                    .padding(.vertical, -7)
            )
            .overlay {
                DatePicker(
                    selection: $date,
                    displayedComponents: .hourAndMinute) {}
                .labelsHidden()
                .colorMultiply(.clear)
            }
        }
    }
}
