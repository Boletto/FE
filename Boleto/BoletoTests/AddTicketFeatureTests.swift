////
////  AddTicketFeatureTests.swift
////  BoletoTests
////
////  Created by Sunho on 10/31/24.
////
//
//import XCTest
//import ComposableArchitecture
//@testable import Boleto
//
//final class AddTicketFeatureTests: XCTestCase {
//
//    var testDate: Date {
//        var components = DateComponents()
//        components.year = 2024
//        components.month = 10
//        components.day = 31
//        components.hour = 9
//        components.minute = 0
//        components.second = 0
//        
//        return Calendar.current.date(from: components)!
//    }
//    func testShowBottomSheets() async {
//        let store = await TestStore(initialState: AddTicketFeature.State()) {
//            AddTicketFeature()
//        } withDependencies: {
//            $0.travelClient = .testValue
//        }
//        
//        await store.send(.showDepartuare) {
//            $0.bottomSheet = .departureSelection(SpotSelectionFeature.State())
//        }
//        
//        await store.send(.showkeywords) {
//            $0.bottomSheet = .traveTypeSeleciton(KeywordSelectionFeature.State())
//        }
//        
//        await store.send(.showfriends) {
//            $0.bottomSheet = .friendSelection(FriendSelectionFeature.State(selectedFriends: []))
//        }
//        
//        await store.send(.showDateSelection) {
//            $0.bottomSheet = .dateSelection(DateSelectionFeature.State(month: Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date()))!))
//        }
//    }
//    func testMakeTicket_success() async {
//        var state = AddTicketFeature.State()
//        state.departureSpot =  SpotType.seoul
//        state.arrivialSpot =  SpotType.dummy
//        state.startDate = testDate
//        state.endDate =  Calendar.current.date(byAdding: .day, value: 1, to: testDate)!
//        state.keywords =  [.activity, .alone]
//
//
//        let testStore = await TestStore(initialState: state) {
//            AddTicketFeature()
//        } withDependencies: {
//            $0.travelClient = .testValue
//            
//        }
//        await testStore.send(.tapmakeTicket)
//        await testStore.receive(.successTicket)
//        
//    }
//    func testMakeTicket_failure() async {
//        let store = await TestStore(initialState: AddTicketFeature.State()) {
//            AddTicketFeature()
//        } withDependencies: {
//            $0.travelClient = .testValue
//        }
//        await store.send(.tapmakeTicket)
//        await store.receive(.failureTicket("출발지와 도착지를 선택해주세요."))
//    }
//    func testEditTicket_success() async  {
//        var state = AddTicketFeature.State(mode: .edit(Ticket.mockTickets[0]))
//        state.departureSpot = SpotType.seoul
//        state.arrivialSpot = SpotType.busan
//            state.startDate = testDate
//            state.endDate = Calendar.current.date(byAdding: .day, value: 1, to: testDate)
//            state.keywords = [.activity, .alone]
//        
//        let testStore = await TestStore(initialState: state) {
//            AddTicketFeature()
//        } withDependencies: {
//            $0.travelClient = .testValue
//            
//        }
//        await testStore.send(.tapmakeTicket) 
//        await testStore.receive(.successTicket)
//    }
//}
