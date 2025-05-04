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
    let editableID: Int?
    let fullSizeURLString: String
    let smallSizeURLString: String
    let createDate: String
}
extension Ticket {
    var status: TravelStatus {
        let now = Date()
        let calendar = Calendar.current
        let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endDate) ?? endDate
        if now < startDate {
            return .future
        } else if now > endOfDay {
            return .completed
        } else {
            return .ongoing
        }
    }
}
extension Ticket {
    // Static mock tickets for testing and preview
    static let mockTickets: [Ticket] = [
        // Current ongoing trip
        Ticket(
            travelID: 1,
            departaure: .seoul,
            arrival: .jeju,
            startDate: Date().addingTimeInterval(-86400), // Started yesterday
            endDate: Date().addingTimeInterval(172800),   // Ends in 2 days
            participant: [.mockSelf, .mockFriend],
            keywords: [ .food],
            editableID: nil,
            fullSizeURLString: "https://example.com/full/jeju.jpg",
            smallSizeURLString: "https://example.com/small/jeju.jpg",
            createDate: "2025-05-01"
        ),
        
        // Completed trip
        Ticket(
            travelID: 2,
            departaure: .seoul,
            arrival: .busan,
            startDate: Date().addingTimeInterval(-1209600), // 2 weeks ago
            endDate: Date().addingTimeInterval(-1036800),   // 12 days ago
            participant: [.mockSelf],
            keywords: [.city, .food],
            editableID: nil,
            fullSizeURLString: "https://example.com/full/busan.jpg",
            smallSizeURLString: "https://example.com/small/busan.jpg",
            createDate: "2025-04-15"
        ),
        
        // Future trip
        Ticket(
            travelID: 3,
            departaure: .busan,
            arrival: .seoul,
            startDate: Date().addingTimeInterval(604800),  // 1 week from now
            endDate: Date().addingTimeInterval(777600),    // 9 days from now
            participant: [.mockSelf, .mockFriend, .mockFamily],
            keywords: [.alone],
            editableID: 42,
            fullSizeURLString: "https://example.com/full/seoul.jpg",
            smallSizeURLString: "https://example.com/small/seoul.jpg",
            createDate: "2025-04-30"
        ),
        
        // Another future trip (for testing sorting)
        Ticket(
            travelID: 4,
            departaure: .seoul,
            arrival: .daegu,
            startDate: Date().addingTimeInterval(2592000),  // 30 days from now
            endDate: Date().addingTimeInterval(2678400),    // 31 days from now
            participant: [.mockSelf],
            keywords: [.country, .family],
            editableID: nil,
            fullSizeURLString: "https://example.com/full/daegu.jpg",
            smallSizeURLString: "https://example.com/small/daegu.jpg",
            createDate: "2025-05-02"
        )
    ]
}

enum TravelStatus {
    case future
    case ongoing
    case completed
}

