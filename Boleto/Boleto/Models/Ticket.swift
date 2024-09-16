//
//  Ticket.swift
//  Boleto
//
//  Created by Sunho on 9/5/24.
//

import Foundation

struct Ticket: Identifiable, Equatable {
    let id = UUID()
    
    let departaure: String
    let arrival: String
    let startDate: String
    let endDate: String
    let participant: [Person]
    let keywords: [Keywords] 
    static var dummyTicket = Ticket(departaure: "Seoul", arrival: "Busan", startDate: "2024.1.28", endDate: "2024.04.12", participant: [Person(image: "beef3", name: "강병호"),Person(image: "beef1", name: "김수민"),Person(image: "beef2", name: "하잇"),Person(image: "beef4", name: "면답"), Person(image: "beef2", name: "호잇")], keywords: [.activity,.adventure])
}
