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
struct EventFrameResponse: Decodable {
    let createdDate: String
    let modifiedDate: String
    let frameId: Int
    let frameName: String
    let frameCode: String
    let frameUrl: String
    let defaultProvided: Bool
    let description: String
    
    enum CodingKeys: String, CodingKey {
        case createdDate = "created_date"
        case modifiedDate = "modified_date"
        case frameId = "frame_id"
        case frameCode = "frame_code"
        case frameUrl = "frame_url"
        case defaultProvided = "default_provided"
        case frameName = "frame_name"
        case description
    }
}
