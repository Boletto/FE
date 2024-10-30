//
//  AllTicketOverViewFeatureTests.swift
//  BoletoTests
//
//  Created by Sunho on 10/28/24.
//

import XCTest
import ComposableArchitecture

@testable import Boleto
@MainActor
final class AllTicketOverViewFeatureTests: XCTestCase {
    let mockTickets = [
        Ticket.makeMockTicket(id: 1, status: .completed),
        Ticket.makeMockTicket(id: 2, status: .ongoing),
        Ticket.makeMockTicket(id: 3, status: .future)
    ]
    func testFetchTicketSuccess() async {
        let testStore = TestStore(initialState: AllTicketsOverViewFeature.State()) {
            AllTicketsOverViewFeature()
        } withDependencies: {
            $0.travelClient.getAlltravel = { @Sendable in
                return self.mockTickets
            }
        }
        await testStore.send(.fetchTickets)
        await testStore.receive(.updateTickets(mockTickets)) { state in
            state.allTickets = self.mockTickets
            state.classifyTickets()
            
            // Verify tickets are classified correctly
            XCTAssertEqual(state.currentTicket, self.mockTickets[1]) // ongoing ticket
            XCTAssertEqual(state.completedTickets, [self.mockTickets[0]]) // completed ticket
            XCTAssertEqual(state.futureTickets, [self.mockTickets[2]]) // future ticket
        }
    }
    
    func testConfirmDeletionSuccess() async {
        let mockTicket = mockTickets[0]
        let testStore = TestStore(initialState: AllTicketsOverViewFeature.State(allTickets: mockTickets)) {
            AllTicketsOverViewFeature()
        } withDependencies: {
            $0.travelClient.deleteTravel = {@Sendable _ in true}
        }
        await testStore.send(.confirmDeletion(mockTicket)) { state in
            state.selectedTicket = mockTicket
            state.alert = AlertState {
                TextState("삭제 확인")
            } actions: {
                ButtonState(role: .destructive, action: .confirmDeletion) {
                    TextState("삭제")
                }
                ButtonState(role: .cancel) {
                    TextState("취소")
                }
            } message: {
                TextState("정말로 이 여행을 삭제하시겠습니까?")
            }
        }
  
    }
    func testDeletionSuccess() async {
        let ticket = mockTickets[0]
        let testStore =  TestStore(initialState: AllTicketsOverViewFeature.State(allTickets: mockTickets, selectedTicket: ticket)) {
            AllTicketsOverViewFeature()
        } withDependencies: {
            $0.travelClient.deleteTravel = { @Sendable _ in true }
        }

        await testStore.send(.deletionResponse(true)) { state in
            state.allTickets = [self.mockTickets[1],self.mockTickets[2]]
            state.completedTickets = []
            state.futureTickets = [self.mockTickets[2]]
            state.currentTicket = self.mockTickets[1]
            state.alert = AlertState {
                TextState("삭제 성공")
            } actions: {
                ButtonState(action: .deletionSuccess) {
                    TextState("확인")
                }
            } message: {
                TextState("여행이 성공적으로 삭제되었습니다.")
            }
        }
        XCTAssertFalse(testStore.state.allTickets.contains(where: { $0.travelID == ticket.travelID }), "The ticket should be deleted from allTickets.")
    }
    func testDeletionFail() async {
        let testStore =  TestStore(initialState: AllTicketsOverViewFeature.State(allTickets: mockTickets)) {
            AllTicketsOverViewFeature()
        } withDependencies: {
            $0.travelClient.deleteTravel = { @Sendable _ in true }
        }
        await testStore.send(.deletionResponse(false)) {
            $0.allTickets = [self.mockTickets[0], self.mockTickets[1], self.mockTickets[2]]
            $0.alert = AlertState {
                TextState("삭제 실패")
            } actions: {
                ButtonState(action: .deletionError) {
                    TextState("확인")
                }
            } message: {
                TextState("여행 삭제 중 오류가 발생했습니다. 다시 시도해 주세요.")
            }
        }
    }
    
}

