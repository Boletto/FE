//
//  TravelFetchRequest.swift
//  Boleto
//
//  Created by Sunho on 10/4/24.
//

import Foundation
struct TravelFetchRequest: Encodable {
    let departure: String
    let arrive: String
    let keyword: String
    let startDate: String
    let endDate: String
    let members: [Int]
    let color: String
    var travelId: Int
    enum CodingKeys: String, CodingKey {
        case startDate = "start_date"
        case endDate = "end_date"
        case departure
        case arrive
        case color
        case members
        case keyword
        case travelId = "travel_id"
    }
}
