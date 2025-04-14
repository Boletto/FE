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
        var isCapturing: Bool  = false
        @Presents var alert: AlertState<Action.Alert>?
        init(ticket: Ticket, editStatus: EditState) {
            self.ticket = ticket
            self.editStatus = editStatus
            self.memoryFeature = MemoryFeature.State(
                travelId: ticket.travelID,
                editStatus: editStatus,
                ticketfullurl: ticket.fullSizeURLString
            )
        }
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case alert(PresentationAction<Alert>)
        case memoryFeature(MemoryFeature.Action)
        case toggleParticipantModal
        case updateCurrentTab(TicketTab)
        case navigateToEditView
        case shareToInstagramStory(UIImage?)
        case fetchSingleTravel
        case updateTicket(Ticket)
        case showAlert(String)
        enum Alert: Equatable {
            case uninstallInstagram
        }
    }
    
    @Dependency(\.travelClient) var travelClient
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Scope(state: \.memoryFeature, action: \.memoryFeature) {
            MemoryFeature()
        }
        
        Reduce { state, action in
            switch action {
            case .alert:
                return .none
            case .fetchSingleTravel:
                return .run {[travelId = state.ticket.travelID] send in
                    let ticket = try await travelClient.getOneTravel(travelId)
                    await send(.updateTicket(ticket))
                }
            case .updateTicket(let ticket):
                //여기서 여행을 꺼주거나 켜야할꺼같음.
                state.ticket = ticket
                return .none
            case .binding:
                return .none
            case .memoryFeature:
                return .none
                
            case .toggleParticipantModal:
                state.isShowingParticipantModal.toggle()
                return .none
                
            case .updateCurrentTab(let tab):
                state.currentTab = tab
                return .none
                
            case .navigateToEditView:
                return .none
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
            case .shareToInstagramStory(let image):
                guard let image = image else {return .none}
                guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "INSTAGRAM_API_KEY") as?  String else {
                    fatalError("API_KEY not found in Info.plist")
                }
                guard let instaurl = URL(string: "instagram-stories://share?source_application=\(apiKey)") else {
                    return .send(.showAlert("인스타그램을 다운 후 사용할 수 있는 기능입니다."))
                }
                guard let imageData = image.jpegData(compressionQuality: 0.8) else {return .none}
                let pasteBoardItems = ["com.instagram.sharedSticker.backgroundImage": imageData]
                UIPasteboard.general.setItems([pasteBoardItems])
                if UIApplication.shared.canOpenURL(instaurl) {
                    UIApplication.shared.open(instaurl)
                } else {
                    return .send(.showAlert("인스타그램을 다운 후 사용할 수 있는 기능입니다."))
                }
                state.isCapturing = false
                return .none
        
            }
        }
        .ifLet(\.$alert, action: \.alert)
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
