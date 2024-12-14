//
//  SilentPushModel.swift
//  Boleto
//
//  Created by Sunho on 11/17/24.
//

import Foundation
struct SilentPushModel {
    var eventType: SilentAction
    enum SilentAction {
        case fetchEventStickers
        case fetchEventFrames
        case startMonitoring(SpotType)
        case stopMonitoring(SpotType)
    }
}
