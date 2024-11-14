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
    var getAllFriends: @Sendable () async throws
}
