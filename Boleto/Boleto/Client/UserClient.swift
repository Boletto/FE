//
//  UserClient.swift
//  Boleto
//
//  Created by Sunho on 9/30/24.
//

import Foundation
import ComposableArchitecture
import Alamofire

@DependencyClient
struct UserClient {
    var patchUser: @Sendable (Data?, String,String?, Bool) async throws -> User
//    var addUser: @Sendable (Data?, String, Bool) async throws -> User
    var getUserFrames: @Sendable () async throws -> [FrameData]
    var getStickers: @Sendable () async throws -> [StickerData]
    var putFCMToken: @Sendable (String) async throws-> Void
    var postStickerCode: @Sendable (String) async throws -> Void
    var postFrameCode: @Sendable (String) async throws -> Void
    var postCustomFrame: @Sendable(Data) async throws -> FrameItem
    var deleteUser: @Sendable () async throws -> Void
    enum UserError: Error {
        case fuck
    }
}
extension UserClient: DependencyKey {
    static var liveValue: Self = {
        return Self(
            patchUser: { imagefile, nickname, name, profileDefault in
                    let profileRequest = ProfileRequest(nickName: nickname, name: name, profileDefault: profileDefault)
                    guard let multipartData = UserRouter.patchUserInfo(profileRequest, imageFile: imagefile).multipartData else {
                        throw NSError(domain: "MultipartDataError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create multipart form data"])
                    }
        
     
                let data = try await NetworkManager.upload(endpoint: UserRouter.patchUserInfo(profileRequest, imageFile: imagefile), multipartData: multipartData, responseType: ProfileResponse.self)
                let user = User(name: data.name, nickName: data.nickname, profileImage: data.profileUrl, userID: 0)
                return user
            },
            getUserFrames: {
                let data = try await NetworkManager.request(endpoint: UserRouter.getFrames, responseType: [FrameResponse].self)
              
                let frameData = data.map {
                    return FrameData(frameURL: $0.frameUrl, frameCode: $0.frameCode, frameType: $0.frameType)
                }
                return frameData
            }, getStickers: {
                let data = try await NetworkManager.request(endpoint: UserRouter.getCollectedStickers, responseType: [UserStickerResponse].self)
              
          
                let stickerDatas = data.compactMap({ res in
                    return StickerData(stickerType: res.stickerType, name: res.stickerName, url: res.stickerURL, isCollected: true, stickerCode: res.stickerCode)
                })
                return stickerDatas
                
            }, putFCMToken: { token in
                let _ = try await NetworkManager.request(endpoint: UserRouter.putFCMToken(PutUserTokenRequest(token: token)), responseType: EmptyData.self)
        
            }, postStickerCode: { stickercode in
                let _ = try await NetworkManager.request(endpoint: UserRouter.postUserSticker(UploadStickerRequest(stickerCode: stickercode)), responseType: EmptyData.self)
                
            }, postFrameCode: {code in
                let _ = try await NetworkManager.request(endpoint: UserRouter.postFrameCode(code), responseType: EmptyData.self)
            }, postCustomFrame:  { imageData in
                guard let multiPartData = UserRouter.postCustomFrame(imageFile: imageData).multipartData else {throw NSError(domain: "MultipartDataError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create multipart form data"]) }
           
                let data = try await NetworkManager.upload(endpoint: UserRouter.postCustomFrame(imageFile: imageData), multipartData: multiPartData, responseType: FrameResponse.self)
           
                return FrameItem(imageUrl: data.frameUrl, frameCode: data.frameCode, frameType: data.frameType)
            }, deleteUser: {
                let response =  try await NetworkManager.request(endpoint: UserRouter.deleteUser, responseType: EmptyData.self)
                
            }
        )
    }()
}
extension DependencyValues{
    var userClient: UserClient {
        get {self[UserClient.self]}
        set {self[UserClient.self] = newValue}
    }
}
