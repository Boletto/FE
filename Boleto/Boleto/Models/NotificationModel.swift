//
//  NotificationModel.swift
//  Boleto
//
//  Created by Sunho on 10/16/24.
//

import Foundation
protocol NotificationProtocol {
    var id: String {get}
    var title: String {get}
    var body: String{ get}
    var infoDictionary: [AnyHashable: String] { get }  // JSON 직렬화 대신 바로 딕셔너리 반환//    var userInfo:
}

struct BadgeNotification: NotificationProtocol {
    var infoDictionary: [AnyHashable: String] {
        ["NotificationType": "badge", "StickerImage": stickerImageType.rawValue]
     }
    var id: String
    var stickerImageType: StickerImage
    var title: String = "새로운 뱃지를 획득!"
    
    var body: String {
        "\(stickerImageType.koreanString)룰 획득했습니다."
    }
    
    
}
struct FrameNotification: NotificationProtocol {
    var body: String = "직접 프레임을 완성해보세요"
    
    var id: String
    
    
    var title: String {
        "에 도착했어요"
    }
    
    var infoDictionary: [AnyHashable: String] {
         ["NotificationType": "fourCutframe", "Spot": id]
     }
    
}
