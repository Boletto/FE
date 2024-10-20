//
//  FriendResponse.swift
//  Boleto
//
//  Created by Sunho on 10/4/24.
//

import Foundation
struct FriendResponse: Decodable {
    let userId: Int
    let name: String?
    let nickName: String
    let userProfile: String?
}
extension FriendResponse {
    func toDummyModel() -> FriendDummy {
        return FriendDummy(id: self.userId, name: self.name, nickname: self.nickName, imageUrl: self.userProfile)
    }
}
