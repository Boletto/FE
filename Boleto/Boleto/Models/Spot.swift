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
    var landmarks: [Badge] {
        switch self {
        case .seoul:
            return [
                Badge(badgetype: .gbg, latitude: 37.5759, longtitude: 126.9768),
                Badge(badgetype: .nst, latitude:37.5524, longtitude: 126.9884),
                Badge(badgetype: .sl, latitude: 37.5101, longtitude: 127.0987),
                Badge(badgetype: .np, latitude: 37.5796, longtitude: 127.0072),
            ]
        case .busan:
            return [
                Badge(badgetype: .gdb, latitude: 35.1536, longtitude: 129.1187),
                Badge(badgetype: .hb, latitude:35.1587, longtitude: 129.1604),
                Badge(badgetype: .bs, latitude: 35.0988, longtitude: 129.0404),
                Badge(badgetype: .bcc, latitude: 35.1807, longtitude: 129.1243),

            ]
        case .jeju:
            return [
                Badge(badgetype: .hnp, latitude: 33.3617, longtitude: 126.5331),
                Badge(badgetype: .jc, latitude:33.2449, longtitude: 126.5622),
                Badge(badgetype: .ch, latitude: 33.3051, longtitude: 126.4049),
                Badge(badgetype: .itb, latitude: 33.5059, longtitude: 126.4527),
            ]
        }
    }
}
