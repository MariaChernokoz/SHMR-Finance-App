//
//  BalanceChartView.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 22.07.2025.
//

import SwiftUI
import Charts

enum PeriodType: String, CaseIterable, Identifiable {
    case day, month
    var id: String { self.rawValue }
}

struct BalanceChartView: View {
    let historyDay: [BalanceHistoryPoint]
    let historyMonth: [BalanceHistoryPoint]
    @State private var selectedPeriod: PeriodType = .day
    @State private var selectedPoint: BalanceHistoryPoint?
    
    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df
    }()
    
    var body: some View {
        VStack {
            Picker("Период", selection: $selectedPeriod) {
                Text("Дни").tag(PeriodType.day)
                Text("Месяцы").tag(PeriodType.month)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            ZStack {
                if selectedPeriod == .day {
                    Chart(historyDay) { point in
                        BarMark(
                            x: .value("Дата", point.date),
                            y: .value("Баланс", abs(NSDecimalNumber(decimal: point.balance).doubleValue))
                        )
                        .foregroundStyle((point.balance >= 0) ? Color.accent : Color.negativeBalance)
                    }
                    .transition(.opacity.combined(with: .scale))
                    .id("day")
                } else {
                    Chart(historyMonth) { point in
                        BarMark(
                            x: .value("Дата", point.date),
                            y: .value("Баланс", abs(NSDecimalNumber(decimal: point.balance).doubleValue))
                        )
                        .foregroundStyle((point.balance >= 0) ? Color.accent : Color.negativeBalance)
                    }
                    .transition(.opacity.combined(with: .scale))
                    .id("month")
                }
            }
            .animation(.easeInOut, value: selectedPeriod)
            .chartXAxis {
                AxisMarks(values: .stride(by: selectedPeriod == .day ? .day : .month, count: selectedPeriod == .day ? 5 : 8)) { value in
                    AxisValueLabel(format: selectedPeriod == .day ? .dateTime.day().month(.abbreviated) : .dateTime.month().year())
                }
            }
            .chartYAxis(.hidden)
            .chartOverlay { proxy in
                GeometryReader { geo in
                    Rectangle().fill(Color.clear).contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    if let plotFrame = proxy.plotFrame {
                                        let x = value.location.x - geo[plotFrame].origin.x
                                        if let date: Date = proxy.value(atX: x) {
                                            let history = selectedPeriod == .day ? historyDay : historyMonth
                                            if let nearest = history.min(by: { abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date)) }) {
                                                selectedPoint = nearest
                                            }
                                        }
                                    }
                                }
                                .onEnded { _ in selectedPoint = nil }
                        )
                }
            }
            .overlay(alignment: .top) {
                if let point = selectedPoint {
                    Text("\(point.date, formatter: dateFormatter): \(NSDecimalNumber(decimal: point.balance).doubleValue, specifier: "%.2f")")
                        .padding(8)
                        .background(Color(.systemBackground).opacity(0.9))
                        .cornerRadius(8)
                        .shadow(radius: 4)
                        .transition(.opacity)
                }
            }
            .frame(height: 200)
        }
    }
}
