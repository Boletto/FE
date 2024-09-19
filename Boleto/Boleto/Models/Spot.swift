//
//  Spot.swift
//  Boleto
//
//  Created by Sunho on 9/3/24.
//

import Foundation
import CoreLocation

enum Spot: String, CaseIterable,Equatable {
    case seoul = "서울"
    case busan = "부산"
    case jeju = "제주"
    var upperString: String {
        switch self {
        case .seoul:
            "SEOUL"
        case .busan:
            "BUSAN"
        case .jeju:
            "JEJU"
        }
    }
    var coordinate: CLLocationCoordinate2D {
        switch self {
        case .seoul:
            CLLocationCoordinate2D(latitude: 126.97796, longitude: 37.56653)
        case .busan:
            CLLocationCoordinate2D(latitude: 129.0756, longitude: 35.17955)
        case .jeju:
            CLLocationCoordinate2D(latitude: 126.5311, longitude: 33.49962)
        }
    }
}
