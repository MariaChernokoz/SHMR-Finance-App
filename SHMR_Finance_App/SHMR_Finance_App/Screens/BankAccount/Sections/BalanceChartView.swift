//
//  BalanceChartView.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 22.07.2025.
//

import SwiftUI
import Charts

struct BalanceChartView: View {
    let history: [BalanceHistoryPoint]

    var body: some View {
        Chart(history) { point in
            BarMark(
                x: .value("Дата", point.date),
                y: .value("Баланс", abs(point.balance))
            )
            .foregroundStyle(point.balance >= 0 ? Color.accent : Color.negativeBalance)
        }
        .chartYAxis(.hidden)
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: 5))
        }
        .frame(height: 200)
    }
}
