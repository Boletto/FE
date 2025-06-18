//
//  PastTravelFeature.swift
//  Boleto
//
//  Created by Sunho on 9/5/24.
//
import SwiftUI
import ComposableArchitecture

@Reducer
struct AllTicketsOverViewFeature {
    @ObservableState
    struct State: Equatable {
        var currentTicket: Ticket?
        var allTickets = [Ticket]()
        var completedTickets = [Ticket]()
        var futureTickets = [Ticket]()
        var modalPosition: CGPoint = .zero
        var selectedTicket: Ticket?
        var isLoading = false
        @Presents var alert: AlertState<Action.Alert>?
    }
    enum Action: FeatureAction, BindableAction, Equatable  {
        case binding(BindingAction<State>)
        case user(UserAction)
        case external(ExternalAction)
        case inner(InnerAction)
        case delegate(DelegateAction)
        enum UserAction: Equatable {
            case touchAddTravel
            case touchTicket(Ticket)
            case confirmDeletion(Ticket)
            case onAppear
        }
        enum ExternalAction: Equatable {
            
            case ticketUpdated
            
            
        }
        
        enum InnerAction: Equatable {
            case fetchTickets
            case updateTickets([Ticket])
            case deletionResponse(Bool)
            case recordTTI(String, String)
            
        }
        enum DelegateAction: Equatable {
            case sessionExpired
            case startMonitoring(SpotType)
            case stopMonitoring
            case navigateToAddTicket
            case navigateToTicketDetail(Ticket)
        }
        
        
        case alert(PresentationAction<Alert>)
        
        @CasePathable
        enum Alert: Equatable {
            case confirmDeletion
            case deletionSuccess
            case deletionError
        }
    }
    @Dependency(\.travelClient) var travelClient
    @Dependency(\.ttiClient) var tticlient
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .user(.touchAddTravel):
                return .send(.delegate(.navigateToAddTicket))
            case .user(.touchTicket(let ticket)):
                return .send(.delegate(.navigateToTicketDetail(ticket)))
   
                
            case .alert(.dismiss):
                state.alert = nil
                state.selectedTicket = nil
                return .none
            case .user(.confirmDeletion(let ticket)):
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
            case .user(.onAppear) :
                
                return .send(.inner(.fetchTickets))
                
                
            case .inner(.fetchTickets):
                return handleFetchTickets(&state)
            case .inner(.updateTickets(let tickets)):
                return handleUpdateTickets(&state, tickets)
            case .inner(.recordTTI(let event, let detail)):
                return .run {send in
                    try await tticlient.postEvent(event, detail)
                }
            case .inner(.deletionResponse(let isSuccess)):
                
                return handleDeletionResponse(&state,isSuccess)
                
            case .external(.ticketUpdated):
                return .send(.inner(.fetchTickets))
                
                
                
            case .alert(.presented(.confirmDeletion)):
                return handleConfirmDeletionAlert(&state)
            case .alert:
                return .none
            default:
                return .none
                
            }
            
        }              .ifLet(\.$alert, action: \.alert)
    }
}
private extension AllTicketsOverViewFeature {
    func handleFetchTickets(_ state: inout State) -> Effect<Action> {
        state.isLoading = true
        return .run { send in
            do {
                let data = try await travelClient.getAlltravel(true)
                await send(.inner(.updateTickets(data)))
            } catch let error as CustomError {
                switch error {
                case .expiredRefreshToken:
                    await send(.delegate(.sessionExpired))
                default:
                    await send(.inner(.updateTickets([])))
                }
            }
        }
    }
    
    func handleUpdateTickets(_ state: inout State, _ tickets: [Ticket]) -> Effect<Action> {
        state.isLoading = false
        state.allTickets = tickets
        
        // 티켓 상태별로 분류 및 정렬
        state.completedTickets = tickets
            .filter { $0.status == .completed }
            .sorted { $0.endDate > $1.endDate }
        
        state.futureTickets = tickets
            .filter { $0.status == .future }
            .sorted { $0.startDate < $1.startDate }
        
        // 현재 진행중인 티켓이 있으면 모니터링 시작
        if let currentTicket = tickets.first(where: { $0.status == .ongoing }) {
            state.currentTicket = currentTicket
            return .concatenate(
                .send(.delegate(.startMonitoring(currentTicket.arrival))),
                .send(.inner(.recordTTI("TicketList", "ShowTickets")))
            )
        } else {
            state.currentTicket = nil
            return .concatenate(
                .send(.delegate(.stopMonitoring)),
                .send(.inner(.recordTTI("TicketList", "ShowTickets")))
            )
        }
    }
    
    func handleConfirmDeletionAlert(_ state: inout State) -> Effect<Action> {
        guard let ticketToDelete = state.selectedTicket else { return .none }
        
        return .run { [currentTicket = state.currentTicket] send in
            do {
                let result = try await travelClient.deleteTravel(ticketToDelete.travelID)
                
                // 현재 모니터링 중인 티켓이라면 모니터링 중지
                if ticketToDelete == currentTicket {
                    await send(.delegate(.stopMonitoring))
                }
                
                await send(.inner(.deletionResponse(result)))
            } catch {
                await send(.inner(.deletionResponse(false)))
            }
        }
    }
    
    func handleTicketUpdated(_ state: inout State, _ updatedTicket: Ticket) -> Effect<Action> {
        if let index = state.allTickets.firstIndex(where: { $0.travelID == updatedTicket.travelID }) {
            state.allTickets[index] = updatedTicket
            return .send(.inner(.updateTickets(state.allTickets)))
        }
        return .none
    }
    
    func handleDeletionResponse(_ state: inout State, _ success: Bool) -> Effect<Action> {
        if success {
            guard let ticketToDelete = state.selectedTicket else { return .none }
            state.allTickets.removeAll { $0.travelID == ticketToDelete.travelID }
            
            state.alert = AlertState {
                TextState("삭제 성공")
            } actions: {
                ButtonState(action: .deletionSuccess) {
                    TextState("확인")
                }
            } message: {
                TextState("여행이 성공적으로 삭제되었습니다.")
            }
            
            return .send(.inner(.fetchTickets))
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
            return .none
        }
    }
}
