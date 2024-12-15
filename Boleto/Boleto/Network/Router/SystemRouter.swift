//
//  SystemRouter.swift
//  Boleto
//
//  Created by Sunho on 11/26/24.
//

import Foundation
import Alamofire
enum SystemRouter {
    case getAllStickers(isEvent:Bool = false)
    case getAllFrames(isEvent: Bool = true)
}
extension SystemRouter: NetworkProtocol {
    var baseURL: String {
        return CommonAPI.api + "/api/v1/sys"
    }
    var path: String {
        switch self {
        case .getAllStickers:
            "/stickers"
        case .getAllFrames:
            "/frames"
        }
    }
    var method: HTTPMethod {
        switch self {
        case .getAllStickers, .getAllFrames:
                .get
        }
    }
    var parameters: RequestParams {
        switch self {
        case .getAllStickers(let event):
                .query(["isEvent": event])
        case .getAllFrames(let event):
                .query(["isEvent": event])
        }
    }
    var multipartData: MultipartFormData? {
        return nil
    }
}
