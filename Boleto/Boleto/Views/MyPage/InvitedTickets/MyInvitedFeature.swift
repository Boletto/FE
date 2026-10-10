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
        case showSessionExpiredAlert
        case showAlert(String)
        @CasePathable
        enum Alert: Equatable {
            case refuseButtonTapped(Int)
            case acceptButtonTapped
            case sessionExpired
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
                    if invitedTravelID != nil {
                        await send(.showAcceptButton)
                    }
                }
            case .fetchAllInvitedTickets:
                return .run { send in
                    do {
                        let tickets = try await travelClient.getAlltravel(false)
                        await send(.updateinvitedTickets(tickets))
                    } catch let error as CustomError {
                            // 에러 처리: 필요 시 에러를 디스패치하거나 로깅
                            switch error {
                            case .expiredRefreshToken:
                                await send(.showSessionExpiredAlert)
                            default:
                                await send(.showAlert(error.message))
                            }
                    }
                    

                }
            case .showAlert(let message):
                state.alert = AlertState {
                    TextState("오류")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("확인")
                    }
                } message: {
                    TextState(message)
                }
                return .none
            case .showSessionExpiredAlert:
                state.alert = AlertState {
                    TextState("오류")
                } actions: {
                    ButtonState(action: .sessionExpired) {
                        TextState("확인")
                    }
                } message: {
                    TextState("세션이 만료되었습니다. 다시 로그인해주세요")
                }
                return .none
            case .updateinvitedTickets(let tickets):
                state.invitedTickets = tickets
                return .none
            case .alert(.presented(.acceptButtonTapped)):
                guard let travelId = state.invitedTravelID else { return .none }
                return .run { send in
                    do{
                        try await travelClient.acceptTravel(travelId)
                        await send(.fetchAllInvitedTickets)
                    } catch let error as CustomError{
                        if case let .badRequest(message, _) = error {
                            await send(.showAlert(message))
                        } else {
                            await send(.showAlert(error.message))
                        }
                    }
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
