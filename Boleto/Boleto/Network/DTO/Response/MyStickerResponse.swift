//
//  MyStickerResponse.swift
//  Boleto
//
//  Created by Sunho on 10/1/24.
//

import Foundation
struct MyStickerResponse: Decodable {
    let stickerCount: Int
    let stickers: [MyStickerInfo]
}
struct MyStickerInfo: Decodable {
    let id: Int
    let stickerType: String
}
