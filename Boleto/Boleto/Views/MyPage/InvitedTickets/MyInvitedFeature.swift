//
//  MyInvitedFeature.swift
//  Boleto
//
//  Created by Sunho on 9/12/24.
//

import ComposableArchitecture
@Reducer
struct MyInvitedFeature {
    @Dependency(\.dismiss) var dismiss
    @ObservableState
    struct State: Equatable {
//        var  invitedTickets: [Ticket] = [Ticket(departaure: "Seoul", arrival: "Busan", startDate: "2019-03-13", endDate: "2023-04-15", participant: [Person(image: "beef3", name: "강병호"),Person(image: "beef1", name: "김수민"),Person(image: "beef2", name: "하잇"),Person(image: "beef4", name: "면답")], keywords: [.adventure]),
//                                         Ticket(departaure: "Jeju", arrival: "Seoul", startDate: "2024-10-2", endDate: "2025-11-2", participant: [Person(image: "beef3", name: "강병호"),Person(image: "beef1", name: "김수민"),Person(image: "beef2", name: "하잇"),Person(image: "beef4", name: "면답")], keywords: [.fandom]),
//                                         Ticket(departaure: "Busan", arrival: "Jeju", startDate: "2024-10-2", endDate: "2025-11-2", participant: [Person(image: "beef3", name: "강병호"),Person(image: "beef1", name: "김수민"),Person(image: "beef2", name: "하잇"),Person(image: "beef4", name: "면답")], keywords: [.adventure])]
        var  invitedTickets = [Ticket]()
        @Presents var alert: AlertState<Action.Alert>?
    }
    enum Action {
        case alert(PresentationAction<Alert>)
        case tapRefuseButton
        case tapAcceptButton
        case backbuttonTapped
        @CasePathable
        enum Alert {
            case refuseButtonTapped
            case acceptButtonTapped
        }
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .alert(.presented(.acceptButtonTapped)):
                print("HI")
                return .none
            case .alert:
                return .none
            case .tapRefuseButton:
                state.alert = AlertState {
                    TextState("초대를 거절하시겠어요?")
                } actions: {
                    ButtonState(role: .cancel) {
                          TextState("취소")
                        }
                    ButtonState(action: .acceptButtonTapped) {
                          TextState("거절")
                        }
                }message: {
                    TextState("거절한 티켓은 삭제되어 다시 볼 수 없어요.")
                }
                return .none
            case .tapAcceptButton:
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
