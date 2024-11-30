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
        CLLocationCoordinate2D(latitude: 34.7604, longitude: 127.6622)
    }
    var landmarks: [Badge] {
        return [
            Badge(badgetype: .ys01, latitude: 34.7604, longtitude: 127.6622), // 엑스포
            Badge(badgetype: .ys02, latitude: 34.7478, longtitude: 127.7648), // 오동도
            Badge(badgetype: .ys03, latitude: 34.7384, longtitude: 127.6486), // 검은모래해변
            Badge(badgetype: .ys04, latitude: 34.7425, longtitude: 127.7378)  // 해상케이블카
        ]
    }
}
