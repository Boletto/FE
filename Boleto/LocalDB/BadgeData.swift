//
//  BadgeData.swift
//  Boleto
//
//  Created by Sunho on 9/14/24.
//

import SwiftData

@Model
class BadgeData {
    var name: String
    var imageName: String
    var latitude: Double
    var longtitude: Double
    var isCollected: Bool
    init(name: String, imageName: String, latitude: Double, longtitude: Double, isCollected: Bool) {
        self.name = name
        self.imageName = imageName
        self.latitude = latitude
        self.longtitude = longtitude
        self.isCollected = isCollected
    }
}

extension BadgeData {
    static let dummy = [    BadgeData(name: "경복궁", imageName: "seoulSticker1", latitude: 37.5759, longtitude: 126.9768, isCollected: false),
                            BadgeData(name: "남산", imageName: "seoulSticker2", latitude: 37.5524, longtitude: 126.9884, isCollected: false),
                            BadgeData(name: "성산일출봉", imageName: "JejuBadge2", latitude: 37.5524, longtitude: 126.9884, isCollected: false),
                            BadgeData(name: "해운대", imageName: "BusanBadge1", latitude: 38.222, longtitude: 32.444, isCollected: false)

                           ]
}
