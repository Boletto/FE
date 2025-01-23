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
        CLLocationCoordinate2D(latitude: 35.1151, longitude: 129.04141) // 부산역
    }
    var landmarks: [Badge] {
        return [
            Badge(badgetype: .bs01, latitude: 35.0984, longtitude: 129.0291), // BIFF 광장
            Badge(badgetype: .bs02, latitude: 35.07548, longtitude: 129.02231), // 송도 구름산책로
            Badge(badgetype: .bs03, latitude: 35.161233, longtitude: 129.191224), // 해운대 블루라인파크
            Badge(badgetype: .bs04, latitude: 35.28406, longtitude: 129.06848), // 범어사
            Badge(badgetype: .bs05, latitude: 35.1536, longtitude: 129.1187), // 광안리 대교
            Badge(badgetype: .bs06, latitude: 35.171202, longtitude: 129.127080), // 영화의 전당
            Badge(badgetype: .bs07, latitude: 35.1580, longtitude: 129.1603), // 해운대 해수욕장
            Badge(badgetype: .bs08, latitude: 35.078272, longtitude: 129.045342), // 흰여울마을
            Badge(badgetype: .bs09, latitude: 35.0970, longtitude: 129.0105)  // 감천문화마을
        ]
    }
}
