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
        let mappedKeywords = keywordStrings.map{$0.trimmingCharacters(in: .whitespaces)}.compactMap { Keywords.fromKoreanString($0) }
    
        return .init( travelID: travelID, departaure: Spot(rawValue: departure) ?? .seoul, arrival: Spot(rawValue: arrive)!, startDate: startDate.toDate()!, endDate: endDate.toDate()!, participant: participants, keywords: mappedKeywords, color: TicketColor(rawValue: color) ?? .blue)
    }
}
struct Member: Decodable {
    let nickname: String
    let name: String
    let userProfile: String?
    let userId: Int
    enum CodingKeys: String, CodingKey {
        case nickname
        case name
        case userProfile = "user_profile"
        case userId = "user_id"
    }
    func toPreson() -> FriendDummy {
        return .init(id: userId, name: name, nickname: nickname, imageUrl: userProfile ?? "default")
    }
    
}
