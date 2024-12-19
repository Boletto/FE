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
                let data = try await NetworkManager.request(endpoint: FriendRouter.getFriendLists, responseType: [FriendResponse].self)
                return data.map{$0.toModel()}
            }, getShareCode: {
                let data = try await NetworkManager.request(endpoint: FriendRouter.getMyCode, responseType: ShareCodeResponse.self)
              
                    return data.friendCode
          
            }, getFindFrined: {keyword in
                let data = try await NetworkManager.request(endpoint: FriendRouter.getFindFrined(keyword: keyword), responseType: [FriendResponse].self)
                return data.map{$0.toModel()}
            }, postAddFriend: { friendCode in
                do {
                    let data = try await NetworkManager.request(endpoint: FriendRouter.postAddFriend(friendCode: friendCode), responseType: EmptyData.self)
                } catch let error as CustomError {
                    throw error
                }
            }, deleteFriend: { friendId in
                let data = try await NetworkManager.request(endpoint: FriendRouter.deleteFriend(friendID: friendId), responseType: EmptyData.self)
         
            }, getInfoByCode:  { code in
                let data = try await NetworkManager.request(endpoint: FriendRouter.getInfobyCode(friendCode: code), responseType: ShareCodeResponse.self)
                    return data.userNickname
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
