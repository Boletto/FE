//
//  NetworkProtocol.swift
//  Boleto
//
//  Created by Sunho on 9/22/24.
//

import Alamofire
import Foundation
protocol NetworkProtocol: URLRequestConvertible {
    var baseURL: String {get}
    var method: HTTPMethod {get}
    var path: String {get}
    var parameters: RequestParams {get}
    var multipartData: MultipartFormData? {get}
}
enum RequestParams {
    case query(_ parameter: Encodable?)
    case body(_ parameter: Encodable?)
    case none
}
extension NetworkProtocol  {
    func asURLRequest() throws -> URLRequest {
        let baseurl = try baseURL.asURL()
        let url = path.isEmpty ? baseurl : baseurl.appendingPathComponent(path)
        var urlRequest = try URLRequest(url: url, method: method)
        if let multipartData  = multipartData {
            urlRequest.setValue(ContentType.mutliPart.rawValue, forHTTPHeaderField: HTTPHeaderField.contentType.rawValue)
        } else {
            urlRequest.setValue(ContentType.json.rawValue, forHTTPHeaderField: HTTPHeaderField.contentType.rawValue)
        }
        switch parameters {
        case .query(let request):
            let params = request?.toDictionary() ?? [:]
            let queryParams = params.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
            var components = URLComponents(string: url.absoluteString)
            components?.queryItems = queryParams
            urlRequest.url = components?.url
        case .body(let request):
            let params = request?.toDictionary() ?? [:]
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
        case .none:
            break
        }
        
        return urlRequest
    }


}
