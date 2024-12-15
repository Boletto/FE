//
//  Ticket.swift
//  Boleto
//
//  Created by Sunho on 9/5/24.
//

import SwiftUI

struct Ticket: Equatable {
    let travelID: Int
    let departaure: SpotType
    let arrival: SpotType
    let startDate: Date
    let endDate: Date
    let participant: [MemberModel]
    let keywords: [Keywords]
    let editableID: Int?
    let fullSizeURL: URL
    let smallSizeURL: URL
    let createDate: String
}
extension Ticket {
    var status: TravelStatus {
        let now = Date()
        let calendar = Calendar.current
             
             // 오늘이 끝나는 시점(23:59:59)을 계산
             let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endDate) ?? endDate
        if now < startDate {
            return .future
        } else if now > endOfDay {
            return .completed
        } else {
            return .ongoing
        }
    }
}
extension Ticket {
    static let mockTickets: [Ticket] = [
        Ticket(
            travelID: 1,
            departaure: .busan, // Replace with appropriate SpotType
            arrival: .seoul,    // Replace with appropriate SpotType
            startDate: Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
            endDate: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
            participant: [MemberModel(id: 81, name: "유", nickname: "모해",imageUrl: nil)],     // Replace with appropriate [FriendDummy] if needed
            keywords: [.activity, .alone],
            editableID: 1234,
            fullSizeURL: URL(string: "https://objectstorage.ap-chuncheon-1.oraclecloud.com/n/axfasyxukuxi/b/boletto_bucket/o/system%2Ftickets%2Fchristmas_full_3.png")!,
            smallSizeURL: URL(string: "https://objectstorage.ap-chuncheon-1.oraclecloud.com/n/axfasyxukuxi/b/boletto_bucket/o/system%2Ftickets%2Fchristmas_small_3.png")!,
            createDate: "2024.08.24"
        ),
        Ticket(
            travelID: 2,
            departaure: .gyeongju, // Replace with appropriate SpotType
            arrival: .seoul,    // Replace with appropriate SpotType
            startDate: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
            endDate: Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
            participant: [MemberModel(id: 81, name: "유", nickname: "모해",imageUrl: nil)],
            keywords: [.fit, .alone],
            editableID: 1234,
            fullSizeURL: URL(string: "https://objectstorage.ap-chuncheon-1.oraclecloud.com/n/axfasyxukuxi/b/boletto_bucket/o/system%2Ftickets%2Fchristmas_full_3.png")!,
            smallSizeURL: URL(string: "https://objectstorage.ap-chuncheon-1.oraclecloud.com/n/axfasyxukuxi/b/boletto_bucket/o/system%2Ftickets%2Fchristmas_small_3.png")!,
            createDate: "2024.08.24"
        ),
        Ticket(
            travelID: 3,
            departaure: .seoul, // Replace with appropriate SpotType
            arrival: .seoul,    // Replace with appropriate SpotType
            startDate: Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
            endDate: Calendar.current.date(byAdding: .day, value: 2, to: Date())!,
            participant: [MemberModel(id: 81, name: "유", nickname: "모해",imageUrl: nil)],
            keywords: [.city, .fandom],
            editableID: 1234,
            fullSizeURL: URL(string: "https://objectstorage.ap-chuncheon-1.oraclecloud.com/n/axfasyxukuxi/b/boletto_bucket/o/system%2Ftickets%2Fchristmas_full_3.png")!,
            smallSizeURL: URL(string: "https://objectstorage.ap-chuncheon-1.oraclecloud.com/n/axfasyxukuxi/b/boletto_bucket/o/system%2Ftickets%2Fchristmas_small_3.png")!,
            createDate: "2024.08.24"
        )
//        Ticket(
//            travelID: 10,
//            departaure: .dummy, // Replace with appropriate SpotType
//            arrival: .seoul,    // Replace with appropriate SpotType
//            startDate: Calendar.current.date(byAdding: .day, value:11, to: Date())!,
//            endDate: Calendar.current.date(byAdding: .day, value: 19, to: Date())!,
//            participant: [MemberModel(id: 81, name: "유", nickname: "모해",imageUrl: nil)],  
//            keywords: [.city, .fandom],
//            color: .yellow
//        )
    ]
}


enum TravelStatus {
    case future
    case ongoing
    case completed
}

