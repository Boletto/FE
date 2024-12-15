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
    var updateFrame: @Sendable ([FrameData]) -> Void
    var deleteAllFrames: () -> Void
    var saveCollectFrame: @Sendable (FrameData) -> Void
    var getEventFrame: @Sendable  () async throws-> Void
}
extension FrameDBClient: DependencyKey {
    public static let liveValue = Self (
        updateFrame:  { newDatas in
            do {
                @Dependency(\.databaseClient.context) var context
                let dbcontext = try context()
                let existingFrames = try dbcontext.fetch(FetchDescriptor<FrameData>())
                for frame in existingFrames {
                    dbcontext.delete(frame)
                }
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
        }, getEventFrame: {
            do {
                @Dependency(\.databaseClient.context) var context
                let dbcontext = try context()
                let result = try await NetworkManager.request(endpoint: SystemRouter.getAllFrames(isEvent: true), responseType: GeneralResponse<[FrameResponse]>.self)
                guard let frames = result.data else  {throw CustomError.invalidResponse }
                for eventFrame in frames {
                    let frameData = FrameData(frameURL: eventFrame.frameUrl, frameCode: eventFrame.frameCode, frameType: eventFrame.frameType)
                    dbcontext.insert(frameData)
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

