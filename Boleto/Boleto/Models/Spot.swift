//
//  Spot.swift
//  Boleto
//
//  Created by Sunho on 9/3/24.
//

import Foundation
import CoreLocation
enum SpotType: String, CaseIterable, Identifiable, Equatable {
    var id: String { self.rawValue }
    
    case seoul, busan, jeju
    case gangneung, suwon, gyeongju, yeosu
    
    var spot: Spot {
        switch self {
        case .seoul: return SeoulSpot()
        case .busan: return BusanSpot()
        case .jeju: return JejuSpot()
        case .gangneung: return GangneungSpot()
        case .suwon: return SuwonSpot()
        case .gyeongju: return GyeongjuSpot()
        case .yeosu: return YeosuSpot()
        default: return MockSpot()
        }
    }
    static func fromUpperString(_ upperString: String) -> SpotType? {
        return SpotType.allCases.first {$0.spot.upperString == upperString}
    }
    static func fromKoreanString(_ name: String) -> SpotType? {
        return SpotType.allCases.first{$0.spot.name == name}
    }
}

protocol Spot{
    
    var name: String { get }
    var upperString: String { get }
    var coordinate: CLLocationCoordinate2D { get }
    var landmarks: [Badge] { get }
}

struct MockSpot: Spot {
    var name: String { "테스트용 스팟" }
    var upperString: String { "MOCK" }
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: 37.1234, longitude: 127.5678) // 임의의 테스트 좌표
    }
    var landmarks: [Badge] {
        return [
            Badge(badgetype: .sl01, latitude: 37.5665, longtitude: 126.9780), // 서울 랜드마크 예시
            Badge(badgetype: .bs01, latitude: 35.1796, longtitude: 129.0756), // 부산 랜드마크 예시
            Badge(badgetype: .jj01, latitude: 33.3617, longtitude: 126.5331), // 제주 랜드마크 예시
            Badge(badgetype: .gn01, latitude: 37.8059, longtitude: 128.9036), // 강릉 랜드마크 예시
            Badge(badgetype: .sw01, latitude: 37.2845, longtitude: 127.0439)  // 수원 랜드마크 예시
        ]
    }
}
