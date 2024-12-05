//
//  StickerResponse.swift
//  Boleto
//
//  Created by Sunho on 11/26/24.
//

import Foundation


struct UserStickerResponse: Decodable {
    let createdDate: String? // 날짜가 null일 수 있으니 Optional
    let modifiedDate: String?
    let stickerID: Int
    let stickerCode: String
    let stickerName: String
    let stickerType: String
    let stickerURL: String
    let description: String
    let owned: Bool

    enum CodingKeys: String, CodingKey {
        case createdDate = "created_date"
        case modifiedDate = "modified_date"
        case stickerID = "sticker_id"
        case stickerCode = "sticker_code"
        case stickerName = "sticker_name"
        case stickerType = "sticker_type"
        case stickerURL = "sticker_url"
        case description
        case owned
    }
}
