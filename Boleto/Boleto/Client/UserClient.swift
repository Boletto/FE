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
    var patchUser: @Sendable (Data, String,String) async throws -> User
    var postCollection: @Sendable (StickerImage?, Data?) async throws -> Bool
    var getUserFrames: @Sendable () async throws -> [FrameItem]
    var getStickers: @Sendable () async throws -> [StickerImage]
    var getAllUsers: @Sendable () async throws -> [FriendDummy]
//    var getSearchUsers: @Sendable (String ) async throws
    var postFriend: @Sendable(Int) async throws -> Bool
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
                
            
            },postCollection:  { stickertype, imageFile in
                if let sticker = stickertype {
                    let req = UploadStickerRequest(stickerType: sticker)
                    let task = API.session.request(UserRouter.postUserCollect(req, imageFile: nil), interceptor: RequestTokenInterceptor())
                        .validate()
                        .serializingDecodable(GeneralResponse<EmptyData>.self)
                    switch await task.result {
                    case .success(let success):
                        return true
                    case .failure(let error):
                        throw error
                    }
                } else if let imagedata = imageFile {
                    guard let multipartData = UserRouter.postUserCollect(nil, imageFile: imagedata).multipartData else {
                        throw NSError(domain: "MultipartDataError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create multipart form data"])
                    }
                    let task = API.session.upload(multipartFormData: multipartData, with: UserRouter.postUserCollect(nil, imageFile: imagedata), interceptor: RequestTokenInterceptor())
                        .validate()
                        .serializingDecodable(GeneralResponse<EmptyData>.self)
                    switch await task.result {
                    case .success(let success):
                        return true
                    case .failure(let error):
                        throw error
                    }
                }
                    return false
            
            }, getUserFrames: {
                let task = API.session.request(UserRouter.getFrames, interceptor: RequestTokenInterceptor())
                    .validate()
                    .serializingDecodable(GeneralResponse<MyFrameResponse>.self)
                return try await task.value.data!.parestoFrameItem()
            }, getStickers: {
                let task = API.session.request(UserRouter.getCollectedStickers, interceptor: RequestTokenInterceptor())
                    .validate()
                    .serializingDecodable(GeneralResponse<MyStickerResponse>.self)
                let value = try await task.value
                let stickerimages = value.data?.stickers.compactMap({ sticker in
                    return StickerImage(rawValue: sticker.stickerType)
                })
                return stickerimages ?? []
                
            }, getAllUsers:  {
                let task = API.session.request(UserRouter.fetchAllUser, interceptor: RequestTokenInterceptor())
                    .validate()
                    .serializingDecodable(GeneralResponse<[FriendListResponse]>.self)
                do {
                    let value = try await task.value

                    // Assuming `value.data` contains an array of `FriendListResponse`
                    if let friendList = value.data {
                        let dummyModels = friendList.map { $0.toDummyModel() } // Convert each `FriendListResponse` to `FriendDummy`
                        
                        // Now you can use `dummyModels` as needed
                       return dummyModels
                    } else {
                        // Handle the case where `data` is nil
                        throw UserError.fuck
                    }
                } catch {
                    // Handle the error
                   throw error
                }
            }, postFriend: {  id in
                let task = API.session.request(UserRouter.postFriend(PostFriendMatching(friendId: id)),interceptor: RequestTokenInterceptor())
                    .validate()
                    .serializingDecodable(GeneralResponse<FriendListResponse>.self)
                do {
                    let value = try await task.value
                    if value.success {
                        return true
                    } else {
                        return false
                    }
                } catch {
                    throw error
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
