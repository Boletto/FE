//
//  FriendResponse.swift
//  Boleto
//
//  Created by Sunho on 10/4/24.
//

import Foundation
struct FriendResponse: Decodable {
    let userId: Int
    let name: String
    let nickname: String
    let userProfile: String?
    enum CodingKeys: String, CodingKey {
        case userId = "friend_user_id"
        case userProfile = "user_profile"
       case name, nickname
    }
}
extension FriendResponse {
    func toModel() -> MemberModel {
        return MemberModel(id: self.userId, name: self.name, nickname: self.nickname, imageUrl: self.userProfile)
    }
}
