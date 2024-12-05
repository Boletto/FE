//
//  GyeongjuSpot.swift
//  Boleto
//
//  Created by Sunho on 11/29/24.
//
import Foundation
import CoreLocation
struct GyeongjuSpot: Spot {
    var name: String { "경주" }
    var upperString: String { "GYEONGJU" }
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: 35.8562, longitude: 129.2241)
    }
    var landmarks: [Badge] {
        return [
            Badge(badgetype: .gj01, latitude: 35.7950, longtitude: 129.3325), // 석굴암
            Badge(badgetype: .gj02, latitude: 35.8345, longtitude: 129.2190), // 첨성대
            Badge(badgetype: .gj03, latitude: 35.8881, longtitude: 129.2873), // 옥산서원
            Badge(badgetype: .gj04, latitude: 35.8390, longtitude: 129.2240)  // 황룡사지
        ]
    }
}
