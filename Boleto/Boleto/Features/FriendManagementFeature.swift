//
//  FriendManagementFeature.swift
//  Boleto
//
//  Created by Sunho on 2/27/25.
//

import ComposableArchitecture
@Reducer
struct FriendManagementFeature {
    @ObservableState
    struct State {
        var pendingInviteCode: String?
        var invitedFriendName: String?
        var invitedFriendCode: String?
    }
    
   
    
    enum Action: FeatureAction {
        case user(UserAction)
        case external(ExternalAction)
        case inner(InnerAction)
        case delegate(DelegateAction)
        enum UserAction {
         
            case setPendingInviteCode(String)
            case acceptFriend
            case rejectFriend
        }
        enum ExternalAction {
          
        }
        enum InnerAction {
            case checkPendingInviteCode
            case showFriendAlert(String)
            case updateFriendInfo(String, String)
            case showAlert(String, Bool)
            case fetchFriendInfo(String)
        }
        enum DelegateAction {
            
        }
    }
    
    @Dependency(\.friendClient) var friendClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .user(.setPendingInviteCode(let code)):
                state.pendingInviteCode = code
                return .none
            case .inner(.checkPendingInviteCode):
                if let code = state.pendingInviteCode {
                    return .send(.inner(.showFriendAlert(code)))
                }
                return .none
            case .inner(.fetchFriendInfo(let code)):
                return .run {send in
                    do {
                        let name = try await friendClient.getInfoByCode(code)
                        await send(.inner(.updateFriendInfo(code, name)))
                    } catch let error as CustomError{
                        switch error {
                        case .expiredRefreshToken:
                            await send(.inner(.showAlert("토큰이 만료되었어요", false)))
                        case .notFound(let message):
                            await send(.inner(.showAlert(message, false)))
                        default:
                            print(error.localizedDescription)
                        }
                    }
                }
            case .inner(.updateFriendInfo(let code, let name)):
                state.invitedFriendCode = code
                state.invitedFriendName = name
                return .none
            case .inner(.showFriendAlert(let code)):
                return .send(.inner(.fetchFriendInfo(code)))
            case .user(.acceptFriend):
              return .run { [code = state.invitedFriendCode] send in
                  do {
                      guard let code = code else { return }
                      try await friendClient.postAddFriend(code)
                      await send(.inner(.showAlert("친구 추가가 완료되었습니다.", true)))
                  } catch let error as CustomError {
                      if case let .badRequest(message, _) = error {
                          await send(.inner(.showAlert(message, false)))
                      } else {
                          await send(.inner(.showAlert("알 수 없는 오류가 발생했습니다.", false)))
                      }
                  } catch {
                      await send(.inner(.showAlert("알 수 없는 오류가 발생했습니다.", false)))
                  }
              }
            case .user(.rejectFriend):
                state.invitedFriendCode = nil
                state.invitedFriendName = nil
                state.pendingInviteCode = nil
                return .none
            case .inner(.showAlert):
                state.invitedFriendCode = nil
                state.invitedFriendName = nil
                state.pendingInviteCode = nil
                return .none
            default:
                return .none
            }
        }
    }
}
