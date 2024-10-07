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
        @Shared(.appStorage("LocationOn")) var locationOn: Bool  = false
        @Shared(.appStorage("name")) var name = ""
        @Shared(.appStorage("nickname")) var nickname = ""
        @Shared(.appStorage("profile")) var profile = ""
        var notiAlert: Bool = false
        var locationAlert: Bool = false
        var showOutMember = false
        var outMemberState =  OutMemberFeature.State()
        @Presents var alert: AlertState<Action.Alert>?
//        var path =  StackState<Destination.State>()

        init() {
            self.notiAlert = alertOn
            self.locationAlert = locationOn
        }
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
        case eraseEveryUserDefault
        enum Alert {
            case doLogOut
  
        }
    }
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.locationClient) var locationclient
    @Dependency(\.frameDBClient) var dbclient
    @Dependency(\.accountClient) var accountClient
    var body: some ReducerOf<Self> {
        BindingReducer()
        Scope(state:\.outMemberState, action: \.outMemberAction) {
            OutMemberFeature()
        }
        Reduce { state, action in
            switch action {
            case .binding(\.notiAlert):
                state.alertOn = state.notiAlert
                return .run { [alertOn = state.notiAlert] send in
                    if alertOn {
                        try await self.locationclient.requestNotiAuthorization()
                    } else {
                        await self.locationclient.removeAllScheduledNotifications()
                    }
                }
            case .binding(\.locationAlert) :
                state.locationOn = state.locationAlert
                return .run {[locationOn = state.locationAlert] send in
                    if locationOn {
                        let _ = await self.locationclient.requestauthorzizationStatus()
                    } else {
                        
                    }
                }
            case .alert(.presented(.doLogOut)):
                return .run {send in
                    do  {
                        let result = try await accountClient.postLogout()
                        if result {
                            await send(.goLoginView)
                        }
                    } catch {
                        
                    }}
            
            case .toggleOutMemberView:
                state.showOutMember.toggle()
                return .none
            case .goLoginView:
//                state.userid
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
            case .eraseEveryUserDefault:
                state.name = ""
                state.profile = ""
                state.nickname = ""
                return .none
            case .outMemberAction(.alert(.presented(.doEraseMember))):
                return .run { send in
                    do  {
                        let result = try await accountClient.deleteMemeber()
                        if result {
//                            KeyChainManager.shared.deleteAll()
                            dbclient.deleteAllFrames()
                            clearAllSharedState()
                            await send(.eraseEveryUserDefault)
                            await send(.goLoginView)
                        }
                    } catch {
                        
                    }
                    
                }
           
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
          
          // 3. KeyChain 데이터 삭제
          let secItemClasses = [
              kSecClassGenericPassword,
              kSecClassInternetPassword,
              kSecClassCertificate,
              kSecClassKey,
              kSecClassIdentity
          ]
          for itemClass in secItemClasses {
              SecItemDelete([kSecClass as String: itemClass] as CFDictionary)
          }
      }
}
