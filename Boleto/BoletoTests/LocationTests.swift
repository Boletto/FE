//
//  LocationTests.swift
//  BoletoTests
//
//  Created by Sunho on 10/24/24.
//

import Foundation
import XCTest
import ComposableArchitecture
import CoreLocation
@testable import Boleto

@MainActor
final class LocationTests: XCTestCase {
    func testFrameMointoringSuccess() async {
        let spot =  SpotType.dummy
        let store = TestStore(initialState: LocationMointoringFeature.State()) {
            LocationMointoringFeature()
        } withDependencies: {
            $0.locationClient.startMonitoring = { (spotparm: SpotType) in
                return AsyncStream { continuation in
                    continuation.yield(.didEnterFrameRegion)
                    continuation.finish()
                }
                
            }
            $0.notificationClient.add = { notification in
                // 알림 내용 검증
                XCTAssertEqual(notification.title, "에 도착했어요")
                XCTAssertEqual(notification.id, spot.spot.name)            }
            
        }
        await store.send(.startMonitoring(spot)) {
            $0.currentSpot = spot
        }
        
        await store.receive(.moniotirngEvent(.didEnterFrameRegion)) {
            $0.lastEvent = .didEnterFrameRegion
        }
        
        await store.receive(.notificationDelivered("Frame notification scheduled"))
    }
    func testStopMonitoringSuccess() async {
        let spot = SpotType.dummy
        var stoppedSpotType: SpotType?  // 실제로 중단된 spot을 추적하기 위한 변수
        
        let store = TestStore(initialState: LocationMointoringFeature.State()) {
            LocationMointoringFeature()
        } withDependencies: {
            $0.locationClient.stopMonitoring = { spotType in
                stoppedSpotType = spotType  // 중단된 spot을 저장
            }
        }
        
        // 먼저 모니터링을 시작
        await store.send(.startMonitoring(spot)) {
            $0.currentSpot = spot
        }
        
        // 모니터링 중단
        await store.send(.stopMonitoring(spot)) {
            $0.currentSpot = nil
        }
        
        // 실제로 올바른 spot의 모니터링이 중단되었는지 검증
        XCTAssertEqual(stoppedSpotType, spot, "올바른 spot의 모니터링이 중단되어야 합니다")
    }
    
    func testBadgeRegionMonitoringSuccess() async {
         let spot = SpotType.dummy
         let store = TestStore(initialState: LocationMointoringFeature.State()) {
             LocationMointoringFeature()
         } withDependencies: {
             $0.locationClient.startMonitoring = { (spotParam: SpotType) in
                 return AsyncStream { continuation in
                     continuation.yield(.didEnterBadgeRegion(.khu))
                     continuation.finish()
                 }
             }
             $0.notificationClient.add = { notification in
                 XCTAssertEqual(notification.title, "새로운 뱃지를 획득!")
                 XCTAssertEqual(notification.id, "KHU")
             }
         }
         
         await store.send(.startMonitoring(spot)) {
             $0.currentSpot = spot
         }
         
         await store.receive(.moniotirngEvent(.didEnterBadgeRegion(.khu))) {
             $0.lastEvent = .didEnterBadgeRegion(.khu)
         }
         
         await store.receive(.notificationDelivered("Badge notification scheduled"))
     }
}
