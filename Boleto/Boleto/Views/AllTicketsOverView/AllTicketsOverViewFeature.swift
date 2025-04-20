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
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case touchAddTravel
        case touchTicket(Ticket)
        case fetchTickets
        case updateTickets([Ticket])

        case confirmDeletion(Ticket)
        case deletionResponse(Bool)
        
        case alert(PresentationAction<Alert>)
        case sessionExpired
        
        case startMonitoirng(SpotType)
        case stopMonitoring
        
        @CasePathable
        enum Alert: Equatable {
            case confirmDeletion
            case deletionSuccess
            case deletionError
        }
    }
    @Dependency(\.locationClient) var locationClient
    @Dependency(\.travelClient) var travelClient
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .touchTicket(let ticket):
                print("찐 Ticket editableID: \(String(describing: ticket.editableID))")
                return .none
   
            case .fetchTickets:
                return .run { send in
                    do {
                        let data = try await travelClient.getAlltravel(true)
                        await send(.updateTickets(data))
                    } catch let error as CustomError {
                        switch error {
                        case .expiredRefreshToken:
                            await send(.sessionExpired)
                        default:
                            print(error.localizedDescription)
                            await send(.updateTickets([]))
                        }
                    }
                }
 
            case .updateTickets(let tickets):
                state.allTickets = tickets
                state.currentTicket =  tickets.first { $0.status == .ongoing }
                state.completedTickets = tickets.filter { $0.status == .completed }
                    .sorted { $0.endDate > $1.endDate }  // 최신순 정렬
                state.futureTickets = tickets.filter { $0.status == .future }
                    .sorted { $0.startDate < $1.startDate }  // 가까운 미래순 정렬
                if let currentticket = state.currentTicket {
                    return .run {send in
                        await send(.startMonitoirng(currentticket.arrival))
                    }
                }
                return .none
            case .touchAddTravel:
                return .none
            case .sessionExpired:
                return .none
            case .startMonitoirng:
                return .none
            case .stopMonitoring:
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
                
            case .alert(.presented(.confirmDeletion)):
                guard let ticketToDelete = state.selectedTicket else { return .none }
                return .run { [currentTicket = state.currentTicket] send in
                    let result = try await travelClient.deleteTravel(ticketToDelete.travelID)
                    if ticketToDelete == currentTicket {
                        await send(.stopMonitoring)
                    }
                    await send(.deletionResponse(result))
                }
            case .deletionResponse(let success):
                if success {
                    guard let ticketToDelete = state.selectedTicket else { return .none }
                    state.allTickets.removeAll {$0.travelID == ticketToDelete.travelID}
                    state.alert = AlertState {
                        TextState("삭제 성공")
                    } actions: {
                        ButtonState(action: .deletionSuccess) {
                            TextState("확인")
                        }
                    } message: {
                        TextState("여행이 성공적으로 삭제되었습니다.")
                    }
                    return .run { [tickts = state.allTickets]  send in
                        await send(.updateTickets(tickts))
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
            case .alert:
                state.alert = nil
                state.selectedTicket = nil
                return .none
            }
            
        }
        .ifLet(\.$alert, action: \.alert)
    }
}
