//
//  StickerRequest.swift
//  Boleto
//
//  Created by Sunho on 10/1/24.
//

import Foundation
struct UploadStickerRequest : Encodable {
    let stickerType: String

       
       init(stickerType: StickerImage) {
           self.stickerType = stickerType.rawValue
       }
}
