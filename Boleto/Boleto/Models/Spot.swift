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
    var landmarks: [BadgeData] {
        switch self {
        case .seoul:
            return [
                BadgeData(name: "경복궁", imageName: .gbg, latitude: 37.5759, longtitude: 126.9768, isCollected: false),
                BadgeData(name: "남산타워", imageName: .nst, latitude: 37.5524, longtitude: 126.9884, isCollected: false),
                BadgeData(name: "석촌호수", imageName:  .sl, latitude: 37.5101, longtitude: 127.0987, isCollected: false),
                BadgeData(name: "낙산공원", imageName: .np, latitude: 37.5796, longtitude: 127.0072, isCollected: false)
            ]
        case .busan:
            return [
                BadgeData(name: "광안대교", imageName: .gdb, latitude: 35.1536, longtitude: 129.1187, isCollected: false),
                BadgeData(name: "해운대 해수욕장", imageName: .hb, latitude: 35.1587, longtitude: 129.1604, isCollected: false),
                BadgeData(name: "BIFF 광장", imageName: .bs, latitude: 35.0988, longtitude: 129.0404, isCollected: false),
                BadgeData(name: "영화의 전당", imageName: .bcc, latitude: 35.1807, longtitude: 129.1243, isCollected: false)
            ]
        case .jeju:
            return [
                BadgeData(name: "한라산 국립공원", imageName: .hnp, latitude: 33.3617, longtitude: 126.5331, isCollected: false),
                BadgeData(name: "주상절리대", imageName: .jc, latitude: 33.2449, longtitude: 126.5622, isCollected: false),
                BadgeData(name: "카멜리아 힐", imageName: .ch, latitude: 33.3051, longtitude: 126.4049, isCollected: false),
                BadgeData(name: "이호테우 해수욕장", imageName: .itb, latitude: 33.5059, longtitude: 126.4527, isCollected: false)
            ]
        }
    }
}
