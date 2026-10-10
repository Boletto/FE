//
//  PostFriendError.swift
//  Boleto
//
//  Created by Sunho on 11/15/24.
//

import Foundation
enum PostFriendError:Equatable, Error  {
    case expiredFriendCode
   case usedFriendCode
   case selfFriendCode
    case unknownCode
}
