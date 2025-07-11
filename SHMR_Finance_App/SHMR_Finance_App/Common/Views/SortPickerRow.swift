//
//  SortPickerRow.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 11.07.2025.
//

import Foundation
import SwiftUI

enum SortType: String, CaseIterable, Identifiable, Hashable {
    case date = "По дате"
    case amount = "По сумме"
    var id: String { self.rawValue }
    var title: String { self.rawValue }
}

struct SortPickerRow: View {
    let title: String
    @Binding var sortType: SortType

    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.primary)
            Spacer()
            ZStack {
                Text(sortType.rawValue)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.black)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 7)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color.accentColor)
                            .opacity(0.2)
                    )
                Picker("", selection: $sortType) {
                    ForEach(SortType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .labelsHidden()
                .blendMode(.destinationOver) // Picker "невидимый", но кликабельный
                .contentShape(Rectangle())
            }
        }
    }
}
