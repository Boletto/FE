//
//  TravelMemoryPhotoRequest.swift
//  Boleto
//
//  Created by Sunho on 12/2/24.
//

import Foundation
struct TravelMemoryPhotoRequest: Encodable {
    let memoryType: String 
    let frameCode: String
    enum CodingKeys: String, CodingKey {
        case memoryType = "memory_type"
        case frameCode = "frame_code"
    }
}
