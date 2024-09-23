//
//  TravelResponse.swift
//  Boleto
//
//  Created by Sunho on 9/23/24.
//

import Foundation
struct TravelResponse: Decodable {
    let travelID: Int
    let departure: String
    let arrive: String
    let keyword: String
    let startDate: String
    let endDate: String
    let members: [Member]
    let color: String
    let status: String?
    enum CodingKeys: String, CodingKey {
        case travelID = "travel_id"
        case startDate = "start_date"
        case endDate = "end_date"
        case departure, arrive, keyword,members, color, status
        
    }
    func toTicket() -> Ticket {
        let participants = members.map {$0.toPreson()}
        let keywordStrings = keyword.split(separator: ",")
        let mappedKeywords = keywordStrings.compactMap { Keywords(rawValue: $0.capitalized) }
          
        return .init(departaure: departure, arrival: arrive, startDate: startDate, endDate: endDate, participant: participants, keywords: mappedKeywords, color: TicketColor(rawValue: color) ?? .blue)
    }
}
struct Member: Decodable {
    let id: Int
    let email: String?
    let serialId: String
    let password: String
    let provider: String
    let role: String
    let createdAt: [Int]
    let name: String
    let nickname: String
    let refreshToken: String
    let userProfile: String
    let login: Bool
    let frame: Bool
    let location: Bool
    let friendApply: Bool
    func toPreson() -> Person {
        return .init(id: String(id), image: userProfile, name: name)
    }
}
