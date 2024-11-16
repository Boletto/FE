//
//  FriendRouter.swift
//  Boleto
//
//  Created by Sunho on 11/14/24.
//

import Foundation
import Alamofire

enum FriendRouter {
    case getMyCode
    case getFriendLists
    case getFindFrined(GetSearchFriendRequest)
    case postAddFriend(friendCode: String)
    case deleteFriend(friendID: Int)
    case getInfobyCode(friendCode: String)
}

extension FriendRouter: NetworkProtocol {
    var baseURL: String {
        return CommonAPI.api + "/api/v1/friend"
    }
    var path: String {
        switch self {
        case .getMyCode:
            "/code"
        case .getFriendLists:
            ""
        case .getFindFrined:
            "/search"
        case .postAddFriend(let friendCode):
            "/code/\(friendCode)"
        case .deleteFriend(let friendID):
            "/\(friendID)"
        case .getInfobyCode(let friendCode):
            "/code/\(friendCode)"
        }
    }
    var method: HTTPMethod {
        switch self {
        case .getMyCode:
                .get
        case .getFriendLists:
                .get
        case .getFindFrined:
                .get
        case .postAddFriend:
                .post
        case .deleteFriend:
                .delete
        case .getInfobyCode:
                .get
        }
    }
    var parameters: RequestParams {
        switch self {
        case .getMyCode:
                .none
        case .getFriendLists:
                .none
        case .getFindFrined(let keyword):
                .query(keyword)
        case .postAddFriend:
                .none
        case .deleteFriend:
                .none
        case .getInfobyCode:
                .none
        }
    }
    var multipartData: MultipartFormData? {
        return nil
    }
}
