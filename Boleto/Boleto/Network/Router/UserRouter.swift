//
//  UserRouter.swift
//  Boleto
//
//  Created by Sunho on 9/28/24.
//

import Alamofire
import Foundation
enum UserRouter {
    case patchUserInfo(ProfileRequest, imageFile: Data?)
    case getCollectedStickers
    case getFrames
    case putFCMToken(PutUserTokenRequest)
    case postUserSticker(UploadStickerRequest)
    case postCustomFrame(imageFile: Data)
    case deleteUser
    
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
        case .putFCMToken:
            "/device-token"
        case .postUserSticker(let stickerCode):
            "/stickers/\(stickerCode)"
        case .postCustomFrame:
            "/frames"
        case .deleteUser:
            "/me"
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

        case .putFCMToken:
                .put
        case .postUserSticker:
                .post
        case .postCustomFrame:
                .post
        case .deleteUser:
                .delete
            
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
        case .putFCMToken(let req):
            return .query(req)
        case .postUserSticker(let req):
            return .body(req)
        default:
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
            if let imageFile = imageFile {
                multiPart.append(imageFile , withName: "file", fileName: profileRequest.name, mimeType:  "image/jpeg")
            }
            return multiPart
        case .postCustomFrame(let file):
            let multiPart = MultipartFormData()
            multiPart.append(file, withName: "file",  fileName: UUID().uuidString,mimeType: "image/jpeg")
            return multiPart

        default: return nil
        }
    }
}
