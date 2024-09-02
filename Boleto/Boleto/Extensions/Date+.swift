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
}
