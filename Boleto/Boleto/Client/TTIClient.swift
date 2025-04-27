//
//  AnalysisClient.swift
//  Boleto
//
//  Created by Sunho on 4/22/25.
//

import Foundation
import ComposableArchitecture

@DependencyClient
struct TTIClient {
    var postEvent: @Sendable (String, String) async throws -> Void
}

extension TTIClient: DependencyKey {
    static var liveValue: TTIClient = {
        return Self(
            postEvent: { actionType, actionDetails in
                let data = try await NetworkManager.request(endpoint: AnalysisRouter.postEvent(TTIRequest(actionType: actionType, actionDetail: actionDetails)), responseType: EmptyData.self)
                print(data)
                
            }
        )
        
    }()
}
extension DependencyValues {
    var ttiClient: TTIClient {
        get { self[TTIClient.self]}
        set {self[TTIClient.self] = newValue}
    }
}
