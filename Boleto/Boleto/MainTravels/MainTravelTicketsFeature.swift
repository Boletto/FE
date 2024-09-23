//
//  PastTravelFeature.swift
//  Boleto
//
//  Created by Sunho on 9/5/24.
//
import SwiftUI
import ComposableArchitecture

@Reducer
struct MainTravelTicketsFeature {
    @ObservableState
    struct State {
        var currentTicket: Ticket?
        var allTickets = [Ticket]()
        var ongoingTickets: [Ticket] = []
        var completedTickets: [Ticket] = []
        var futureTickets: [Ticket] = []
        var showingModal = false
        var modalPosition: CGPoint = .zero
        var selectedTicket: Ticket?
        var isLoading = false
        @Presents var alert: AlertState<Action.Alert>?
        mutating func classifyTickets() {
            ongoingTickets = allTickets.filter { $0.status == .ongoing }
            completedTickets = allTickets.filter { $0.status == .completed }
                .sorted { $0.endDate > $1.endDate }  // 최신순 정렬
            futureTickets = allTickets.filter { $0.status == .future }
                .sorted { $0.startDate < $1.startDate }  // 가까운 미래순 정렬
        }
    }
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case touchAddTravel
        case hideModal
        case touchTicket(Ticket)
        case fetchTickets
        case updateTickets([Ticket])
        case confirmDeletion(Ticket)
        case deleteTicket(Ticket)
        case deletionResponse(Bool)
        case alert(PresentationAction<Alert>)
        
        enum Alert: Equatable {
            case confirmDeletion
            case deletionSuccess
            case deletionError
        }
    }
    @Dependency(\.travelClient) var travelClient
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
                
            case .touchTicket(let _):
                return .none
            case .touchAddTravel:
                return .none
            case .hideModal:
                state.showingModal = false
                return .none
            case .binding:
                return .none
            case .fetchTickets:
                return .run { send in
                    let data = try await travelClient.getAlltravel()
                    await send(.updateTickets(data))
                }
            case .updateTickets(let tickets):
                state.allTickets = tickets
                state.classifyTickets()
                return .none
            case .confirmDeletion(let ticket):
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
                state.selectedTicket = ticket
                return .none
            case .deleteTicket(let ticket):
                state.allTickets.removeAll { $0.id == ticket.id }
                state.classifyTickets()
                // Here you would typically also call an API to delete the ticket on the server
                return .none
            case .alert(.presented(.confirmDeletion)):
                guard let ticketToDelete = state.selectedTicket else { return .none }
                return .run { send in
                    let result = try await travelClient.deleteTravel(ticketToDelete.travelID)
                    await send(.deletionResponse(result))
                    
                }
            case .deletionResponse(let success):
                if success {
                    guard let ticketToDelete = state.selectedTicket else { return .none }
                    state.allTickets.removeAll { $0.id == ticketToDelete.id }
                    state.classifyTickets()
                    state.alert = AlertState {
                        TextState("삭제 성공")
                    } actions: {
                        ButtonState(action: .deletionSuccess) {
                            TextState("확인")
                        }
                    } message: {
                        TextState("여행이 성공적으로 삭제되었습니다.")
                    }
                } else {
                    state.alert = AlertState {
                        TextState("삭제 실패")
                    } actions: {
                        ButtonState(action: .deletionError) {
                            TextState("확인")
                        }
                    } message: {
                        TextState("여행 삭제 중 오류가 발생했습니다. 다시 시도해 주세요.")
                    }
                }
                return .none
                
            case .alert(.presented(.deletionSuccess)) :
                return  .run { send in
                    await send(.fetchTickets)
                }
            case  .alert(.presented(.deletionError)):
                state.alert = nil
                state.selectedTicket = nil
                return .none
            case .alert(.dismiss):
                state.alert = nil
                state.selectedTicket = nil
                return .none
            }
            
        }
        .ifLet(\.$alert, action: \.alert)
    }
}
