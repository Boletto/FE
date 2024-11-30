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
        CLLocationCoordinate2D(latitude: 33.49962, longitude: 126.5311) // 제주시청 좌표
    }
    var landmarks: [Badge] {
        return [
            Badge(badgetype: .jj01, latitude: 33.3617, longtitude: 126.5331), // 한라산
            Badge(badgetype: .jj02, latitude: 33.4500, longtitude: 126.5000), // 별빛공원
            Badge(badgetype: .jj03, latitude: 33.4242, longtitude: 126.9307), // 섭지코지
            Badge(badgetype: .jj04, latitude: 33.5200, longtitude: 126.5400), // 용암동굴
            Badge(badgetype: .jj05, latitude: 33.3100, longtitude: 126.4090), // 카멜리아 힐
            Badge(badgetype: .jj06, latitude: 33.5141, longtitude: 126.4527), // 이호테우 해수욕장
            Badge(badgetype: .jj07, latitude: 33.2380, longtitude: 126.4300), // 주상절리대
            Badge(badgetype: .jj08, latitude: 33.5100, longtitude: 126.5267), // 제주동문시장
            Badge(badgetype: .jj09, latitude: 33.4500, longtitude: 126.3000)  // 한담해안산책로
        ]
    }
}
