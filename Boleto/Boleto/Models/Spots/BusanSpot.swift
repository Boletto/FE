//
//  BusanSpot.swift
//  Boleto
//
//  Created by Sunho on 11/29/24.
//
import Foundation
import CoreLocation
struct BusanSpot: Spot {
    var name: String { "부산" }
    var upperString: String { "BUSAN" }
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: 35.1796, longitude: 129.0756) // 부산 시청 좌표
    }
    var landmarks: [Badge] {
        return [
            Badge(badgetype: .bs01, latitude: 35.1019, longtitude: 129.0307), // BIFF 광장
            Badge(badgetype: .bs02, latitude: 35.0815, longtitude: 129.0164), // 송도 구름산책로
            Badge(badgetype: .bs03, latitude: 35.1587, longtitude: 129.1604), // 해운대 블루라인파크
            Badge(badgetype: .bs04, latitude: 35.2672, longtitude: 129.0926), // 범어사
            Badge(badgetype: .bs05, latitude: 35.1536, longtitude: 129.1187), // 광안리 대교
            Badge(badgetype: .bs06, latitude: 35.1807, longtitude: 129.1243), // 영화의 전당
            Badge(badgetype: .bs07, latitude: 35.1580, longtitude: 129.1603), // 해운대 해수욕장
            Badge(badgetype: .bs08, latitude: 35.0885, longtitude: 129.0347), // 흰여울마을
            Badge(badgetype: .bs09, latitude: 35.0970, longtitude: 129.0105)  // 감천문화마을
        ]
    }
}
