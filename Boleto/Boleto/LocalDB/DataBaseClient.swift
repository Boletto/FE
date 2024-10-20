//
//  DataBaseClient.swift
//  Boleto
//
//  Created by Sunho on 10/2/24.
//

import Foundation
import ComposableArchitecture
import SwiftData
@MainActor
let appContext: ModelContext = {
    let container = SwiftDataModelConfigurationProvider.shared.container
    let context = ModelContext(container)
    return context
}()

struct DataBaseClient {
    var context: () throws -> ModelContext
}
extension DataBaseClient: DependencyKey {
    @MainActor
    public static let liveValue = Self(context: {appContext})
}

extension DependencyValues {
    var databaseClient: DataBaseClient {
        get{ self[DataBaseClient.self]}
        set {self[DataBaseClient.self] = newValue}
    }
}
