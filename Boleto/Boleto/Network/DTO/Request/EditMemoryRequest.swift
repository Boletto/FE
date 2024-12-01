//
//  EditMemoryRequest.swift
//  Boleto
//
//  Created by Sunho on 9/26/24.
//

import Foundation
struct EditMemoryRequest: Encodable{
    let stickerCode: String
    let locX: Double
    let locY: Double
    let rotation: Int
    let scale: Double
    let content: String

    enum CodingKeys: String, CodingKey {
        case stickerCode = "sticker_code"
        case locX = "loc_x"
        case locY = "loc_y"
        case rotation
        case scale
        case content
    }
}
struct EditModeRequest: Encodable {
    let status: String
}
