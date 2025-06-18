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
    enum BottomSheetState {
        case departureSelection(SpotSelectionFeature)
        case traveTypeSeleciton(KeywordSelectionFeature)
        case dateSelection(DateSelectionFeature)
        case friendSelection(FriendsFeature)
        
        
        enum Action: Equatable {
            case departureSelection(SpotSelectionFeature.Action)
            case traveTypeSeleciton(KeywordSelectionFeature.Action)
            case dateSelection(DateSelectionFeature.Action)
            case friendSelection(FriendsFeature.Action)
        }
    }
    enum Mode: Equatable {
        case add
        case edit(Ticket)
    }
    @ObservableState
    struct State: Equatable {
        @Presents var bottomSheet: BottomSheetState.State?
        @Presents var alert: AlertState<Action.Alert>?
        var mode: Mode
        var startDate: Date?
        var endDate: Date?
        var keywords: [Keywords]?
        var departureSpot: SpotType?
        var arrivialSpot: SpotType?
        var friends: [MemberModel]?
        var isDateSheetPresented = false
        var travelID:Int?
        var isMonitoring: Bool = false
        
        var isFormComplete: Bool {
            startDate != nil && arrivialSpot != nil  && keywords != nil
        }
        
        init(mode: Mode = .add,friends: [MemberModel]? = nil) {
            self.mode = mode
            self.friends = friends
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
                self.isMonitoring = Date.isTraveling(startDate: ticket.startDate, endDate: ticket.endDate)
            }
        }
    }
    
    enum Action: FeatureAction, Equatable {
        case bottomSheet(PresentationAction<BottomSheetState.Action>)
        case alert(PresentationAction<Alert>)
     
        
        case user(UserAction)
        case external(ExternalAction)
        case inner(InnerAction)
        case delegate(DelegateAction)
        enum Alert: Equatable {
            
        }
        enum UserAction: Equatable {
            case showDepartuare
            case showDateSelection
            case showkeywords
            case showfriends
            case tapbackButton
            case tapmakeTicket
            
        }
        enum ExternalAction: Equatable {
           
        }
        enum InnerAction: Equatable {
            case successTicket
            case failureTicket(String)
        }
        enum DelegateAction: Equatable {
            case startMonitoring(SpotType)
            case dismissView
        }
    }
    
    @Dependency(\.travelClient) var travelClient
    @Dependency(\.locationClient) var locationClient
    @Dependency(\.dismiss) var dismiss
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
            case .bottomSheet(.presented(.friendSelection(.finishSelectFriend))):
                state.friends = state.bottomSheet?.friendSelection?.selectedFriends
                state.bottomSheet = nil
                return .none
            case .bottomSheet(.presented(.dateSelection(.sendDate))):
                state.startDate = state.bottomSheet?.dateSelection?.startDate
                state.endDate = state.bottomSheet?.dateSelection?.endDate ?? state.startDate
                state.bottomSheet = nil
                return .none
            case .bottomSheet:
                return .none
            case .user(.showDepartuare):
                state.bottomSheet = .departureSelection(SpotSelectionFeature.State())
                return .none
                
            case .user(.showDateSelection):
                state.bottomSheet = .dateSelection(DateSelectionFeature.State())
                return .none
                
            case .user(.showkeywords):
                state.bottomSheet = .traveTypeSeleciton(KeywordSelectionFeature.State())
                return .none
            case .user(.tapbackButton):
                return .none
                
                
            case .user(.showfriends):
                   return handleShowFriends(&state)
            case .user(.tapmakeTicket):
                return handleMakeTicket(&state)

            case .inner(.successTicket):
                guard let startDate = state.startDate,
                      let endDate = state.endDate,
                      let arrivalSpot = state.arrivialSpot else {
                    return .none
                }
                
                switch state.mode {
                case .add:
                    return .send(.delegate(.dismissView))
                    
                case .edit:
                    return handleEditModeSuccess(&state, startDate: startDate, endDate: endDate, arrivalSpot: arrivalSpot)
                }
          
            case .inner(.failureTicket(let message)):
                return handleFailureTicket(&state, message)

            case .alert:
                return .none
                
            case .external, .delegate:
                return .none
                
                                

            }
        }
        .ifLet(\.$bottomSheet, action: \.bottomSheet)
        .ifLet(\.$alert, action: \.alert)
    }
}
private extension AddTicketFeature {
    func handleShowFriends(_ state: inout State) -> Effect<Action> {
           let userid = KeyChainManager.shared.read(key: .userid).map { Int($0) }
           let friends = state.friends?.filter { $0.id != userid }
           state.bottomSheet = .friendSelection(
               FriendsFeature.State(
                   friends: friends ?? [],
                   selectedFriends: friends ?? []
               )
           )
           return .none
       }
       
    
    func handleMakeTicket(_ state: inout State) -> Effect<Action> {
        guard let departureSpot = state.departureSpot?.spot.upperString,
              let arrivalSpot = state.arrivialSpot?.spot.upperString,
              let keywords = state.keywords else {
            return .send(.inner(.failureTicket("출발지와 도착지를 선택해주세요.")))
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let startDateString = state.startDate.map { dateFormatter.string(from: $0) } ?? "2024-09-09"
        let endDateString = state.endDate.map { dateFormatter.string(from: $0) } ?? "2024-09-09"
        
        let friendsId = state.friends?.compactMap { Int($0.id) }.sorted(by: >)
        let keywordString = keywords.map { $0.koreanString }.joined(separator: ", ")
        
        switch state.mode {
        case .add:
            return createNewTicket(
                departure: departureSpot,
                arrival: arrivalSpot,
                keyword: keywordString,
                startDate: startDateString,
                endDate: endDateString,
                members: friendsId ?? []
            )
            
        case .edit:
            guard let travelId = state.travelID else {
                return .send(.inner(.failureTicket("여행 ID가 없습니다.")))
            }
            return updateExistingTicket(
                travelId: travelId,
                departure: departureSpot,
                arrival: arrivalSpot,
                keyword: keywordString,
                startDate: startDateString,
                endDate: endDateString,
                members: friendsId ?? []
            )
        }
    }
    func createNewTicket(
        departure: String,
        arrival: String,
        keyword: String,
        startDate: String,
        endDate: String,
        members: [Int]
    ) -> Effect<Action> {
        let request = TravelRequest(
            departure: departure,
            arrive: arrival,
            keyword: keyword,
            startDate: startDate,
            endDate: endDate,
            members: members
        )
        
        return .run { send in
            do {
                try await travelClient.postTravel(request)
                await send(.inner(.successTicket))
            } catch let error as CustomError {
                await send(.inner(.failureTicket(error.message)))
            } catch {
                await send(.inner(.failureTicket("알 수 없는 오류가 발생했습니다.")))
            }
        }
    }
    

    func updateExistingTicket(
        travelId: Int,
        departure: String,
        arrival: String,
        keyword: String,
        startDate: String,
        endDate: String,
        members: [Int]
    ) -> Effect<Action> {
        let request = TravelFetchRequest(
            departure: departure,
            arrive: arrival,
            keyword: keyword,
            startDate: startDate,
            endDate: endDate,
            members: members
        )
        
        return .run { send in
            do {
                let result = try await travelClient.patchTravel(request, travelId)
                if result {
                    await send(.inner(.successTicket))
                } else {
                    await send(.inner(.failureTicket("티켓 생성에 실패했습니다.")))
                }
            } catch {
                await send(.inner(.failureTicket("오류 발생: \(error.localizedDescription)")))
            }
        }
    }

    func handleEditModeSuccess(
        _ state: inout State,
        startDate: Date,
        endDate: Date,
        arrivalSpot: SpotType
    ) -> Effect<Action> {
        let isTraveling = Date.isTraveling(startDate: startDate, endDate: endDate)
        
        if isTraveling {
            return .concatenate(
                .send(.delegate(.startMonitoring(arrivalSpot))),
                .send(.delegate(.dismissView))
            )
        } else if state.isMonitoring {
            return .run { send in
                await locationClient.stopMonitoring()
                await send(.delegate(.dismissView))
            }
        } else {
            return .send(.delegate(.dismissView))
        }
    }
    func handleFailureTicket(_ state: inout State, _ message: String) -> Effect<Action> {
        state.alert = AlertState {
            TextState("에러")
        } actions: {
            ButtonState(role: .cancel) {
                TextState("확인")
            }
        } message: {
            TextState(message)
        }
        return .none
    }
    func handleBottomSheetActions(_ state: inout State, _ action: BottomSheetState.Action) -> Effect<Action> {
        switch action {
        case .departureSelection(.sendSpots):
            state.departureSpot = state.bottomSheet?.departureSelection?.selectedDeparture
            state.arrivialSpot = state.bottomSheet?.departureSelection?.selectedArrival
            state.bottomSheet = nil
            return .none
            
        case .traveTypeSeleciton(.tapSubmit):
            state.keywords = state.bottomSheet?.traveTypeSeleciton?.selectedKeywords
            state.bottomSheet = nil
            return .none
            
        case .friendSelection(.finishSelectFriend):
            state.friends = state.bottomSheet?.friendSelection?.selectedFriends
            state.bottomSheet = nil
            return .none
            
        case .dateSelection(.sendDate):
            state.startDate = state.bottomSheet?.dateSelection?.startDate
            state.endDate = state.bottomSheet?.dateSelection?.endDate ?? state.startDate
            state.bottomSheet = nil
            return .none
            
        default:
            return .none
        }
    }
}
