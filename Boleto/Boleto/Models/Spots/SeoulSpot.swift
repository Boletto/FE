//
//  SeoulSpot.swift
//  Boleto
//
//  Created by Sunho on 11/29/24.
//
import Foundation
import CoreLocation

struct SeoulSpot: Spot {
    var name: String { "서울" }
    var upperString: String { "SEOUL" }
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: 37.554739, longitude:  126.97078) // 서울역
    }
    var landmarks: [Badge] {
        return [
            Badge(badgetype: .sl01, latitude: 37.5796, longtitude: 126.9770), // 경복궁
            Badge(badgetype: .sl02, latitude: 37.5270, longtitude: 126.9326), // 여의도 한강공원
            Badge(badgetype: .sl03, latitude: 37.5793, longtitude: 127.0072), // 낙산공원
            Badge(badgetype: .sl04, latitude: 37.5512, longtitude: 126.9882), // 남산타워
            Badge(badgetype: .sl05, latitude: 37.5110, longtitude: 127.0982), // 롯데월드
            Badge(badgetype: .sl06, latitude: 37.5716, longtitude: 126.9768), // 광화문광장
            Badge(badgetype: .sl07, latitude: 37.5826, longtitude: 126.9830), // 북촌한옥마을
            Badge(badgetype: .sl08, latitude: 37.5823, longtitude: 126.9919)  // 창덕궁 후원
        ]
    }
}
