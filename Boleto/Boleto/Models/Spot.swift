//
//  Spot.swift
//  Boleto
//
//  Created by Sunho on 9/3/24.
//

import Foundation
import CoreLocation
enum SpotType: String, CaseIterable, Identifiable, Equatable {
    var id: String {self.rawValue}
    
    case seoul, busan, jeju, school
    case dummy  
    
    var spot: Spot {
        switch self {
        case .seoul: return SeoulSpot()
        case .busan: return BusanSpot()
        case .jeju: return JejuSpot()
        case .school: return SchoolSpot()
        case .dummy: return MockSpot()
        }
    }
    
}
struct SpotFactory {
    static func fromUpperString(_ upperString: String) -> SpotType? {
        switch upperString {
        case "SEOUL": return .seoul
        case "BUSAN": return .busan
        case "JEJU": return .jeju
        case "KHU": return .school
            
        default: return nil
        }
    }
}

protocol Spot{
    
    var name: String { get }
    var upperString: String { get }
    var coordinate: CLLocationCoordinate2D { get }
    var landmarks: [Badge] { get }
}

struct MockSpot: Spot {
    var name: String  {"목업용"}
    var upperString: String {"Mock"}
    var coordinate: CLLocationCoordinate2D = .init(latitude:   37.50541, longitude: 126.947)
    var landmarks: [Badge] {
        return [
            Badge(badgetype: .khu, latitude: 37.2478, longtitude: 127.077),
            Badge(badgetype: .khu, latitude: 37.50541,longtitude: 126.9409)
            
        ]
    }
}

struct SeoulSpot: Spot {
    
    var name: String { "서울" }
    var upperString: String { "SEOUL" }
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: 37.56653, longitude:126.97796 )
    }
    var landmarks: [Badge] {
        return [
            Badge(badgetype: .gbg, latitude: 37.5759, longtitude: 126.9768),
            Badge(badgetype: .nst, latitude: 37.5524, longtitude: 126.9884),
            Badge(badgetype: .sl, latitude: 37.5101, longtitude: 127.0987),
            Badge(badgetype: .np, latitude: 37.5796, longtitude: 127.0072)
        ]
    }
}

struct BusanSpot: Spot {
    
    var name: String { "부산" }
    var upperString: String { "BUSAN" }
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: 129.0756, longitude: 35.17955)
    }
    var landmarks: [Badge] {
        return [
            Badge(badgetype: .gdb, latitude: 35.1536, longtitude: 129.1187),
            Badge(badgetype: .hb, latitude: 35.1587, longtitude: 129.1604),
            Badge(badgetype: .bs, latitude: 35.0988, longtitude: 129.0404),
            Badge(badgetype: .bcc, latitude: 35.1807, longtitude: 129.1243)
        ]
    }
}

struct JejuSpot: Spot {
    
    var name: String { "제주" }
    var upperString: String { "JEJU" }
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: 33.49962, longitude: 126.5311 )
    }
    var landmarks: [Badge] {
        return [
            Badge(badgetype: .hnp, latitude: 33.3617, longtitude: 126.5331),
            Badge(badgetype: .jc, latitude: 33.2449, longtitude: 126.5622),
            Badge(badgetype: .ch, latitude: 33.3051, longtitude: 126.4049),
            Badge(badgetype: .itb, latitude: 33.5059, longtitude: 126.4527)
        ]
    }
}

struct SchoolSpot: Spot {
    
    var name: String { "중앙도서관" }
    var upperString: String { "KHU" }
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: 37.2408, longitude: 127.07965135574341)
    }
    var landmarks: [Badge] {
        return [
            Badge(badgetype: .khu, latitude: 37.2478, longtitude: 127.077)
        ]
    }
}

