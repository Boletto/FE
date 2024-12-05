//
//  MyInvitedFeature.swift
//  Boleto
//
//  Created by Sunho on 9/12/24.
//

import ComposableArchitecture
@Reducer
struct MyInvitedFeature {
    
    @ObservableState
    struct State: Equatable {
        var  invitedTickets = [Ticket]()
        var invitedTravelID: Int?
        @Presents var alert: AlertState<Action.Alert>?
    }
    enum Action: Equatable {
        case alert(PresentationAction<Alert>)
        case fetchAllInvitedTickets
        case updateinvitedTickets([Ticket])
        case tapRefuseButton(Int)
        case tapAcceptButton(Int)
        case backbuttonTapped
        case showAcceptButton
        case initializeView
        @CasePathable
        enum Alert: Equatable {
            case refuseButtonTapped(Int)
            case acceptButtonTapped
        }
    }
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.travelClient) var travelClient
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .initializeView:
                return .run { [invitedTravelID = state.invitedTravelID] send in
                    await send(.fetchAllInvitedTickets)
                    
                    // 2. invitedTravelID 확인 후 showAcceptButton 실행
                    if invitedTravelID != nil {
                        await send(.showAcceptButton)
                    }
                }
            case .fetchAllInvitedTickets:
                return .run { send in
                    let tickets = try await travelClient.getAlltravel(false)
                    await send(.updateinvitedTickets(tickets))
                }
            case .updateinvitedTickets(let tickets):
                state.invitedTickets = tickets
                return .none
            case .alert(.presented(.acceptButtonTapped)):
                guard let travelId = state.invitedTravelID else { return .none }
                return .run { send in
                    try await travelClient.acceptTravel(travelId)
                    await send(.fetchAllInvitedTickets)
                }
                
            case .alert(.presented(.refuseButtonTapped(let travelId))):
                return .run { send in
                    try await travelClient.rejectTravel(travelId)
                    await send(.fetchAllInvitedTickets)
                }
            case .alert:
                return .none
            case .tapRefuseButton(let travelId):
                state.alert = AlertState {
                    TextState("초대를 거절하시겠어요?")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("취소")
                    }
                    ButtonState(action: .refuseButtonTapped(travelId)) {
                        TextState("거절")
                    }
                }message: {
                    TextState("거절한 티켓은 삭제되어 다시 볼 수 없어요.")
                }
                return .none
            case .tapAcceptButton(let travelId):
                state.invitedTravelID = travelId
                return .send(.showAcceptButton)
            case .showAcceptButton:
                state.alert = AlertState {
                    TextState("초대를 수락하시겠어요?")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("취소")
                    }
                    ButtonState(action: .acceptButtonTapped) {
                        TextState("수락")
                    }
                }message: {
                    TextState("수락한 티켓은 나의 여행에 자동으로 추가돼요.")
                }
                return .none
            case .backbuttonTapped:
                return .run { _ in await self.dismiss() }
            }}.ifLet(\.$alert, action: \.alert)
    }
}
