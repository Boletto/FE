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
    case putFCMToken(PutUserTokenRequest)
    case postUserSticker(UploadStickerRequest)
    
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
        case .putFCMToken:
            "/user/device-token"
        case .postUserSticker(let stickerCode):
            "/user/stickers/\(stickerCode)"
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
//        case .postUserCollect:
//                .post
        case .putFCMToken:
                .put
        case .postUserSticker:
                .post
            
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
//        case .postUserCollect(let request ,let  imageFile):
//            return .body(request)
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
            multiPart.append(imageFile, withName: "file", fileName: profileRequest.name, mimeType:  "image/jpeg")
            return multiPart
//        case .postUserCollect(let req, let imageFile):
//            guard let imageFile = imageFile else {return nil}
//            let multipart = MultipartFormData()
//            multipart.append(imageFile, withName: "frameFile", fileName: "\(UUID().uuidString)", mimeType: "image/jpeg")
//            return multipart
        default: return nil
        }
    }
}
