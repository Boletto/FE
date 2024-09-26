//
//  MemoryResponse.swift
//  Boleto
//
//  Created by Sunho on 9/24/24.
//

import Foundation
struct MemoryResponse: Decodable {
    let travelId: Int
    let pictureList: [PictureDTO]
    let stickerList: [StickerDTO]
    let speechList: [SpeechDTO]
    let status: String
    enum CodingKeys: String, CodingKey {
        case travelId = "travel_id"
        case pictureList = "picture_list"
        case stickerList = "sticker_list"
        case speechList = "speech_list"
        case status
    }
}
struct SpeechDTO: Decodable {
    let speechId: Int
       let text: String
       let locX: Double
       let locY: Double
       let rotation: Int
       let scale: Int

       enum CodingKeys: String, CodingKey {
           case speechId = "speech_id"
           case text
           case locX = "loc_x"
           case locY = "loc_y"
           case rotation
           case scale
       }
}
struct StickerDTO: Decodable {
    let stickerId: Int
    let field: String
    let locX: Double
    let locY: Double
    let rotation: Int
    let scale: Int

    enum CodingKeys: String, CodingKey {
        case stickerId = "sticker_id"
        case field
        case locX = "loc_x"
        case locY = "loc_y"
        case rotation
        case scale
    }
}
struct PictureDTO: Decodable {
    let pictureId: Int
    let pictureUrl: String
    let pictureIdx: Int

    enum CodingKeys: String, CodingKey {
        case pictureId = "picture_id"
        case pictureUrl = "picture_url"
        case pictureIdx = "picture_idx"
    }
}
