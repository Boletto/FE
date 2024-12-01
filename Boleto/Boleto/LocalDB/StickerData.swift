//
//  BadgeData.swift
//  Boleto
//
//  Created by Sunho on 9/14/24.
//

import SwiftData

@Model
class StickerData {
    var stickerType: String
    var name: String
    var url: String
    var isCollected: Bool
    var stickerCode: String
    var region: String
    init(stickerType: String, name: String, url: String, isCollected: Bool, stickerCode: String) {
        self.stickerType = stickerType
        self.name = name
        self.url = url
        self.isCollected = isCollected
        self.stickerCode = stickerCode
        self.region = StickerData.mapRegion(from: stickerCode)
    }
    private static func mapRegion(from stickerCode: String) -> String {
        switch stickerCode.prefix(2) {
        case "SL": return "서울"
        case "JJ": return "제주"
        case "BS": return "부산"
        case "SW": return "수원"
        case "GN": return "강릉"
        case "YS": return "여수"
        case "GJ": return "경주"
        default: return "기타"
        }
    }
}

//extension BadgeData {
//    static let dummy = [    BadgeData(name: "경복궁", imageName: "seoulSticker1", latitude: 37.5759, longtitude: 126.9768, isCollected: false),
//                            BadgeData(name: "남산", imageName: "seoulSticker2", latitude: 37.5524, longtitude: 126.9884, isCollected: false),
//                            BadgeData(name: "성산일출봉", imageName: "JejuBadge2", latitude: 37.5524, longtitude: 126.9884, isCollected: false),
//                            BadgeData(name: "해운대", imageName: "BusanBadge1", latitude: 38.222, longtitude: 32.444, isCollected: false)
//
//                           ]
//}
