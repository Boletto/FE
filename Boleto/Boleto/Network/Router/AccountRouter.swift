//
//  AccountRouter.swift
//  Boleto
//
//  Created by Sunho on 9/28/24.
//

import Foundation
import Alamofire

enum AccountRouter {
    case postKakaoLogin(LoginUserRequest)
    case postAppleLogin(AppleLoginRequest)
    case postLogout
    case postRefreshToken(refreshToken: String)

}
extension AccountRouter: NetworkProtocol {
    var multipartData: Alamofire.MultipartFormData? {
        return nil
    }
    
    var baseURL: String {
        return CommonAPI.api + "/api/v1"
    }
    var path: String {
        switch self {
        case .postKakaoLogin:
            "/oauth/login"
        case .postAppleLogin:
            "/oauth2/login/apple"
        case .postLogout:
            "auth/logout"
        case .postRefreshToken:
            "auth/reissue"
        }
    }
    var method: HTTPMethod {
        switch self {
        case .postKakaoLogin:
                .post
        case .postAppleLogin:
                .post
        case .postLogout:
                .post
        case .postRefreshToken:
                .post
        }
    }
    var parameters: RequestParams {
        switch self {
        case .postKakaoLogin(let loginUserRequest):
                .body(loginUserRequest)
        case .postAppleLogin(let appleLoginRequest):
                .body(appleLoginRequest)
        case .postRefreshToken(let token):
                .body(["refresh_token": token])
        default:
            .none
        }
    }
}

