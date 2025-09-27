//
//  TTIClient.swift
//  Boleto
//
//  Created by Sunho on 4/22/25.
//

import Foundation
import ComposableArchitecture
import FirebaseAnalytics

@DependencyClient
struct TTIClient {
    var logEvent: @Sendable (String, String) -> Void
}

extension TTIClient: DependencyKey {
    static var liveValue: TTIClient = {
        return Self(
            logEvent: { eventName, details in
                Analytics.logEvent(eventName, parameters: [
                    "screen": eventName,
                    "action": details,
                    "timestamp": Date().timeIntervalSince1970
                ])
            }
        )
    }()
}
extension TTIClient: TestDependencyKey {
    static let testValue = Self(
        logEvent: { _, _ in
            // Empty implementation for testing
        }
    )
}
extension DependencyValues {
    var ttiClient: TTIClient {
        get { self[TTIClient.self]}
        set {self[TTIClient.self] = newValue}
    }
}
