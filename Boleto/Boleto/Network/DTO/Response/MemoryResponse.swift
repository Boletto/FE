//
//  MemoryResponse.swift
//  Boleto
//
//  Created by Sunho on 9/24/24.
//

import Foundation
import SwiftUI
struct MemoryResponse: Decodable {
    let memories: [MemoryDTO]
    let stickers: [StickerDTO]
    let status: String
}
struct MemoryDTO: Decodable {
    let memoryType: String
    let frameUrl: String
    let pictures: [String]
    let memoryIdx: Int

    enum CodingKeys: String, CodingKey {
        case memoryType = "memory_type"
        case pictures
        case memoryIdx = "memory_idx"
        case frameUrl = "frame_url"
    }
}
struct StickerDTO: Decodable {
    let stickerCode: String
        let stickerType: String
        let stickerURL: String
    let locX: String
        let locY: String
        let rotation: Int
        let scale: Double
        let content: String

        enum CodingKeys: String, CodingKey {
            case stickerCode = "sticker_code"
            case stickerType = "sticker_type"
            case stickerURL = "sticker_url"
            case locX = "loc_x"
            case locY = "loc_y"
            case rotation
            case scale
            case content
        }
}
