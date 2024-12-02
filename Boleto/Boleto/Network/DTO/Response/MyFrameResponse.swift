//
//  MyFrameResponse.swift
//  Boleto
//
//  Created by Sunho on 10/1/24.
//

import Foundation
struct MyFrameResponse : Decodable {
    let createdDate: String
        let modifiedDate: String
        let frameId: Int
        let frameName: String
        let description: String
        let frameCode: String
        let frameUrl: String
        let owned: Bool

        enum CodingKeys: String, CodingKey {
            case createdDate = "created_date"
            case modifiedDate = "modified_date"
            case frameId = "frame_id"
            case frameName = "frame_name"
            case description
            case frameCode = "frame_code"
            case frameUrl = "frame_url"
            case owned
        }
}
