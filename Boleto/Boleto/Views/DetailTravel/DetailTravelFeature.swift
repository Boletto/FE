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
        var editStatus: EditState
        var capturedImage: UIImage?
        init(ticket: Ticket, editStatus: EditState) {
            self.ticket = ticket
            self.editStatus = editStatus
            self.memoryFeature = MemoryFeature.State(
                travelId: ticket.travelID,
                editStatus: editStatus,
                ticketfullurl: ticket.fullSizeURL
            )
        }
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case memoryFeature(MemoryFeature.Action)
        case toggleParticipantModal
        case updateCurrentTab(TicketTab)
        case navigateToEditView
        case shareToInstagramStory(UIImage?)
        
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

            case .shareToInstagramStory(let image):
                guard let image = image else {return .none}
                guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "INSTAGRAM_API_KEY") as?  String else {
                    fatalError("API_KEY not found in Info.plist")
                }
                guard let instaurl = URL(string: "instagram-stories://share?source_application=\(apiKey)") else {
                    print("인스타 다운 안되어있는뎅?")
                    return .none
                }
                guard let imageData = image.jpegData(compressionQuality: 0.8) else {return .none}
                let pasteBoardItems = ["com.instagram.sharedSticker.backgroundImage": imageData]
                UIPasteboard.general.setItems([pasteBoardItems])
                if UIApplication.shared.canOpenURL(instaurl) {
                    UIApplication.shared.open(instaurl)
                }
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
