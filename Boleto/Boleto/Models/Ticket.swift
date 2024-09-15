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
    
}
