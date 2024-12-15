//
//  GangnenugSpot.swift
//  Boleto
//
//  Created by Sunho on 11/29/24.
//

import Foundation
import CoreLocation
struct GangneungSpot: Spot {
    var name: String { "강릉" }
    var upperString: String { "GANGNEUNG" }
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: 37.76451, longitude: 128.899617)
    }
    var landmarks: [Badge] {
        return [
            Badge(badgetype: .gn01, latitude: 37.7955, longtitude: 128.9036), // 경포대
            Badge(badgetype: .gn02, latitude: 37.7955, longtitude: 128.9036), // 경포호
            Badge(badgetype: .gn03, latitude: 37.6890, longtitude: 129.0336), // 정동진
            Badge(badgetype: .gn04, latitude: 37.9000, longtitude: 128.8214)  // 주문진해변
        ]
    }
}
