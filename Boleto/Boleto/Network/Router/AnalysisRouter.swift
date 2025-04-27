//
//  File.swift
//  Boleto
//
//  Created by Sunho on 4/22/25.
//

import Foundation
import Alamofire
enum AnalysisRouter {
    case postEvent(TTIRequest)
}
extension AnalysisRouter: NetworkProtocol {
    var baseURL: String {
        return CommonAPI.api +  "/api/v1/analysis"
    }
    var path: String {
        switch self {
        case .postEvent:
            "/event"
        }
    }
    var method: HTTPMethod {
        switch self {
        case .postEvent:
                .post
        }
    }
    var parameters: RequestParams {
        switch self {
        case .postEvent(let request):
                .body(request)
        }
    }
    var multipartData: MultipartFormData? {
        return nil
    }}
