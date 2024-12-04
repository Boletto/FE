//
//  FrameResponse.swift
//  Boleto
//
//  Created by Sunho on 12/5/24.
//

import Foundation
struct FrameResponse: Decodable {
    let createdDate: String
    let modifiedDate: String
    let frameId: Int
    let frameType: String
    let frameCode: String
    let frameUrl: String
    let owned: Bool
    
    enum CodingKeys: String, CodingKey {
        case createdDate = "created_date"
        case modifiedDate = "modified_date"
        case frameId = "frame_id"
        case frameCode = "frame_code"
        case frameUrl = "frame_url"
        case owned
        case frameType = "frame_type"
    }
}
