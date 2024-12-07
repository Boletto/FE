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
    var patchUser: @Sendable (Data?, String,String) async throws -> User
    var getUserFrames: @Sendable () async throws -> [FrameData]
    var getStickers: @Sendable () async throws -> [StickerData]
    var putFCMToken: @Sendable (String) async throws-> Void
    var postStickerCode: @Sendable (String) async throws -> Void
    var postCustomFrame: @Sendable(Data) async throws -> FrameItem
    var deleteUser: @Sendable () async throws -> Void
    enum UserError: Error {
        case fuck
    }
}
extension UserClient: DependencyKey {
    static var liveValue: Self = {
        return Self(
            patchUser: { imagefile, nickname, name in
                let profileRequest = ProfileRequest(nickName: nickname, name: name)
                guard let multipartData = UserRouter.patchUserInfo(profileRequest, imageFile: imagefile).multipartData else {
                    throw NSError(domain: "MultipartDataError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create multipart form data"])
                }
                let task = API.session.upload(multipartFormData: multipartData, with: UserRouter.patchUserInfo(profileRequest, imageFile: imagefile), interceptor: RequestTokenInterceptor())
                    .validate()
                    .serializingDecodable(GeneralResponse<ProfileResponse>.self)
           
              
                let value = try await task.value
                guard let data = value.data else {throw CustomError.invalidResponse}
                let user = User(name: data.name, nickName: data.nickname, profileImage: data.profileUrl)
                return user
                
            
            },
            getUserFrames: {
                let res = try await NetworkManager.request(endpoint: UserRouter.getFrames, responseType: GeneralResponse<[FrameResponse]>.self)
                guard let data = res.data else {throw CustomError.invalidResponse }
                let frameData = data.map {
                    return FrameData(frameURL: $0.frameUrl, frameCode: $0.frameCode, frameType: $0.frameType)
                }
                return frameData
            }, getStickers: {
                let task = API.session.request(UserRouter.getCollectedStickers, interceptor: RequestTokenInterceptor())
                    .validate()
                    .serializingDecodable(GeneralResponse<[UserStickerResponse]>.self)
                let value = try await task.value
                let stickerDatas = value.data?.compactMap({ res in
                    return StickerData(stickerType: res.stickerType, name: res.stickerName, url: res.stickerURL, isCollected: true, stickerCode: res.stickerCode)
                })
                return stickerDatas ?? []
                
            }, putFCMToken: { token in
                let task = API.session.request(UserRouter.putFCMToken(PutUserTokenRequest(token: token)), interceptor: RequestTokenInterceptor())
                    .validate()
                    .serializingDecodable(GeneralResponse<EmptyData>.self)
                switch await task.result {
                case .success(let success):
                    return
                case .failure(let error):
                    throw error
                }
            }, postStickerCode: { stickercode in
                try await NetworkManager.request(endpoint: UserRouter.postUserSticker(UploadStickerRequest(stickerCode: stickercode)), responseType: GeneralResponse<EmptyData>.self)
                
            }, postCustomFrame:  { imageData in
                guard let multiPartData = UserRouter.postCustomFrame(imageFile: imageData).multipartData else {throw NSError(domain: "MultipartDataError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create multipart form data"]) }
                let task =  API.session.upload(multipartFormData: multiPartData, with: UserRouter.postCustomFrame(imageFile: imageData),interceptor: RequestTokenInterceptor())
                    .validate()
                    .serializingDecodable(GeneralResponse<FrameResponse>.self)
                let value = try await task.value
                guard  let data = value.data else {throw CustomError.invalidResponse}
                return FrameItem(imageUrl: data.frameUrl, frameCode: data.frameCode, frameType: data.frameType)
            }, deleteUser: {
                let response =  try await NetworkManager.request(endpoint: UserRouter.deleteUser, responseType: GeneralResponse<EmptyData>.self)
                if !response.success {
                    switch response.error?.code {
                    case 50000:
                        throw CustomError.unknownError
                    default:
                        throw CustomError.invalidResponse
                    }
                 
                }
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
