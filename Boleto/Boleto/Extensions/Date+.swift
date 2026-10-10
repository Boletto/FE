//
//  Date+.swift
//  Boleto
//
//  Created by Sunho on 9/2/24.
//

import SwiftUI
extension Date {
    public var ticketformat: String {
        return toString("yyyy-MM-dd")
    }
    public func toString(_ dateFormat: String) -> String {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = dateFormat
        return dateformatter.string(from: self)
    }
    public static func isTraveling( startDate: Date,  endDate: Date) -> Bool {
        let now = Date()
        let calendar = Calendar.current
        let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endDate) ?? endDate
        return now >= startDate && now <= endOfDay
    }
}
