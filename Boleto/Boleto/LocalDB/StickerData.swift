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
    @Attribute
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

extension StickerData {
    static let dummy = StickerData(
        stickerType: "STICKER",
        name: "경복궁",
        url: "https://objectstorage.ap-chuncheon-1.oraclecloud.com/n/axfasyxukuxi/b/boletto_bucket/o/system/stickers/SL01.png",
        isCollected: false,
        stickerCode: "SL01"
    )
}
