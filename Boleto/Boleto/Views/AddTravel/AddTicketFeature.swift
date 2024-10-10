//
//  AddTicketFeature.swift
//  Boleto
//
//  Created by Sunho on 8/31/24.
//

import ComposableArchitecture
import SwiftUI
@Reducer
struct AddTicketFeature {
    @Reducer(state: .equatable)
    enum BottomSheetState{
        case departureSelection(SpotSelectionFeature)
        case traveTypeSeleciton(KeywordSelectionFeature)
        case dateSelection(DateSelectionFeature)
        case friendSelection(FriendSelectionFeature)
    }
    enum Mode: Equatable {
        case add
        case edit(Ticket)
    }
    @ObservableState
    struct State: Equatable {
        @Presents var bottomSheet: BottomSheetState.State?
        var mode: Mode
        var startDate: Date?
        var endDate: Date?
        var keywords: [Keywords]?
        var departureSpot: Spot?
        var arrivialSpot: Spot?
        var friends: [FriendDummy]?
        var isDateSheetPresented = false
        var travelID:Int?
        var color: TicketColor?
        var isFormComplete: Bool {
            startDate != nil && arrivialSpot != nil
        }
        init(mode: Mode = .add) {
            self.mode = mode
            switch mode {
            case .add:
                break
            case .edit(let ticket):
                self.departureSpot = ticket.departaure
                self.arrivialSpot = ticket.arrival
                self.startDate = ticket.startDate
                self.endDate = ticket.endDate
                self.keywords = ticket.keywords
                self.friends = ticket.participant
                self.travelID = ticket.travelID
                self.color = ticket.color
            }
        }
    }
    
    enum Action {
        case bottomSheet(PresentationAction<BottomSheetState.Action>)
        case showDepartuare
        case showDateSelection
        case showkeywords
        case showfriends
        case tapbackButton
        case tapmakeTicket
        case successTicket
        case failureTicket(String)
    }
    
    @Dependency(\.travelClient) var travelClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .bottomSheet(.presented(.departureSelection(.sendSpots))):
                state.departureSpot = state.bottomSheet?.departureSelection?.selectedDeparture
                state.arrivialSpot = state.bottomSheet?.departureSelection?.selectedArrival
                state.bottomSheet = nil
                return .none
            case .bottomSheet(.presented(.traveTypeSeleciton(.tapSubmit))):
                state.keywords = state.bottomSheet?.traveTypeSeleciton?.selectedKeywords
                state.bottomSheet = nil
                return .none
            case .bottomSheet(.presented(.friendSelection(.sendFriendId))):
                state.friends = state.bottomSheet?.friendSelection?.selectedFriends
                state.bottomSheet = nil
                return .none
            case .bottomSheet(.presented(.dateSelection(.sendDate))):
                state.startDate = state.bottomSheet?.dateSelection?.startDate
                state.endDate = state.bottomSheet?.dateSelection?.endDate
                state.bottomSheet = nil
                return .none
            case .showDepartuare:
                state.bottomSheet = .departureSelection(SpotSelectionFeature.State())
                return .none
            case .showDateSelection:
                state.bottomSheet = .dateSelection(DateSelectionFeature.State())
                return .none
            case .showkeywords:
                state.bottomSheet = .traveTypeSeleciton(KeywordSelectionFeature.State())
                return .none
            case .showfriends:
                state.bottomSheet = .friendSelection(FriendSelectionFeature.State(selectedFriends: state.friends ?? []))
                return .none
            case .bottomSheet:
                return .none
            case .tapbackButton:
                return .none
            case .tapmakeTicket:
                
                guard let departureSpot = state.departureSpot?.rawValue,
                      let arrivalSpot = state.arrivialSpot?.rawValue, let keywords = state.keywords else {
                    return .send(.failureTicket("출발지와 도착지를 선택해주세요."))
                }
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                
                let startDateString = state.startDate.map { dateFormatter.string(from: $0) } ?? "2024-09-09 10:30:00"
                let endDateString = state.endDate.map { dateFormatter.string(from: $0) } ?? "2024-09-09 10:40:00"
                let travelId = state.travelID
                let friendsId = state.friends?.compactMap({ Int($0.id)}).sorted(by: >)
                let ticketColor = state.color
                let mode = state.mode
                return .run {send in
                    if mode == .add {
                        let request = TravelRequest(
                            departure: departureSpot,
                            arrive: arrivalSpot,
                            keyword: keywords.map { $0.koreanString }.joined(separator: ", "),
                            startDate: startDateString,
                            endDate: endDateString,
                            members: friendsId ?? [],
                            color: TicketColor.random().rawValue
                        )
                        do {
                            let result = try await travelClient.postTravel(request)
                            if result {
                                await send(.successTicket)
                            } else {
                                await send(.failureTicket("티켓 생성에 실패했습니다."))
                            }
                        } catch {
                            await send(.failureTicket("오류 발생: \(error.localizedDescription)"))
                        }
                    } else {
                        let request = TravelFetchRequest( departure: departureSpot,
                                                          arrive: arrivalSpot,
                                                          keyword: keywords.map { $0.koreanString }.joined(separator: ", "),
                                                          startDate: startDateString,
                                                          endDate: endDateString,
                                                          members: friendsId ?? [],
                                                          color: mode == .add ? TicketColor.random().rawValue : ticketColor!.rawValue, travelId: travelId!)
                        do {
                            let result = try await travelClient.patchTravel(request)
                            if result {
                                await send(.successTicket)
                            } else {
                                await send(.failureTicket("티켓 생성에 실패했습니다."))
                            }
                        } catch {
                            await send(.failureTicket("오류 발생: \(error.localizedDescription)"))
                        }
                    }
                }
            case .successTicket :
                return .none
            case .failureTicket(let message):
                return .none
            }
        }
        .ifLet(\.$bottomSheet, action: \.bottomSheet)
    }
}
