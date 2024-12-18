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
            Badge(badgetype: .gj01, latitude: 35.79515, longtitude: 129.350379), // 석굴암
            Badge(badgetype: .gj02, latitude: 35.834682, longtitude: 129.219063), // 첨성대
            Badge(badgetype: .gj03, latitude: 36.011714, longtitude: 129.163311), // 옥산서원
            Badge(badgetype: .gj04, latitude: 35.837436, longtitude: 129.232758)  // 황룡사지
        ]
    }
}
