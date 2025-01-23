//
//  AppFeature.swift
//  Boleto
//
//  Created by Sunho on 9/7/24.
//

import SwiftUI
import ComposableArchitecture
import CoreLocation
import UserNotifications
import AuthenticationServices
import Combine

@Reducer
struct AppFeature {
    @ObservableState
    struct State {
        var allTicketState: AllTicketsOverViewFeature.State = .init()
        var loginState: LoginFeature.State = .init()
        var profileState: MyProfileFeature.State = .init( mode: .add)
        var monitoringState: LocationMointoringFeature.State = .init()
        @Shared(.appStorage("isLogin")) var isLogin: Bool = false
        @Shared(.appStorage("currentSpotType")) var currentSpot: SpotType?
        var pendingInviteCode: String? = nil  // 임시 저장용 초대 코드
        var isNotificationEnabled = false
        var path =  StackState<Destination.State>()
        var showFriendModal: Bool = false
        var invitedFriendName: String?
        var invitedFriendCode: String?
        var userID: Int?
        @Presents var alert: AlertState<Action.Alert>?
        
        var viewstate: ViewState = .splash
        enum ViewState: Equatable {
            case splash
            case agreement
            case setProfile
            case loggedIn
            case loggedOut
            case tutorial
        }
        
        
    }
    @Reducer(state: .equatable)
    enum Destination {
        case pushSettingView(PushSettingFeature)
        case alarmsView(AlarmsFeature)
        case detailEditView(DetailTravelFeature)
        case addticket(AddTicketFeature)
        case myPage(MyPageFeature)
        case editProfile(MyProfileFeature)
        case mySticker(MyStickerFeature)
        case myPhotos(MyphotoFeature)
        case friendLists(FriendsFeature)
        case invitedTravel(MyInvitedFeature)
        case frameNotificationView(FrameNotificationFeature)
        case badgeNotificationView(BadgeNotificationFeature)
        case rewardView
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State> )
        case allTicket(AllTicketsOverViewFeature.Action)
        case login(LoginFeature.Action)
        case profile(MyProfileFeature.Action)
        case monitoring(LocationMointoringFeature.Action)
        
        case startMonitoring(SpotType)
        case stopMonitoring

        case fetchMyStickers
        case fetchMyFrames
        case fetchEventSticker
        case fetchEventFrame
        case setViewState(State.ViewState)
        
