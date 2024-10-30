//
//  Ticket.swift
//  Boleto
//
//  Created by Sunho on 9/5/24.
//

import SwiftUI

struct Ticket: Equatable {


    let travelID: Int
    let departaure: SpotType
    let arrival: SpotType
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
extension Ticket {
    static func makeMockTicket(id: Int, status: TravelStatus) -> Ticket {
        let now = Date()
        let calendar = Calendar.current
        let startDate: Date
        let endDate: Date
        
        switch status {
        case .future:
            startDate = calendar.date(byAdding: .day, value: 1, to: now)!
            endDate = calendar.date(byAdding: .day, value: 2, to: now)!
        case .ongoing:
            startDate = calendar.date(byAdding: .day, value: -1, to: now)!
            endDate = calendar.date(byAdding: .day, value: 1, to: now)!
        case .completed:
            startDate = calendar.date(byAdding: .day, value: -2, to: now)!
            endDate = calendar.date(byAdding: .day, value: -1, to: now)!
        }
        
        return Ticket(travelID: id, departaure: .dummy, arrival: .seoul, startDate: startDate, endDate: endDate, participant: [], keywords: [.activity, .alone], color: .purple)
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
