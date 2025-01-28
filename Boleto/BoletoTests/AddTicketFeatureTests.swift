//
//  AddTicketFeatureTests.swift
//  BoletoTests
//
//  Created by Sunho on 10/31/24.
//

import Testing
import UIKit
import ComposableArchitecture
@testable import Boleto

@MainActor
struct AddTicketFeatureTests {
    var testDate: Date {
        var components = DateComponents()
        components.year = 2025
        components.month = 1
        components.day = 28
        components.hour = 9
        components.minute = 0
        components.second = 0
        
        return Calendar.current.date(from: components)!
    }
    
    @Test("showBottomSheets")
    func testShowBottomSheets() async {
        let store = TestStore(initialState: AddTicketFeature.State()) {
            AddTicketFeature()
        } withDependencies: {
            $0.travelClient = .testValue
        }
        
        await store.send(.showDepartuare) {
            $0.bottomSheet = .departureSelection(SpotSelectionFeature.State())
        }
        
        await store.send(.showkeywords) {
            $0.bottomSheet = .traveTypeSeleciton(KeywordSelectionFeature.State())
        }
        
        await store.send(.showfriends) {
            $0.bottomSheet = .friendSelection(FriendsFeature.State(friends: [], selectedFriends: []))
        }
        
        await store.send(.showDateSelection) {
            $0.bottomSheet = .dateSelection(DateSelectionFeature.State(month: Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date()))!))
        }
    }
    
    @Test("SuccessMakeTicket")
    func successMakeTicket() async {
        var state = AddTicketFeature.State()
        state.startDate = Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 28))!
        state.endDate = Calendar.current.date(from: DateComponents(year: 2025, month: 2, day: 4))!
        state.mode = .add
        state.keywords = [.activity]
        state.departureSpot = .seoul
        state.arrivialSpot = .busan
        let store = TestStore(initialState: state) {
            AddTicketFeature()
        } withDependencies: {
            $0.travelClient = .testValue
        }
        await store.send(.tapmakeTicket)
        await store.receive(.successTicket)
    }
    
    @Test("FailMakeTicket")
    func failMakeTicket() async {
        let store = TestStore(initialState: AddTicketFeature.State(mode: .add)) {
            AddTicketFeature()
        } withDependencies: {
            $0.travelClient = .testValue
        }
        await store.send(.tapmakeTicket)
        await store.receive(\.failureTicket) {
            $0.alert = AlertState {
                TextState("에러")
            } actions: {
                ButtonState(role: .cancel) {
                    TextState("확인")
                }
            } message: {
                TextState("출발지와 도착지를 선택해주세요.")
            }
        }
    }
}
