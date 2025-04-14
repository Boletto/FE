//
//  ImageClient.swift
//  Boleto
//
//  Created by Sunho on 4/13/25.
//

import Foundation
import ComposableArchitecture

struct ImageClient {
    var loadImage: @Sendable (URL, CGSize?) async
}
