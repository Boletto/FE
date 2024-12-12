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
}
extension SystemRouter: NetworkProtocol {
    var baseURL: String {
        return CommonAPI.api + "/api/v1/sys"
    }
    var path: String {
        switch self {
        case .getAllStickers:
            "/stickers"
        }
    }
    var method: HTTPMethod {
        switch self {
        case .getAllStickers:
                .get
        }
    }
    var parameters: RequestParams {
        switch self {
        case .getAllStickers(let event):
                .query(["isEvent": event])
        }
    }
    var multipartData: MultipartFormData? {
        return nil
    }
}
