//
//  PostFourCutResponse.swift
//  Boleto
//
//  Created by Sunho on 10/1/24.
//

import Foundation
struct PostFourCutResponse: Decodable {
    var pictureId: String
    var pictureUrl: [String]
    var pictureIdx: Int
    var fourCutID: Int
    var collecId: Int
    var frameType: String

    enum CodingKeys: String, CodingKey {
        case pictureId = "picture_id"
        case pictureUrl = "picture_url"
        case pictureIdx = "picture_idx"
        case fourCutID = "fourCut_id"
        case collecId = "collec_id"
        case frameType = "frame_type"
    }
}
