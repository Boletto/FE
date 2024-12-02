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
    var frameId: Int
    var frameCode: String
    var name: String
    init(frameURL: String, frameid: Int, frameCode: String,name: String) {
        self.frameURL = frameURL
        self.frameId = frameid
        self.frameCode = frameCode
        self.name = name
    }
}
