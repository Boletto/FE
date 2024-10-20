//
//  File.swift
//  Boleto
//
//  Created by Sunho on 9/26/24.
//

import Foundation
struct ImageUploadRequest: Encodable {
    let travelId: Int
    let pictureIdx: Int
    let isFourcut: Bool
    enum CodingKeys: String, CodingKey {
        case travelId = "travel_id"
        case pictureIdx = "picture_idx"
        case isFourcut = "is_fourCut"
     }
}
