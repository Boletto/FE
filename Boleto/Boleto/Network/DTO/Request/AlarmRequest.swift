//
//  AlarmRequest.swift
//  Boleto
//
//  Created by Sunho on 11/11/24.
//

import Foundation

struct AlarmRequest: Encodable {
    var alarmType: AlarmType
    var value: String
    enum CodingKeys: String, CodingKey {
        case alarmType = "alarm_type"
        case value
    }
    
}
enum AlarmType: String, Codable {
    case sticker = "STICKER_ACQUISITION"
    case regionActive = "REGION_ACTIVATION"
    case regionDeactive = "REGION_DEACTIVATION"
    case travelTicket = "TRAVEL_TICKET"
    case invitedTicket = "FRIEND_INVITE_SENT"
    case friendAccept = "FRIEND_ACCEPT"
}
