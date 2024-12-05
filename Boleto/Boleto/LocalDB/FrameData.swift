//
//  FrameData.swift
//  Boleto
//
//  Created by Sunho on 10/3/24.
//

import SwiftData

@Model
class FrameData {
    var frameURL: String

    var frameCode: String
    var frameType: String
    init(frameURL: String, frameCode: String,frameType: String) {
        self.frameURL = frameURL
   
        self.frameCode = frameCode
        self.frameType = frameType
    }
}
