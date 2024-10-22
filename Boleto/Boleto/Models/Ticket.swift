//
//  Ticket.swift
//  Boleto
//
//  Created by Sunho on 9/5/24.
//

import SwiftUI

struct Ticket: Identifiable, Equatable {
    static func == (lhs: Ticket, rhs: Ticket) -> Bool {
        if lhs.id == rhs.id {
            return true
        } else {return false}
    }
    
//    let id = UUID()
    var id: Int {travelID}
    let travelID: Int
    let departaure: Spot
    let arrival: Spot
    let startDate: Date
    let endDate: Date
    let participant: [FriendDummy]
    let keywords: [Keywords]
    let color: TicketColor
}
extension Ticket {
    var status: TravelStatus {
        let now = Date()
        if now < startDate {
            return .future
        } else if now > endDate + 1 {
            return .completed
        } else {
            return .ongoing
        }
    }
}
enum TravelStatus {
    case future
    case ongoing
    case completed
}

enum TicketColor: String,CaseIterable {
    case blue = "#65B1F7"
    case white = "#FFFFFF"
    case yellow = "#F9EF85"
    case green = "#85E8C4"
    case orange = "#F77A59"
    case purple = "#9AABFB"
    case pink = "#F76592"
    var color: Color {
            return Color(hex: self.rawValue)
        }
}
extension TicketColor {
    static func random() -> TicketColor {
        return TicketColor.allCases.randomElement() ?? .blue
    }
}
