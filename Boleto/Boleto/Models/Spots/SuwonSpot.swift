//
//  SuwonSpot.swift
//  Boleto
//
//  Created by Sunho on 11/29/24.
//

import Foundation
import CoreLocation

struct SuwonSpot: Spot {
    var name: String { "수원" }
    var upperString: String { "SUWON" }
    var coordinate: CLLocationCoordinate2D {

        CLLocationCoordinate2D(latitude: 37.26357, longitude: 127.0286)
    }
    var landmarks: [Badge] {
        return [
            Badge(badgetype: .sw01, latitude: 37.265271, longtitude: 127.0377224), // 월화원
            Badge(badgetype: .sw02, latitude: 37.2871202, longtitude: 127.0119379), // 수원화성
            Badge(badgetype: .sw03, latitude: 37.2830911, longtitude: 127.0659215), // 광교호수공원
            Badge(badgetype: .sw04, latitude: 37.2864742, longtitude: 127.036866)  // 월드컵경기장
        ]
    }
}
