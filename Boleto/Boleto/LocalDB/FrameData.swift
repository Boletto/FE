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
    init(frameURL: String) {
        self.frameURL = frameURL
    }
}
