//
//  FriendClient.swift
//  Boleto
//
//  Created by Sunho on 11/14/24.
//

import Foundation
import ComposableArchitecture

@DependencyClient
struct FriendClient {
    var getAllFriends: @Sendable () async throws -> [MemberModel]
    var getShareCode: @Sendable () async throws -> String
    var getFindFrined: @Sendable (String) async throws -> [MemberModel]
    var postAddFriend: @Sendable (String) async throws -> Void
    var deleteFriend: @Sendable (Int) async throws -> Void
    var getInfoByCode: @Sendable (String) async throws -> (String)
}
extension FriendClient: DependencyKey {
    static var liveValue: FriendClient = {
        return Self(
            getAllFriends: {
                let task = API.session.request(FriendRouter.getFriendLists,interceptor: RequestTokenInterceptor())
                    .validate()
                    .serializingDecodable(GeneralResponse<[FriendResponse]>.self)
                switch await task.result {
                case .success(let data):
                    guard let data = data.data else {return []}
                    return data.map{$0.toModel()}
                case .failure(let err):
                    throw err
                }
            }, getShareCode: {
                let task = API.session.request(FriendRouter.getMyCode,interceptor: RequestTokenInterceptor())
                    .validate()
                    .serializingDecodable(GeneralResponse<ShareCodeResponse>.self)
                switch await task.result {
                case .success(let data):
                    guard let data = data.data else {return ""}
                    return data.friendCode
                case .failure(let err):
                    throw err
                }
            }, getFindFrined: {keyword in
                let task = API.session.request(FriendRouter.getFindFrined(GetSearchFriendRequest(keyword: keyword)),interceptor: RequestTokenInterceptor())
                    .validate()
                    .serializingDecodable(GeneralResponse<[FriendResponse]>.self)
                switch await task.result {
                case .success(let data):
                    guard let data = data.data else {return []}
                    return data.map{$0.toModel()}
                case .failure(let err):
                    throw err
                }
            }, postAddFriend: { friendCode in
                let task = API.session.request(FriendRouter.postAddFriend(friendCode: friendCode),interceptor: RequestTokenInterceptor())
                    .validate()
                    .serializingDecodable(GeneralResponse<EmptyData>.self)
                switch await task.result {
                case .success(let res):
                    if res.success {
                        return 
                    } else if let apiError = res.error{
                        switch apiError.code {
                        case 40010:
                            throw PostFriendError.expiredFriendCode
                        case 40011:
                            throw PostFriendError.usedFriendCode
                        case 40012:
                            throw PostFriendError.selfFriendCode
                        default:
                            throw PostFriendError.unknownCode
                        }
                    }
                case .failure(let err):
                    throw err
                }
            }, deleteFriend: { friendId in
                let task = API.session.request(FriendRouter.deleteFriend(friendID: friendId),interceptor: RequestTokenInterceptor())
                    .validate()
                    .serializingDecodable(GeneralResponse<EmptyData>.self)
                switch await task.result {
                case .success(let res):
                    if res.success {
                        return
                    }
                case .failure(let err):
                    throw err
                }
            }, getInfoByCode:  { code in
                let task = API.session.request(FriendRouter.getInfobyCode(friendCode: code), interceptor: RequestTokenInterceptor())
                    .validate()
                    .serializingDecodable(GeneralResponse<ShareCodeResponse>.self)
                switch await task.result {
                case .success(let res):
                    guard let data = res.data else {return ""}
                    return data.userNickname
                case .failure(let err):
                    throw err
                }
                
            }
        )
    }()
}
extension FriendClient {
    static var testValue: FriendClient = {
        return Self(
            getAllFriends: {
                [.dummy]
            }, getShareCode: {
                "heiho"
            }, getFindFrined: { _ in
                [.dummy]
            }, postAddFriend: { _ in
                
                
            }, deleteFriend: { _ in
                
            }, getInfoByCode: { _ in
                return "선호"
                
            }
        )
    }()
}
extension DependencyValues {
    var friendClient: FriendClient {
        get { self[FriendClient.self] }
        set { self[FriendClient.self] = newValue }
    }
}
