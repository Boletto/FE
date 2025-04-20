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
    
    enum Action {
        case checkPendingInviteCode
        case setPendingInviteCode(String)
        case fetchFriendInfo(String)
        case showFriendAlert(String)
        case updateFriendInfo(String, String)
        case acceptFriend
        case rejectFriend
        case showAlert(String, Bool)
    }
    
    @Dependency(\.friendClient) var friendClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .setPendingInviteCode(let code):
                state.pendingInviteCode = code
                return .none
            case .checkPendingInviteCode:
                if let code = state.pendingInviteCode {
                    return .send(.showFriendAlert(code))
                }
                return .none
            case .fetchFriendInfo(let code):
                return .run {send in
                    do {
                        let name = try await friendClient.getInfoByCode(code)
                        await send(.updateFriendInfo(code, name))
                    } catch let error as CustomError{
                        switch error {
                        case .expiredRefreshToken:
                            await send(.showAlert("토큰이 만료되었어요", false))
                        case .notFound(let message):
                            await send(.showAlert(message, false))
                        default:
                            print(error.localizedDescription)
                        }
                    }
                }
            case .updateFriendInfo(let code, let name):
                state.invitedFriendCode = code
                state.invitedFriendName = name
                return .none
            case .showFriendAlert(let code):
                return .send(.fetchFriendInfo(code))

            case .acceptFriend:
              return .run { [code = state.invitedFriendCode] send in
                  do {
                      guard let code = code else { return }
                      try await friendClient.postAddFriend(code)
                      await send(.showAlert("친구 추가가 완료되었습니다.", true))
                  } catch let error as CustomError {
                      if case let .badRequest(message, _) = error {
                          await send(.showAlert(message, false))
                      } else {
                          await send(.showAlert("알 수 없는 오류가 발생했습니다.", false))
                      }
                  } catch {
                      await send(.showAlert("알 수 없는 오류가 발생했습니다.", false))
                  }
              }
            case .rejectFriend:
                state.invitedFriendCode = nil
                state.invitedFriendName = nil
                state.pendingInviteCode = nil
                return .none
            case .showAlert:
                state.invitedFriendCode = nil
                state.invitedFriendName = nil
                state.pendingInviteCode = nil
                return .none
                

            }
        }
    }
}
