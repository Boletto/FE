//
//  SignlePictureRequest.swift
//  Boleto
//
//  Created by Sunho on 9/26/24.
//

import Foundation
struct SignlePictureRequest: Encodable {
    let picutreIdx: Int
    let travelId: Int
    let isFourCut: Bool
    enum CodingKeys: String, CodingKey {
        case picutreIdx = "picture_idx"
        case travelId = "travel_id"
        case isFourCut = "is_fourCut"
    }
}
