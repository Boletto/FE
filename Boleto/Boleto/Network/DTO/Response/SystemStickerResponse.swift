//
//  SystemStickerResponse.swift
//  Boleto
//
//  Created by Sunho on 11/26/24.
//

import Foundation


struct SystemStickerResponse: Codable {
    let createdDate: String
    let modifiedDate: String
    let stickerID: Int
    let stickerCode: String
    let stickerName: String
    let stickerType: String
    let defaultProvided: Bool
    let stickerURL: String
    let description: String

    enum CodingKeys: String, CodingKey {
        case createdDate = "created_date"
        case modifiedDate = "modified_date"
        case stickerID = "sticker_id"
        case stickerCode = "sticker_code"
        case stickerName = "sticker_name"
        case stickerType = "sticker_type"
        case defaultProvided = "default_provided"
        case stickerURL = "sticker_url"
        case description
    }
}