        case tabNotification
        case sendToFrameView(SpotType)
        case sendToBadgeView(StickerCodes)
        case sendToInvitedView(Int)
        case tabmyPage
        case path(StackActionOf<Destination>)
        case popAllPath
        case setPendingInviteCode(String)
        case alert(PresentationAction<Alert>)
        case showFriendAlert(String)
        case showAlert(String, Bool)
        case openFriendModal((String,String))
        case acceptFriend
        case rejectFriend
        case initialLogin
        case sessionExpired
        case updateEventType
        enum Alert: Equatable {
            case sessionExpired
        }
    }
    
    @Dependency(\.userClient) var userClient
    @Dependency(\.notificationClient) var notificationClient
    @Dependency(\.friendClient) var friendClient
    @Dependency(\.stickerDatabase) var stickerDBClient
    @Dependency(\.frameDBClient) var frameDBClient
    @Dependency(\.systemClient) var systemClient
    @Dependency(\.locationClient) var locationClient
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        pathReducer
        Scope(state: \.monitoringState, action: \.monitoring) {
            LocationMointoringFeature()
        }
        Scope(state: \.allTicketState , action: \.allTicket) {
            AllTicketsOverViewFeature()
        }
        Scope(state:\.loginState, action: \.login) {
            LoginFeature()
        }
        Scope(state: \.profileState, action: \.profile) {
            MyProfileFeature()
        }
        Reduce { state, action in
            switch action {
            case .alert(.presented(.sessionExpired)):
                state.isLogin = false
                return .send(.setViewState(.loggedOut))
            case .fetchMyStickers:
                return .run { send in
                    let myStickerImages = try await userClient.getStickers()
                    try await stickerDBClient.updateStickerDB(myStickerImages)
                }
            case .fetchMyFrames:
                return .run {send in
                    do {
                        let myFrames = try await userClient.getUserFrames()
                        try await frameDBClient.updateFrame(myFrames)
                        print("HI")
                    } catch {
                        print(error)
                    }
                }
            case .fetchEventSticker:
                return .run {send in
                    let eventstickers = try await systemClient.getAllSticker(true)
                    try await stickerDBClient.addInStickerDB(eventstickers)
                    for sticker in eventstickers {
                        let alreadyExists = try await stickerDBClient.hasStickers(sticker)
                           if !alreadyExists {
                               try await userClient.postStickerCode(sticker.stickerCode)
                           }
                       }
                    
                }
            case .fetchEventFrame:
                return .run { send in
                    let frames = try await systemClient.getEventFrames()
                    for frame in frames {
                        let alreadyExists = try await frameDBClient.hasFrame(frame)
                        if !alreadyExists {
                            try await userClient.postFrameCode(frame.frameCode)
                            try await frameDBClient.updateFrame([frame])
                        }
                    }
                }

                
            case .profile(.updateUserInfo):
                if state.profileState.mode == .add {
                    state.viewstate = .tutorial
                }
                return .none
            case .profile:
                return .none
            case .monitoring:
                return .none
            case let .setViewState(viewState):
                if let idString = KeyChainManager.shared.read(key: .userid), let id = Int(idString) {
                         state.userID = id
                     } else {
                         print("유저 ID를 가져올 수 없습니다.")
                     }
                state.viewstate = viewState
                return .none
    
            case .sendToBadgeView(let stickertype):
                
                state.path.append(.badgeNotificationView(BadgeNotificationFeature.State(badgeType: stickertype)))
                return .none
            case .sendToFrameView(let spot):
                state.path.append(.frameNotificationView(FrameNotificationFeature.State( badgeType: spot)))
                return .none
            case .sendToInvitedView(let travelId):
                state.path.append(.invitedTravel(MyInvitedFeature.State(invitedTravelID: travelId)))
                return .none
            case .allTicket(.touchAddTravel):
                state.path.append(.addticket(AddTicketFeature.State()))
                return .none
            case .allTicket(.startMonitoirng(let spottype)):
                return .run {send in
                    await send(.startMonitoring(spottype))
                }
            case .allTicket(.stopMonitoring):
                return .run { send in
                    await send(.stopMonitoring)
                }
            case .allTicket(.touchTicket(let ticket)):
                var editStatus: EditState
                if let editableID = ticket.editableID {
                    if editableID == state.userID {
                        editStatus = .lockedByMe
                    } else {
                        editStatus = .lockedByOthers
                    }
                } else {
                    editStatus = .unlocked
                }
                state.path.append(.detailEditView(DetailTravelFeature.State(ticket: ticket, editStatus: editStatus)))
                return .none
            case .allTicket(.sessionExpired):
                return .send(.sessionExpired)
            case .allTicket:
                return .none
            case .tabNotification:
                state.path.append(.alarmsView(AlarmsFeature.State()))
                return .none
            case .tabmyPage:
                state.path.append(.myPage(MyPageFeature.State()))
                return .none
                
            case .startMonitoring(let spot):
                return .run {send in
                    await send(.monitoring(.checkMonitoring(spot)))
                }
            case .stopMonitoring:
                return .run { send in
                    await send(.monitoring(.stopMonitoring))
                }
                
            case .login(.moveToAgreement):
                state.viewstate = .agreement
                return .none
            case .initialLogin:
                state.viewstate = .loggedIn
                state.isLogin = true
                state.path.append(.rewardView)
                if let idString = KeyChainManager.shared.read(key: .userid), let id = Int(idString) {
                         state.userID = id
                     } else {
                         print("유저 ID를 가져올 수 없습니다.")
                     }
                return .concatenate(
                    .run {send in
                        if let fcmToken = KeyChainManager.shared.read(key: .deviceToken) {
                            try await userClient.putFCMToken(fcmToken)
                        }
                            try await stickerDBClient.deleteAllStickers()
                            let stickers = try await systemClient.getAllSticker(false)
                            try await stickerDBClient.addInStickerDB(stickers)
                            await send(.fetchMyFrames)
                            await send(.fetchEventSticker)
                    },
                    .run {send in
                        await send(.fetchMyStickers)
                        await send(.fetchEventFrame)
                        _ = try await notificationClient.requestAuthorication()
                   
                    }
                )
            case .popAllPath:
                state.path.removeAll()
                return .none
            case .login(.loginSuccess):
                state.viewstate = .loggedIn
                if let idString = KeyChainManager.shared.read(key: .userid), let id = Int(idString) {
                         state.userID = id
                     } else {
                         print("유저 ID를 가져올 수 없습니다.")
                     }
                return .run {send in
                    let isFrameEmpty = try await frameDBClient.isEmpty()
                    let isStickerEmpty = try await stickerDBClient.isEmpty()
                    if isFrameEmpty || isStickerEmpty {
                        await send(.initialLogin)
                    } else {
                      if let fcmToken = KeyChainManager.shared.read(key: .deviceToken) {
                        try await userClient.putFCMToken(fcmToken)
                    }
                    }
                }
            case .login:
                return .none
            case .binding:
                return .none
            case .setPendingInviteCode(let code):
                state.pendingInviteCode = code
                return .none
            case .acceptFriend:
                return .run {[code = state.invitedFriendCode] send in
                    do{
                        guard let code = code else {return}
                        try await friendClient.postAddFriend(code)
                        await send(.showAlert("친구 추가가 완료되었습니다.",true))
                    } catch let error as CustomError {
                        if case let .badRequest(message, _) = error {
                            await send(.showAlert(message, false))
                        } else {
                            await send(.showAlert("알수없는 에러발생", false))
                        }
                    }
                }
            case .rejectFriend:
                state.invitedFriendCode = nil
                state.invitedFriendName = nil
                return .none
            case .alert:
                return .none
            case .showFriendAlert(let code):
                return .run { send in
                    do {
                        let name = try await friendClient.getInfoByCode(code)
                        await send(.openFriendModal((code, name)))
                    }catch let error as CustomError {
                        await send(.showAlert(error.message, false))
                        
                    }
                }
            case .openFriendModal((let code, let name)):
                state.invitedFriendCode = code
                state.invitedFriendName = name
                return .none
                
            case .showAlert(let message, let isSuccss):
                state.alert = AlertState {
                    TextState(isSuccss ? "성공" : "오류")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("확인")
                    }
                } message: {
                    TextState(message)
                }
                return .send(.rejectFriend)

                
            case .sessionExpired:
                state.alert = AlertState {
                    TextState("세션 만료")
                } actions: {
                    ButtonState(action: .sessionExpired) {
                        TextState("확인")
                    }
                } message: {
                    TextState("세션이 만료되었습니다. 다시 로그인해주세요.")
                }
                return .none
            default: return .none
            }
            
        }.forEach(\.path, action: \.path)
            .ifLet(\.$alert, action: \.alert)
        
    }
    private let pathReducer = Reduce<State, Action> { state, action in
          switch action {
          case let .path(pathAction):
              switch pathAction {
              case .element(id: _, action: .myPage(.friendListTapped)):
                  state.path.append(.friendLists(FriendsFeature.State()))
                  return .none
              case .element(id: _, action: .myPage(.profileTapped)):
                  state.path.append(.editProfile(MyProfileFeature.State(mode: .edit)))
                  return .none
              case .element(id: _, action: .myPage(.invitedTravelsTapped)):
                  state.path.append(.invitedTravel(MyInvitedFeature.State()))
                  return .none
              case .element(id: _, action: .myPage(.travelPhotosTapped)):
                  state.path.append(.myPhotos(MyphotoFeature.State()))
                  return .none
              case .element(id: _, action: .myPage(.stickersTapped)):
                  state.path.append(.mySticker(MyStickerFeature.State()))
                  return .none
              case .element(id: _, action: .myPage(.pushSettingTapped)):
                  state.path.append(.pushSettingView(PushSettingFeature.State()))
                  return .none
     
              case .element(id: _, action: .addticket(.tapbackButton)):
              let _ = state.path.popLast()
                  return .none
              case .element(id: let id, action: .detailEditView(.navigateToEditView)):
                  if case let .detailEditView(detailState) = state.path[id: id] {
                      state.path.append(.addticket(AddTicketFeature.State(mode: .edit(detailState.ticket))))
                  }
                  return .none
              case .element(id: _, action: .myPage(.goLoginView)):
                  KeyChainManager.shared.delete(key: .accessToken)
                  KeyChainManager.shared.delete(key: .refreshToken)
                  KeyChainManager.shared.delete(key: .userid)
                  state.viewstate = .loggedOut
                  state.isLogin = false
                  return .run {send in
                      send(.stopMonitoring)
                      send(.popAllPath)
                  }
              case .element(id: _, action: .alarmsView(.navigateToAlarmDestination(let alarmModel, let value))):
                  print("Received alarmModel: \(alarmModel)")
                  switch alarmModel {
                  case .sticker:
                      state.path.append(.badgeNotificationView(BadgeNotificationFeature.State(badgeType: StickerCodes.fromKoreanString(value) ?? .bs01)))
                  case .regionActive:
                      state.path.append(.frameNotificationView(FrameNotificationFeature.State(badgeType: SpotType.fromKoreanString(value) ?? .seoul )))
                  case .invitedTicket:
                      state.path.append(.invitedTravel(MyInvitedFeature.State(invitedTravelID: Int(value))))
                  case .travelTicket:
                      state.path.append(.invitedTravel(MyInvitedFeature.State(invitedTravelID: Int(value))))
                  case .friendAccept:
                      state.path.append(.friendLists(FriendsFeature.State()))
                  default:
                      print(alarmModel, value, "쉬쉬수싯")
                   break
                  }
                  return .none
              case .element(id: _, action: .addticket(.startMonitoring(let spot))):
                  return .send(.startMonitoring(spot))
              case .element(id: _, action: .friendLists(.alert(.presented(.sessionExpired)))):
                  return .send(.alert(.presented(.sessionExpired)))
              case .element(id: _, action: .detailEditView(.memoryFeature(.sessionExpired))):
                  return .send(.alert(.presented(.sessionExpired)))
              case .element(id: _, action: .invitedTravel(.alert(.presented(.sessionExpired)))):
                  return .send(.alert(.presented(.sessionExpired)))
                  
              default:
                  return .none
              }

          default:
              return .none
          }
      }
    
}
