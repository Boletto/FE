//
//  DaejeonSpot.swift
//  Boleto
//
//  Created by Sunho on 12/17/24.
//


import Foundation
import CoreLocation

struct DaejeonSpot: Spot {
    var name: String { "대전" }
    var upperString: String { "DAEJEON" }
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: 36.350411, longitude: 127.384547)
    }
    var landmarks: [Badge] {
        return [

        ]
    }
}
