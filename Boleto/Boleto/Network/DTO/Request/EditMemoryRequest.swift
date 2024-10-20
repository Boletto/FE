//
//  EditMemoryRequest.swift
//  Boleto
//
//  Created by Sunho on 9/26/24.
//

import Foundation
struct EditMemoryRequest: Encodable{
    let travelId: Int
    let status: String
    let stickerList: [StickerRequest]
    let speechList: [SpeechRequest]
    enum CodingKeys: String, CodingKey {
        case travelId = "travel_id"
        case status
        case stickerList = "sticker_list"
        case speechList = "speech_list"
    }
}
struct StickerRequest: Encodable {
    let field: String
    let locX: Double
    let locY: Double
    let rotation: Int
    let scale: Int
    enum CodingKeys: String, CodingKey {
        case field
        case locX = "loc_x"
        case locY = "loc_y"
        case rotation
        case scale
    }
}
struct SpeechRequest: Encodable {
    let text: String
    let locX: Double
    let locY: Double
    let rotation: Int
    let scale: Int
    enum CodingKeys: String, CodingKey {
        case text
        case locX = "loc_x"
        case locY = "loc_y"
        case rotation
        case scale
    }
}
