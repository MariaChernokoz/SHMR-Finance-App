//
//  Calendar.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 12.07.2025.
//

import Foundation

extension Calendar {
    func endOfDay(for date: Date) -> Date? {
        let startOfDay = self.startOfDay(for: date)
        return self.date(byAdding: DateComponents(day: 1, second: -1), to: startOfDay)
    }
}

extension Date {
    // Конвертирует локальное время в UTC
    func convertToUTC() -> Date {
        let timeZone = TimeZone.current
        let secondsFromGMT = timeZone.secondsFromGMT(for: self)
        return self.addingTimeInterval(TimeInterval(secondsFromGMT))
    }
    
    // Конвертирует UTC в локальное время
    func convertFromUTCToLocal() -> Date {
        let timeZone = TimeZone.current
        let secondsFromGMT = timeZone.secondsFromGMT(for: self)
        return self.addingTimeInterval(TimeInterval(-secondsFromGMT))
    }
}
