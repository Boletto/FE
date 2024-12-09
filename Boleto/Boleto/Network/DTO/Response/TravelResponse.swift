//
//  TravelResponse.swift
//  Boleto
//
//  Created by Sunho on 9/23/24.
//

import Foundation
struct TravelResponse: Decodable {
    let travelID: Int
    let ticketInfo: TicketInfoDTO
    let departure: String
    let arrive: String
    let keyword: String
    let startDate: String
    let endDate: String
    let members: [Member]
    let status: String?
    let editable: Int?
    let createdDate: String
    enum CodingKeys: String, CodingKey {
        case travelID = "travel_id"
        case ticketInfo = "ticket_info"
        case startDate = "start_date"
        case endDate = "end_date"
        case departure, arrive, keyword,members, status
        case editable = "editable_user_id"
        case createdDate = "created_date"
    }
    func toTicket() -> Ticket {
        let participants = members.map {$0.toModel()}
        let keywordStrings = keyword.split(separator: ",")
        let mappedKeywords = keywordStrings.map{$0.trimmingCharacters(in: .whitespaces)}.compactMap { Keywords.fromKoreanString($0) }
        return .init( travelID: travelID, departaure: SpotType.fromUpperString(departure) ?? .seoul,
                      arrival: SpotType.fromUpperString(arrive) ?? .seoul, startDate: startDate.toDate() ?? Date(), endDate: endDate.toDate() ?? Date(), participant: participants, keywords: mappedKeywords, editableID: editable,fullSizeURL: URL(string: ticketInfo.ticketFull)!, smallSizeURL: URL(string: ticketInfo.ticketSmall)!)
    }
}
struct TicketInfoDTO: Decodable {
    let ticketFull: String
    let ticketSmall: String
    enum CodingKeys: String, CodingKey {
        case ticketFull = "ticket_full"
        case ticketSmall = "ticket_small"
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
    func toModel() -> MemberModel {
        return .init(id: userId, name: name, nickname: nickname, imageUrl: userProfile)
    }
    
}
