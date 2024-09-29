//
//  UserRouter.swift
//  Boleto
//
//  Created by Sunho on 9/28/24.
//

import Alamofire
import Foundation
enum UserRouter {
    case patchUserInfo(ProfileRequest, imageFile: Data)
    case getCollectedStickers
    case getFrames
    
}
extension UserRouter: NetworkProtocol {
    var baseURL: String {
        return CommonAPI.api + "/api/v1"
    }
    var path: String {
        switch self {
        case .patchUserInfo:
            "/user"
        case .getCollectedStickers:
            "/user/stickers"
        case .getFrames:
            "/user/frames"
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
        case .patchUserInfo(let profileRequest, let imageFile):
            let multiPart = MultipartFormData()
            let dataDict = profileRequest.toDictionary()
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: dataDict)
                multiPart.append(jsonData, withName: "data",  mimeType: "application/json")
                
            } catch {
                return nil
            }
            multiPart.append(imageFile, withName: "file", fileName: profileRequest.name, mimeType:  "application/json")
            return multiPart
        default: return nil
        }
    }
}
