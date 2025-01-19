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
    case postFrameCode(String)
    
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
            "/stickers/\(stickerCode.stickerCode)"
        case .postCustomFrame:
            "/frames"
        case .deleteUser:
            "/me"
        case .postFrameCode(let code):
            "/frames/\(code)"
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
        case .postFrameCode:
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
        case .putFCMToken(let req):
            return .query(req)
        case .postUserSticker:
            return .none
        default:
            return .none
        }
    }
    var multipartData: MultipartFormData? {
        switch self {
        case .patchUserInfo(let profileRequest, let imageFile):
            let multiPart = MultipartFormData()
            
            do {
                var dataDict = profileRequest.toDictionary()
  
                let jsonData = try JSONSerialization.data(withJSONObject: dataDict)
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    print(jsonString)
                }
                multiPart.append(jsonData, withName: "data",  mimeType: "application/json")
                
                
            } catch {
                return nil
            }
            if let imageFile = imageFile {
                multiPart.append(imageFile , withName: "file", fileName: profileRequest.name ?? "\(UUID().uuidString)", mimeType:  "image/jpeg")
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
