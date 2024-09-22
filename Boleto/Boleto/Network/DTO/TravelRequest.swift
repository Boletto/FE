//
//  TravelDTO.swift
//  Boleto
//
//  Created by Sunho on 9/22/24.
//

import Foundation
typealias Parameters = [String: Any]
struct TravelRequest: Encodable {
    let departure: String
    let arrive: String
    let keyword: [String]
    let startDate: String
    let endDate: String
    let members: [Int]
    let color: String
    enum CodingKeys: String, CodingKey {
        case startDate = "start_date"
        case endDate = "end_date"
        case departure
        case arrive
        case color
        case members
        case keyword
    }
}
