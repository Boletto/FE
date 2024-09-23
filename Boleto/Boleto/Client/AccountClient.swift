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
    var postLogi: @Sendable (LoginUser) async throws -> (Bool)
    var postAppleLogin: @Sendable (AppleLoginRequest) async throws -> (Bool)
}
extension AccountClient: DependencyKey {
    static var liveValue: Self =  {
        let url = "http://3.37.140.217/api/v1/oauth/login"
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        return Self(
            postLogi: {request in
              
                return try await withCheckedThrowingContinuation { continuation in
                    AF.request(url, method: .post, parameters: request, encoder:  JSONParameterEncoder.default, headers: headers)
                        .response{ data in
                            print(data )
                        }
                        .validate()
                        .responseDecodable(of: GeneralResponse<LoginResponseData>.self) { response in
                            switch response.result {
                            case .success(let apiResposne):
                                print(apiResposne)
                                if apiResposne.success, let loginData = apiResposne.data {
                                    KeyChainManager.shared.save(key: .accessToken, token: loginData.accessToken)
                                    KeyChainManager.shared.save(key: .refreshToken, token: loginData.refreshToken)
                                    continuation.resume(returning: true)
                                }
                            case .failure(let error):
                                continuation.resume(returning: false)
                                
                            }
                        }
                }
            }, postAppleLogin: { req in
                return try await withCheckedThrowingContinuation { continuation in
                    AF.request(CommonAPI.api+"/api/v1/oauth2/login/apple", method: .post, parameters: req, encoder: JSONParameterEncoder.default, headers: headers)
                        .response {data in
                            print(data)}
                        .validate()
                        .responseDecodable(of: GeneralResponse<LoginResponseData>.self) { response in
                            switch response.result {
                            case .success(let apiResposne):
                                print(apiResposne)
                                if apiResposne.success, let loginData = apiResposne.data {
                                    KeyChainManager.shared.save(key: .accessToken, token: loginData.accessToken)
                                    KeyChainManager.shared.save(key: .refreshToken, token: loginData.refreshToken)
                                    continuation.resume(returning: true)
                                }
                            case .failure(let error):
                                continuation.resume(returning: false)
                                
                            }
                        }
                }
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
