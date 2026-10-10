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
            case doErase
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

            case .tapLocationAuthor :
                return .run { send in
                    let currentStatus = await  locationclient.authorizationStatus()
                    if currentStatus == .notDetermined  || currentStatus == .restricted {
                       let _ = await self.locationclient.requestauthorziationStatus()
                    } else {
                         locationclient.disableLocationServices()
                    }
                }
            case .alert(.presented(.doLogOut)):
                return .run { send in
                     do {
                         // 로그아웃 API 호출
                         try await accountClient.postLogout()
                         print("Logout API 호출 성공")
                         await send(.goLoginView)
                     } catch {
                         // 에러 처리 (예: 로그 출력)
                         print("Logout API 호출 실패: \(error)")
                     }
                 }
            case .alert(.presented(.doErase)):
                return .run { send in
                    await send(.goLoginView)
                }
            
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
                    } catch {
                        
                    }
                }
                
            case .eraseMember:
                state.initLogin = true
                state.alert = AlertState {
                    TextState("탈퇴 완료")
                } actions: {
                    ButtonState(action: .doErase) {
                        TextState("확인")
                    }
                } message: {
                    TextState("로그인 화면으로 돌아갑니다.")
                }
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

           // 2. 제외할 키 정의
           let excludedKeys: Set<String> = ["name"]

           // 3. 제외할 키를 제외하고 삭제
           dictionary.keys.forEach { key in
               if !excludedKeys.contains(key) {
                   defaults.removeObject(forKey: key)
               }
           }

           // 4. 동기화
           defaults.synchronize()
      }
}
