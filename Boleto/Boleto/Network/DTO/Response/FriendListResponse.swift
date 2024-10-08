//
//  FriendListResponse.swift
//  Boleto
//
//  Created by Sunho on 10/3/24.
//

import Foundation
struct FriendListResponse: Decodable {
    let userId: Int
    let name: String?
    let nickName: String
    let userProfile: String?
    let isFriend: Bool
}
extension FriendListResponse {
    func toDummyModel() -> FriendDummy {
        return FriendDummy(id: self.userId, name: self.name, nickname: self.nickName, imageUrl: self.userProfile)
    }
    func toAllUser() -> AllUser {
        return AllUser(id: self.userId, name: self.name, nickname: self.nickName, imageUrl: self.userProfile, isFriend: self.isFriend)
    }
}
