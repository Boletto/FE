//
//  StickerClient.swift
//  Boleto
//
//  Created by Sunho on 10/2/24.
//

import ComposableArchitecture
import SwiftData
import Foundation

@DependencyClient
struct StickerClient {
    var initializeBadges: @Sendable () throws -> Void
    var fetchMyBadges: @Sendable () throws -> [StickerImage]
    var updateCollectedBadges: @Sendable ([StickerImage]) throws -> Void
    var deleteAllBadges: () throws -> Void
    enum StickerDBError: Error {
        case add
        case fetch

    }
}
extension StickerClient: DependencyKey {
    
    public static let  liveValue = Self (
        initializeBadges: {
            do {
                @Dependency(\.databaseClient.context) var context
                let badgeContext = try context()
                let existingBadges = try badgeContext.fetch(FetchDescriptor<BadgeData>())
                if existingBadges.isEmpty {
                    for spot in Spot.allCases {
                        for badge in spot.landmarks {
                            let badgeData = BadgeData(
                                name: badge.badgetype.koreanString ,
                                imageName: badge.badgetype.rawValue,
                                latitude: badge.latitude,
                                longtitude: badge.longtitude,
                                isCollected: false
                            )
                            badgeContext.insert(badgeData)
                        }
                    }
                    try badgeContext.save()
                }
            } catch {
                print("Error in initializeBadges: \(error)")
                                throw StickerDBError.add
            }
        }, fetchMyBadges: {
            @Dependency(\.databaseClient.context) var context
            let badgeContext = try context()
            let descriptor = FetchDescriptor<BadgeData>(
                                predicate: #Predicate { badge in
                                    badge.isCollected == true
                                }
                            )
                            
                            // Fetch the collected badges and return their images
                            let collectedBadges = try badgeContext.fetch(descriptor)
            return collectedBadges.map { StickerImage(rawValue: $0.imageName) ?? .bubble }
        },
    updateCollectedBadges: { stickerTypes in
        @Dependency(\.databaseClient.context) var context
        let badgeContext = try context()
            for stickerType in stickerTypes {
                let imageNameToFind = stickerType.rawValue
                let descriptor = FetchDescriptor<BadgeData>(
                    predicate: #Predicate<BadgeData> { badge in
                        badge.imageName == imageNameToFind
                    }
                )

                
                if let existingBadge = try badgeContext.fetch(descriptor).first {
                    existingBadge.isCollected = true
                }
            }
            
            try badgeContext.save()
    }, deleteAllBadges:  {
        @Dependency(\.databaseClient.context) var context
        let badgeContext = try context()
        let existingBadges = try badgeContext.fetch(FetchDescriptor<BadgeData>())
                        if !existingBadges.isEmpty {
                             for badge in existingBadges {
                                 badgeContext.delete(badge)
                             }
                             try badgeContext.save()
                         }
    }
    
    )
}
extension DependencyValues{
    var stickerClient: StickerClient {
        get {self[StickerClient.self]}
        set {self[StickerClient.self] = newValue}
    }
}

