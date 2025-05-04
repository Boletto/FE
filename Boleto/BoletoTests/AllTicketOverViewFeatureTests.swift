//
//  AllTicketOverViewFeatureTests.swift
//  BoletoTests
//
//  Created by Sunho on 10/28/24.
//

import Testing
import Foundation
import ComposableArchitecture

@testable import Boleto

@Suite("AllTicketsOverViewFeature Tests")
struct AllTicketsOverViewFeatureTests {
    @Test("Fetch Tickets Successfully")
    func testFetchTicketSuccess() async throws {
        let store = TestStore(initialState: AllTicketsOverViewFeature.State()) {
            AllTicketsOverViewFeature()
        } withDependencies: {
            $0.travelClient.getAlltravel = {_ in Ticket.mockTickets}
            $0.locationClient.startMonitoring = { _ in AsyncStream {_ in }}
            $0.ttiClient.postEvent = { _, _ in }
            
        }
        await store.send(.fetchTickets)
        await store.receive(.updateTickets(Ticket.mockTickets)) { state in
            state.allTickets = Ticket.mockTickets
            state.currentTicket = Ticket.mockTickets[0]
            state.completedTickets = [Ticket.mockTickets[1]]
            // Make sure both future tickets are expected in the right order
            state.futureTickets = [Ticket.mockTickets[2], Ticket.mockTickets[3]]
        }
        await store.receive(.startMonitoirng(Ticket.mockTickets[0].arrival))
        await store.receive(.recordTTI("TicketList", "Showtickets"))
    }
    @Test("Fetch Tickets Fails")
    func testFetchTicketOtherError() async throws {
        let store = TestStore(initialState: AllTicketsOverViewFeature.State()) {
            AllTicketsOverViewFeature()
        } withDependencies: { dependencies in
            dependencies.travelClient.getAlltravel = { _ in
                throw CustomError.internalServerError("server error")
            }
            dependencies.ttiClient.postEvent = { _, _ in }
        }
        
        await store.send(.fetchTickets)
        // 서버 오류 발생 시 빈 배열로 업데이트됨
        await store.receive(.updateTickets([]))
        
        await store.receive(.recordTTI("TicketList", "Showtickets"))
    }
    
    @Test("DeleteTicketSuccess")
    func testDeleteTicketSuccess() async throws {
        let targetTicket = Ticket.mockTickets[0]
        let otherTickets = Array(Ticket.mockTickets.dropFirst())
        var initialState = AllTicketsOverViewFeature.State(currentTicket: targetTicket, allTickets: Ticket.mockTickets)
        let store = TestStore(initialState: initialState) {
            AllTicketsOverViewFeature()
        } withDependencies: {
            $0.travelClient.deleteTravel = { _ in
                true
            }
            $0.ttiClient.postEvent = { _, _ in }
            $0.locationClient.startMonitoring = { _ in AsyncStream {_ in }}
        }
        store.exhaustivity = .off

        await store.send(.confirmDeletion(targetTicket)) { state in
            state.selectedTicket = targetTicket
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

        await store.send(.alert(.presented(.confirmDeletion)))
        await store.receive(.stopMonitoring)
        await store.receive(.deletionResponse(true)) { state in
                state.allTickets = otherTickets
      
            }
            
        await store.receive(.updateTickets(otherTickets))

            
            // 6. TTI 이벤트 기록
            await store.receive(.recordTTI("TicketList", "Showtickets"))


    }
    
}
