//
//  AuthRouter.swift
//  Boleto
//
//  Created by Sunho on 9/21/24.
//

import Foundation
import Alamofire
//
//enum AuthRouter {
//    case 
//}
enum CommonAPI {
    static let api = "http://3.37.140.217"
    static let sessionManager: Session = {
        
        let serverTrustPolices = ServerTrustManager(evaluators: ["3.37.140.217": DisabledTrustEvaluator()])

        let configuration = URLSessionConfiguration.af.default

        configuration.timeoutIntervalForRequest = 30

        return Session(configuration: configuration, serverTrustManager: serverTrustPolices)
    }()

//
//    static let customManager = CustomServerTrustManager(evaluators: [:])
//    static let configuration = URLSessionConfiguration.af.default
//    static let session = Session(configuration: configuration, serverTrustManager: customManager)
}
//class CustomServerTrustManager: ServerTrustManager {
//    override func serverTrustEvaluator(forHost host: String) throws -> ServerTrustEvaluating? {
//        return DisabledTrustEvaluator()
//    }
//}

