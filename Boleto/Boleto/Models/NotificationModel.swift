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
    func toUserInfo() -> [String: Any]
//    var userInfo:
}

struct BadgeNotification: NotificationProtocol {
    func toUserInfo() -> [String : Any] {
        return ["NotificationType": "badge", "StickerImage": stickerImageType]
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
    
    func toUserInfo() -> [String : Any] {
        return ["NotificationType": "fourCutframe", "Spot": title]
    }
    
    
}
