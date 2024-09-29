//
//  UserRouter.swift
//  Boleto
//
//  Created by Sunho on 9/28/24.
//

import Alamofire
import Foundation
enum UserRouter {
    case patchUserInfo
    case getCollectedStickers
    case getFrames
    
}
extension UserRouter: NetworkProtocol {
    var baseURL: String {
        return CommonAPI.api + "/api/v1/user"
    }
    var path: String {
        switch self {
        case .patchUserInfo:
            ""
        case .getCollectedStickers:
            "/stickers"
        case .getFrames:
            "/frames"
        }
    }
    var method: HTTPMethod {
        switch self {
        case .patchUserInfo:
                .patch
        case .getCollectedStickers:
                .get
        case .getFrames:
                .get
            
        }
    }
    var parameters: RequestParams {
        switch self {
        case .patchUserInfo:
            return .none
        case .getCollectedStickers:
            return .none
        case .getFrames:
            return .none
        }
    }
    var multipartData: MultipartFormData? {
        switch self {
        default: return nil
        }
    }
}
