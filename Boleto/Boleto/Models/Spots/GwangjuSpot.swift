//
//  GwangjuSpot.swift
//  Boleto
//
//  Created by Sunho on 12/17/24.
//


import Foundation
import CoreLocation

struct GwangjuSpot: Spot {
    var name: String { "광주" }
    var upperString: String { "GWANGJU" }
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: 35.159545, longitude: 126.852601)
    }
    var landmarks: [Badge] {
        return [
        ]
    }
}
