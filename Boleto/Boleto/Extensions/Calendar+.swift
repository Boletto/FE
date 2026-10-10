//
//  Calendar+.swift
//  Boleto
//
//  Created by Sunho on 1/15/25.
//

import Foundation
extension Calendar {
    func numberOfDays(in date: Date) -> Int {
        range(of: .day, in: .month, for: date)?.count ?? 0
    }
    func firstWeekdayOfMonth(in date: Date) -> Int {
        let firstDay = self.date(from: dateComponents([.year, .month], from: date))!
       return component(.weekday, from: firstDay)
    }
    func date(from baseDate: Date, adding days: Int) -> Date {
//        self.timeZone = TimeZone.current
        date(byAdding: .day, value: days, to: baseDate)!
    }
}
