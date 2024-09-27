//
//  MemoryResponse.swift
//  Boleto
//
//  Created by Sunho on 9/24/24.
//

import Foundation
import SwiftUI
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
extension MemoryResponse {
    func parseToPhotoItems() -> [PhotoItem] {
        return self.pictureList.map { pictureDTO in
//            let imageURL = URL(string: pictureDTO.pictureUrl)
//            let kfImage = KFImage(imageURL)
            return PhotoItem(id: pictureDTO.pictureId, image: nil, pictureIdx: pictureDTO.pictureIdx, imageURL: pictureDTO.pictureUrl)
        }
    }
    func parseToStickers() -> [Sticker] {
        let regularStickers = self.stickerList.map { stickerDTO in
            Sticker(id: UUID(), image: StickerImage(rawValue: stickerDTO.field) ?? .bcc , position: CGPoint(x: stickerDTO.locX, y: stickerDTO.locY), scale: CGFloat(stickerDTO.scale) / 100, rotation: Angle(degrees: Double(stickerDTO.rotation)), type: .regular)
        }
        let bubbleStickers = self.speechList.map { speechDTO in
            Sticker(id: UUID(), image: .bubble, position: CGPoint(x: speechDTO.locX, y: speechDTO.locY), scale: CGFloat(speechDTO.scale) / 100, rotation: Angle(degrees: Double(speechDTO.rotation)), type: .bubble, text: speechDTO.text)}
        return regularStickers + bubbleStickers
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
