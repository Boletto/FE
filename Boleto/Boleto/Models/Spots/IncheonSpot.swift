//
//  IncheonSpot.swift
//  Boleto
//
//  Created by Sunho on 12/17/24.
//


import Foundation
import CoreLocation

struct IncheonSpot: Spot {
    var name: String { "인천" }
    var upperString: String { "INCHEON" }
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: 37.456256, longitude: 126.705206)
    }
    var landmarks: [Badge] {
        return [

        ]
    }
}
