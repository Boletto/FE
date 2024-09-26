//
//  File.swift
//  Boleto
//
//  Created by Sunho on 9/26/24.
//

import Foundation
struct ImageUploadRequest: Encodable {
    let userid: Int
    let travelId: Int
    let pictureIdx: Int
    enum CodingKeys: String, CodingKey {
        case userid = "user_id"
        case travelId = "travel_id"
        case pictureIdx = "picture_idx"
     }
}
