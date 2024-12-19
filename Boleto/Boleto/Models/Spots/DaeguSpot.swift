//
//  DaeguSpot.swift
//  Boleto
//
//  Created by Sunho on 12/17/24.
//


import Foundation
import CoreLocation

struct DaeguSpot: Spot {
    var name: String { "대구" }
    var upperString: String { "DAEGU" }
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: 35.871435, longitude: 128.601445)
    }
    var landmarks: [Badge] {
        return [

        ]
    }
}
