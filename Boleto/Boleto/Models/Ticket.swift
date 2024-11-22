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
    let participant: [MemberModel]
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
    static let mockTickets: [Ticket] = [
        Ticket(
            travelID: 1,
            departaure: .dummy, // Replace with appropriate SpotType
            arrival: .seoul,    // Replace with appropriate SpotType
            startDate: Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
            endDate: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
            participant: [],     // Replace with appropriate [FriendDummy] if needed
            keywords: [.activity, .alone],
            color: .blue
        ),
        Ticket(
            travelID: 2,
            departaure: .dummy, // Replace with appropriate SpotType
            arrival: .seoul,    // Replace with appropriate SpotType
            startDate: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
            endDate: Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
            participant: [],     // Replace with appropriate [FriendDummy] if needed
            keywords: [.fit, .alone],
            color: .purple
        ),
        Ticket(
            travelID: 3,
            departaure: .dummy, // Replace with appropriate SpotType
            arrival: .seoul,    // Replace with appropriate SpotType
            startDate: Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
            endDate: Calendar.current.date(byAdding: .day, value: 2, to: Date())!,
            participant: [],     // Replace with appropriate [FriendDummy] if needed
            keywords: [.city, .fandom],
            color: .yellow
        )
    ]
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
