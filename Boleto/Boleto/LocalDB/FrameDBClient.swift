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
    var updateFrame: @Sendable ([FrameData]) async throws-> Void
    var deleteAllFrames: () -> Void
    var saveCollectFrame: @Sendable (FrameData) -> Void
    var hasFrame: @Sendable  (FrameData) async throws -> Bool
    var isEmpty: @Sendable () async throws -> Bool
}
extension FrameDBClient: DependencyKey {
    public static let liveValue = Self (
        updateFrame:  { newDatas in
            do {
                @Dependency(\.databaseClient.context) var context
                let dbcontext = try context()
                for data in newDatas {
                    dbcontext.insert(data)
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
        }, saveCollectFrame:  {data in
            do {
                @Dependency(\.databaseClient.context) var context
                let dbcontext = try context()
                dbcontext.insert(data)
                try dbcontext.save()
            } catch {
                print("Error in updateFrame: \(error)")
            }
        }, hasFrame: { framedata in
            do {
                @Dependency(\.databaseClient.context) var context
                let dbcontext = try context()
                let findFrame = framedata.frameURL
                let request = FetchDescriptor<FrameData>(predicate: #Predicate<FrameData> { $0.frameURL == findFrame})
                let existingFrames = try dbcontext.fetch(request)
                return !existingFrames.isEmpty
            } catch {
                print("Error in hasFrame: \(error)")
                return false
            }
            
        }, isEmpty:  {
            @Dependency(\.databaseClient.context) var context
            let dbcontext = try context()
            let request = FetchDescriptor<FrameData>()
              let isexist = try dbcontext.fetch(request)
            return isexist.isEmpty
        }
    )
}

extension DependencyValues{
    var frameDBClient: FrameDBClient {
        get {self[FrameDBClient.self]}
        set {self[FrameDBClient.self] = newValue}
    }
}

