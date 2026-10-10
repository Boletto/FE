//
//  AlarmModel.swift
//  Boleto
//
//  Created by Sunho on 11/11/24.
//

import Foundation
struct AlarmModel: Equatable , Codable {
    let alarmId: Int
    let alarmType: AlarmType
    let read: Bool
    let formattedDate: Date
    let message: String
    let value: String
}
extension AlarmModel {
    static let dummy = [AlarmModel(alarmId: 2, alarmType: .sticker, read: false, formattedDate: Date(), message: "안녕핑", value: "서울"),
                        AlarmModel(alarmId: 3, alarmType: .sticker, read: false, formattedDate: Date(), message: "헬로우", value: "남산타워"),
                        AlarmModel(alarmId: 4, alarmType: .sticker, read: false, formattedDate: Date(), message: "선호야", value:"부산")]
}
