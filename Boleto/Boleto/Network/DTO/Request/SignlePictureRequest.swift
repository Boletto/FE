//
//  SignlePictureRequest.swift
//  Boleto
//
//  Created by Sunho on 9/26/24.
//

import Foundation
struct SignlePictureRequest: Encodable {
    let picutreId: Int
    
    enum CodingKeys: String, CodingKey {
        case picutreId = "picture_id"
    }
}
