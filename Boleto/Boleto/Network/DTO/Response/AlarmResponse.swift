//
//  AlarmResponse.swift
//  Boleto
//
//  Created by Sunho on 11/11/24.
//

import Foundation
struct AlarmResponse: Decodable {
    let userAlarmId: Int
    let alarmType: AlarmType
    let message: String
    let read: Bool
    let createdDate: String
    
    // Custom keys to match the server's expected JSON keys
    enum CodingKeys: String, CodingKey {
        case userAlarmId = "user_alarm_id"
        case alarmType = "alarm_type"
        case message
        case read
        case createdDate = "created_date"
    }
    func toAlarm() -> AlarmModel {
        
        return AlarmModel(alarmId: userAlarmId, alarmType: alarmType, read: read, formattedDate: createdDate.toDate()!, message: message)
    }
}
