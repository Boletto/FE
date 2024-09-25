//
//  Ticket.swift
//  Boleto
//
//  Created by Sunho on 9/5/24.
//

import SwiftUI

struct Ticket: Identifiable, Equatable {
//    let id = UUID()
    var id: Int {travelID}
    let travelID: Int
    let departaure: Spot
    let arrival: Spot
    let startDate: Date
    let endDate: Date
    let participant: [Person]
    let keywords: [Keywords] 
    let color: TicketColor
//    static var dummyTicket = Ticket(departaure: "Seoul", arrival: "Busan", startDate: "2024.1.28", endDate: "2024.04.12", participant: [Person(image: "beef3", name: "강병호"),Person(image: "beef1", name: "김수민"),Person(image: "beef2", name: "하잇"),Person(image: "beef4", name: "면답"), Person(image: "beef2", name: "호잇")], keywords: [.activity,.adventure], color: "red")
    static var dummyTicket = Ticket(travelID: 13, departaure: .busan, arrival: .seoul, startDate: Date(), endDate: Date(), participant: [Person(id: "12", image: "beef3", name: "선호"),Person(id: "122", image: "beef3", name: "선호"),Person(id: "112", image: "beef3", name: "선호"),Person(id: "1", image: "beef3", name: "선호"),Person(id: "13", image: "beef3", name: "선호")], keywords: [.hike,.alone,.fandom], color: .green)


}
extension Ticket {
    var status: TravelStatus {
        let now = Date()
        if now < startDate {
            return .future
        } else if now > endDate {
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
