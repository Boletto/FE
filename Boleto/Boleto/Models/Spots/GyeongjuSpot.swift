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
        CLLocationCoordinate2D(latitude: 35.798365, longitude: 129.138955)
    }
    var landmarks: [Badge] {
        return [
            Badge(badgetype: .gj01, latitude: 35.79515, longtitude: 129.3503795), // 석굴암
            Badge(badgetype: .gj02, latitude: 35.8346828, longtitude: 129.2190631), // 첨성대
            Badge(badgetype: .gj03, latitude: 36.0117144, longtitude: 129.1633118), // 옥산서원
            Badge(badgetype: .gj04, latitude: 35.8374368, longtitude: 129.2327585)  // 황룡사지
        ]
    }
}
