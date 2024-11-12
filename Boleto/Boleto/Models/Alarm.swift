//
//  AlarmModel.swift
//  Boleto
//
//  Created by Sunho on 11/11/24.
//

import Foundation
struct AlarmModel: Equatable {
    let alarmId: Int
    let alarmType: AlarmType
    let read: Bool
    let formattedDate: Date
    let message: String
}
extension AlarmModel {
    static let dummy = [AlarmModel(alarmId: 2, alarmType: .sticker, read: false, formattedDate: Date(), message: "안녕핑"),
                        AlarmModel(alarmId: 3, alarmType: .sticker, read: false, formattedDate: Date(), message: "헬로우"),
                        AlarmModel(alarmId: 4, alarmType: .sticker, read: false, formattedDate: Date(), message: "선호야")]
}
