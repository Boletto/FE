//
//  SingleTravelRequest.swift
//  Boleto
//
//  Created by Sunho on 9/24/24.
//

import Foundation
struct SingleTravelRequest: Encodable {
    let travelID: Int
    enum CodingKeys: String, CodingKey {
        case travelID = "travel_id"
    }
}
