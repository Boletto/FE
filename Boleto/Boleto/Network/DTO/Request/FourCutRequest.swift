//
//  FourCutRequest.swift
//  Boleto
//
//  Created by Sunho on 10/1/24.
//

import Foundation
struct FourCutRequest: Encodable {
    let travelId: Int
    let pictureIdx: Int
    let isFourcut: Bool
    let collectId: Int
    enum CodingKeys: String, CodingKey {
        case travelId = "travel_id"
        case pictureIdx = "picture_idx"
        case isFourcut = "is_fourCut"
        case collectId = "collect_id"
     }
}
