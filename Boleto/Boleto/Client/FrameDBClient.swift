//
//  FrameDBClient.swift
//  Boleto
//
//  Created by Sunho on 10/3/24.
//

import Foundation
import ComposableArchitecture
import SwiftData
@DependencyClient
struct FrameDBClient {
    var updateFrame: @Sendable ([String]) -> Void
    var deleteAllFrames: () -> Void
}
extension FrameDBClient: DependencyKey {
    public static let liveValue = Self (
        updateFrame:  { newURLs in
            do {
                @Dependency(\.databaseClient.context) var context
                let dbcontext = try context()
                let existingFrames = try dbcontext.fetch(FetchDescriptor<FrameData>())
                for frame in existingFrames {
                    dbcontext.delete(frame)
                              }
                for newURL in newURLs {
                    dbcontext.insert(FrameData(frameURL: newURL))
                             }
                
                try dbcontext.save()
            } catch {
                print("Error in updateFrame: \(error)")
            }
            
       
        }, deleteAllFrames: {
            do {
                @Dependency(\.databaseClient.context) var context
                let dbcontext = try context()
                let existingFrames = try dbcontext.fetch(FetchDescriptor<FrameData>())
                for frame in existingFrames {
                    dbcontext.delete(frame)
                              }
                try dbcontext.save()
            } catch {
                print("Error in updateFrame: \(error)")
            }
        }
    )
}

extension DependencyValues{
    var frameDBClient: FrameDBClient {
        get {self[FrameDBClient.self]}
        set {self[FrameDBClient.self] = newValue}
    }
}

