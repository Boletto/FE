//
//  AlarmRouter.swift
//  Boleto
//
//  Created by Sunho on 11/11/24.
//

import Foundation
import Alamofire

enum AlarmRouter {
     case putAlarm(Int)
    case getAlarm
    case postAlarm(AlarmRequest)
}
extension AlarmRouter: NetworkProtocol {
    var baseURL: String {
        return CommonAPI.api + "/api/v1/user/alarm"
    }
    var path: String {
        switch self {
        case .putAlarm(let alarmId):
            "/\(alarmId)"
        case .getAlarm:
            ""
        case .postAlarm:
            ""
        }
    }
    var method: HTTPMethod {
        switch self {
        case .putAlarm:
                .put
        case .getAlarm:
                .get
        case .postAlarm:
                .post
        }
    }
    var parameters: RequestParams {
        switch self {
        case .putAlarm:
                .none
        case .getAlarm:
                .none
        case .postAlarm(let alarmRequest):
                .body(alarmRequest)
        }
    }
    var multipartData: MultipartFormData? {
        return nil
    }
}
