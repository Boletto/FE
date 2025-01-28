//
//  LocationTests.swift
//  BoletoTests
//
//  Created by Sunho on 10/24/24.
//

import Foundation
import Testing
import ComposableArchitecture
import CoreLocation

@testable import Boleto

@MainActor
struct LocationTests {
    @Test
    func testStartMonitoringFail() async {
        let spot = SpotType.seoul
        let store = TestStore(initialState: LocationMointoringFeature.State()) {
            LocationMointoringFeature()
        } withDependencies: {
            $0.locationClient.startMonitoring = {(spotparm: SpotType) in
                throw LocationMonitoringError.monitoringStartFailed
            }
        }
        await store.send(.startMonitoring(spot))
        await store.receive(\.monitorFailed) {
            $0.error = .monitoringStartFailed
        }
    }
    
    @Test("Check Monitor Badge")
    func enterBadgeRegion() async throws {
        let spot = SpotType.seoul
        let store = TestStore(initialState: LocationMointoringFeature.State()) {
            LocationMointoringFeature()
        } withDependencies: {
            $0.locationClient.startMonitoring = { _ in
                AsyncStream { continuation in
                    continuation.yield(.didEnterBadgeRegion(.sl01))
                    continuation.finish()
                }
            }
            $0.notificationClient.add = { _ in}
            $0.alarmClient.postNewAlarm = {_, _ in}
            $0.userClient.postStickerCode = { _ in}
        }
        await store.send(.startMonitoring(spot))
        await store.receive(\.monitoringEvent) {
            $0.lastEvent = .didEnterBadgeRegion(.sl01)
        }
    }
    
    @Test("Check Monitor Frame")
    func enterFrameRegion() async throws {
        let spot = SpotType.seoul
        let store = TestStore(initialState: LocationMointoringFeature.State()) {
            LocationMointoringFeature()
        } withDependencies: {
            $0.locationClient.startMonitoring = { _ in
                AsyncStream { continuation in
                    continuation.yield(.didEnterFrameRegion("seoul"))
                    continuation.finish()
                }
            }
            $0.notificationClient.add = { _ in}
            $0.alarmClient.postNewAlarm = {_, _ in}
        }
        await store.send(.startMonitoring(spot))
        await store.receive(\.monitoringEvent) {
            $0.lastEvent = .didEnterFrameRegion("seoul")
        }
    }
    
    @Test("DuplicateMonitoring")
    func duplicateMonitoring() async {
        let spot = SpotType.seoul
        let store = TestStore(initialState: LocationMointoringFeature.State()) {
            LocationMointoringFeature()
        } withDependencies: {
            $0.locationClient.isMonitoringActive = {true}
        }
        await store.send(.checkMonitoring(spot))
    }
    
    @Test("AvailableMonitoring")
    func availableMonitoring() async throws {
        let spot = SpotType.seoul
        let store = TestStore(initialState: LocationMointoringFeature.State()) {
            LocationMointoringFeature()
        } withDependencies: {
            $0.locationClient.isMonitoringActive = { false }
               $0.locationClient.authorizationStatus = { .authorizedAlways}
            $0.locationClient.startMonitoring = { _ in
                      AsyncStream { continuation in
                          continuation.finish()
                      }
                  }
        }
        await store.send(.checkMonitoring(spot))
        await store.receive(\.startMonitoring)
    }
}
