//
//  JejuSpot.swift
//  Boleto
//
//  Created by Sunho on 11/29/24.
//
import Foundation
import CoreLocation

struct JejuSpot: Spot {
    var name: String { "제주" }
    var upperString: String { "JEJU" }
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: 33.5070772, longitude: 126.4934311) // 제주공항
    }
    var landmarks: [Badge] {
        return [
            Badge(badgetype: .jj01, latitude: 33.3616666, longtitude: 126.5291666), // 한라산
            Badge(badgetype: .jj02, latitude: 33.4445307, longtitude: 126.5492916), // 별빛공원
            Badge(badgetype: .jj03, latitude: 33.4242095, longtitude: 126.931111), // 섭지코지
            Badge(badgetype: .jj04, latitude: 33.369241, longtitude: 126.25873), // 용암동굴
            Badge(badgetype: .jj05, latitude: 33.2898, longtitude: 126.36829), // 카멜리아 힐
            Badge(badgetype: .jj06, latitude: 33.49592, longtitude: 126.45493), // 이호테우 해수욕장
            Badge(badgetype: .jj07, latitude: 33.238903, longtitude: 126.42648), // 주상절리대
            Badge(badgetype: .jj08, latitude: 33.51204, longtitude: 126.52827), // 제주동문시장
            Badge(badgetype: .jj09, latitude: 33.459084, longtitude: 126.31057)  // 한담해안산책로
        ]
    }
}
