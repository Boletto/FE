//
//  AccountClient.swift
//  Boleto
//
//  Created by Sunho on 9/21/24.
//

import Foundation
import Alamofire
import ComposableArchitecture

@DependencyClient
struct AccountClient {
    var postLogi: @Sendable (LoginUserRequest) async throws -> User?
    var postAppleLogin: @Sendable (AppleLoginRequest) async throws -> User?
    var postLogout: @Sendable () async throws -> Void
}
extension AccountClient: DependencyKey {
    static var liveValue: Self =  {
        return Self(
            postLogi: {request in
                let task = API.session.request(AccountRouter.postKakaoLogin(request))
                    .validate()
                    .serializingDecodable(GeneralResponse<LoginResponse>.self)
                
                switch await task.result {
                case .success(let res):
                    if let data = res.data {
                        KeyChainManager.shared.save(key: .accessToken, token: data.accessToken)
                        KeyChainManager.shared.save(key: .refreshToken, token: data.refreshToken)
                        KeyChainManager.shared.save(key: .userid, token: String(data.userID))
                        let user = User(name: data.userName ?? "" , nickName: data.userNickName ?? "", profileImage: data.userProfile, userID: data.userID)
                        return user
                    }
                    return nil
                case .failure(let err):
                    print(err)
                    throw err
                }

                
            }, postAppleLogin: { req in
                let task = API.session.request(AccountRouter.postAppleLogin(req))
                    .validate()
                    .serializingDecodable(GeneralResponse<LoginResponse>.self)
                
                switch await task.result {
                case .success(let apiResposne):
                    if apiResposne.success, let loginData = apiResposne.data {
                        KeyChainManager.shared.save(key: .accessToken, token: loginData.accessToken)
                        KeyChainManager.shared.save(key: .refreshToken, token: loginData.refreshToken)
                        KeyChainManager.shared.save(key: .userid, token: String(loginData.userID))
                        if let name =  loginData.userName, let nickName = loginData.userNickName {
                            let user = User(name: name, nickName: nickName, profileImage: loginData.userProfile, userID: loginData.userID)
                            return user
                        }
                            return nil
                    }
                    return nil
  
                case .failure(let error):
                    throw error
                    
                }
            }, postLogout: {
                let data = try await NetworkManager.request(endpoint: AccountRouter.postLogout, responseType: EmptyData.self)
       
            }
        )
    }()
}
extension DependencyValues {
    var accountClient: AccountClient {
        get { self[AccountClient.self] }
        set { self[AccountClient.self] = newValue }
    }
}
