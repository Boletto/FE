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
extension MyFrameResponse {
    func parestoFrameItem() -> [FrameItem]{
        return self.frames.map { frameinfo in
            return FrameItem(imageUrl: frameinfo.frameUrl, idx: frameinfo.id)
        }
    }
}
