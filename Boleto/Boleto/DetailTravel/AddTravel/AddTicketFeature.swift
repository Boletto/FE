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
    @Dependency(\.dismiss) var dismiss
//    @Dependency(
    @Reducer(state: .equatable)
    enum BottomSheetState{
        case departureSelection(SpotSelectionFeature)
        case traveTypeSeleciton(KeywordSelectionFeature)
        case dateSelection(DateSelectionFeature)
    }
    @ObservableState
    struct State: Equatable {
        @Presents var bottomSheet: BottomSheetState.State? 
        var startDate: Date?
        var endDate: Date?
        var keywords: [String]?
        var departureSpot: Spot?
        var arrivialSpot: Spot?
        var isDateSheetPresented = false
        var isFormComplete: Bool {
            startDate != nil && arrivialSpot != nil
        }
        
    }
    enum Action {
        case bottomSheet(PresentationAction<BottomSheetState.Action>)
        case showDepartuare
        case showDateSelection
        case showkeywords
        case tapbackButton
        case tapmakeTicket
//        case dateSelection(start: String, end: String)

    }
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
            case .bottomSheet:
                return .none
            case .tapbackButton:
                return .none
//                return .run {send in
//                    await self.dismiss()}
            case .tapmakeTicket:
                return .none
            }
        }
        .ifLet(\.$bottomSheet, action: \.bottomSheet)
    }
}
