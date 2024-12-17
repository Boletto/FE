//
//  UlsanSpot.swift
//  Boleto
//
//  Created by Sunho on 12/17/24.
//


import Foundation
import CoreLocation

struct UlsanSpot: Spot {
    var name: String { "울산" }
    var upperString: String { "ULSAN" }
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: 35.538377, longitude: 129.311360)
    }
    var landmarks: [Badge] {
        return [
        ]
    }
}
