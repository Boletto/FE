//
//  MyFrameResponse.swift
//  Boleto
//
//  Created by Sunho on 10/1/24.
//

import Foundation
struct MyFrameResponse : Decodable {
    let frameCount: Int
    let frames: [FrameInfo]
}
struct FrameInfo: Decodable {
    let frameUrl: String
    let id: Int
}
