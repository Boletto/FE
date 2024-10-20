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
    case postUserCollect(UploadStickerRequest?, imageFile : Data?)
    case fetchAllUser
    case getSearchUser(GetSearchFriendRequest)
    case postFriend(PostFriendMatching)
    case getFriend
    
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
        case .postUserCollect:
            "/user/collect"
        case .fetchAllUser:
            "/user/all"
        case .getSearchUser:
            "/friend/search"
        case .postFriend:
            "/friend"
        case .getFriend:
            "/friend"
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
        case .postUserCollect:
                .post
        case .fetchAllUser:
                .get
        case .getSearchUser:
                .get
        case .postFriend:
                .post
        case .getFriend:
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
        case .postUserCollect(let request ,let  imageFile):
            return .body(request)
        case .getSearchUser(let request ):
            return .body(request)
        case .postFriend(let req):
            return .query(req)
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
        case .postUserCollect(let req, let imageFile):
            guard let imageFile = imageFile else {return nil}
            let multipart = MultipartFormData()
            multipart.append(imageFile, withName: "frameFile", fileName: "\(UUID().uuidString)", mimeType: "image/jpeg")
            return multipart
        default: return nil
        }
    }
}
