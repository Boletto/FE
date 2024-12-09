import ComposableArchitecture
import SwiftUI

@Reducer
struct DetailTravelFeature {
    @ObservableState
    struct State: Equatable {
        var ticket: Ticket
        var currentTab: TicketTab = .ticket
        var memoryFeature: MemoryFeature.State
        var isShowingParticipantModal = false
        
        init(ticket: Ticket, myID: Int) {
            self.ticket = ticket
            self.memoryFeature = MemoryFeature.State(
                travelId: ticket.travelID,
                ticketColor: ticket.color,
                lastEditIsMe: ticket.editableID == myID
            )
        }
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case memoryFeature(MemoryFeature.Action)
        case toggleParticipantModal
        case updateCurrentTab(TicketTab)
        case navigateToEditView
    }
    
    @Dependency(\.travelClient) var travelClient
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Scope(state: \.memoryFeature, action: \.memoryFeature) {
            MemoryFeature()
        }
        
        Reduce { state, action in
            switch action {
            case .binding:

                return .none
                
            case .memoryFeature:
                // Delegate memory-related actions to MemoryFeature
                return .none
                
            case .toggleParticipantModal:
                // Toggle participant modal visibility
                state.isShowingParticipantModal.toggle()
                return .none
                
            case .updateCurrentTab(let tab):
                // Update the current tab
                state.currentTab = tab
                return .none
                
            case .navigateToEditView:
                // Navigate to edit view (future navigation logic can go here)
                return .none
            }
        }
    }
}

// MARK: - TicketTab Enum
enum TicketTab: Int, CaseIterable {
    case ticket = 0
    case memory = 1
    
    var title: String {
        switch self {
        case .ticket: return "티켓"
        case .memory: return "추억"
        }
    }
}
