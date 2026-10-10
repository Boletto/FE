//
//  YeosuSpot.swift
//  Boleto
//
//  Created by Sunho on 11/29/24.
//

import Foundation
import CoreLocation

struct YeosuSpot: Spot {
    var name: String { "여수" }
    var upperString: String { "YEOSU" }
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: 34.757778, longitude: 127.747222)
    }
    var landmarks: [Badge] {
        return [
            Badge(badgetype: .ys01, latitude: 34.7508, longtitude: 127.7471), // 엑스포
            Badge(badgetype: .ys02, latitude: 34.74434, longtitude: 127.76412), // 오동도
            Badge(badgetype: .ys03, latitude: 34.77597, longtitude: 127.7446), // 검은모래해변
            Badge(badgetype: .ys04, latitude: 34.73056, longtitude: 127.7415)  // 해상케이블카
        ]
    }
}
