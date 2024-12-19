//
//  MyPageFeature.swift
//  Boleto
//
//  Created by Sunho on 9/11/24.
//

import Foundation
import ComposableArchitecture
import SwiftUI
@Reducer
struct MyPageFeature {
    
    @ObservableState
    struct State: Equatable {
        @Shared(.appStorage("AlertOn")) var alertOn: Bool = false
        @Shared(.appStorage("name")) var name = ""
        @Shared(.appStorage("nickname")) var nickname = ""
        @Shared(.appStorage("profile")) var profile = ""
        @Shared(.appStorage("initialLogin")) var initLogin: Bool = true

        var notiAlert: Bool = false
        var showOutMember = false
        var outMemberState =  OutMemberFeature.State()
        @Presents var alert: AlertState<Action.Alert>?

   
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case alert(PresentationAction<Alert>)
        case outMemberAction(OutMemberFeature.Action)
        case profileTapped
        case travelPhotosTapped
        case stickersTapped
        case pushSettingTapped
        case friendListTapped
        case invitedTravelsTapped
        case logoutTapped
        case goLoginView
        case tapbackButton
        case toggleOutMemberView
        case tapLocationAuthor
        case tapNotiManage
        case eraseMember
        
        enum Alert {
            case doLogOut
  
        }
    }
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.locationClient) var locationclient
    @Dependency(\.frameDBClient) var dbclient
    @Dependency(\.stickerDatabase) var stickerDatabase
    @Dependency(\.accountClient) var accountClient
    @Dependency(\.userClient) var userClient
    var body: some ReducerOf<Self> {
        BindingReducer()
        Scope(state:\.outMemberState, action: \.outMemberAction) {
            OutMemberFeature()
        }
        Reduce { state, action in
            switch action {
            case .binding(\.notiAlert):
                state.alertOn = state.notiAlert
                return .none
            case .tapLocationAuthor :
                return .run { send in
                    let currentStatus = await  locationclient.authorizationStatus()
                    if currentStatus == .notDetermined  || currentStatus == .restricted {
                       let _ = await self.locationclient.requestauthorzizationStatus()
                    } else {
                         locationclient.disableLocationServices()
                    }
                }
            case .alert(.presented(.doLogOut)):
                return .run {send in
                    do  {
                         try await accountClient.postLogout()
                     
                            await send(.goLoginView)
                        
                    } catch {
                        
                    }}
            
            case .toggleOutMemberView:
                state.showOutMember.toggle()
                return .none
      
            case .tapbackButton:
                return .run { _ in await self.dismiss() }
 
            case .logoutTapped:
                state.alert = AlertState {
                    TextState("정말 로그아웃하시겠어요?")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("취소")
                    }
                    ButtonState(action: .doLogOut) {
                        TextState("로그아웃")
                    }
                }
                return .none
   
            case .outMemberAction(.alert(.presented(.doEraseMember))):
                return .run { send in
                    do  {
                        try await userClient.deleteUser()
                            dbclient.deleteAllFrames()
                        try await stickerDatabase.deleteAllStickers()
                            clearAllSharedState()
                        await send(.eraseMember)
                            await send(.goLoginView)
                    } catch {
                        
                    }
                    
                }
            case .eraseMember:
                state.initLogin = true
                return .none
            case .tapNotiManage:
                guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return  .none}
                   if UIApplication.shared.canOpenURL(settingsURL) {
                       UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                   }
                return .none
           
            default:
                return .none
            }
        }.ifLet(\.$alert, action: \.alert)
    }
    private func clearAllSharedState() {
          // 1. UserDefaults 초기화
          let defaults = UserDefaults.standard
          let dictionary = defaults.dictionaryRepresentation()
          dictionary.keys.forEach { key in
              defaults.removeObject(forKey: key)
          }
          defaults.synchronize()
          
          // 2. FileManager를 사용하여 저장된 파일 삭제
          if let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
              do {
                  let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsPath,
                                                                            includingPropertiesForKeys: nil)
                  for fileURL in fileURLs {
                      try FileManager.default.removeItem(at: fileURL)
                  }
              } catch {
                  print("Error clearing documents directory: \(error)")
              }
          }
      }
}
