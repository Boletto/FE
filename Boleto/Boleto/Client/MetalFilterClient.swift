//
//  MetalFilterClient.swift
//  Boleto
//
//  Created by Sunho on 4/16/25.
//

import Foundation
import ComposableArchitecture
import UIKit
import MetalKit

@DependencyClient
struct MetalFilterClient {
    var applyFilter: @Sendable (UIImage, String, Float) async throws -> UIImage
    var getAllFilters: @Sendable () async throws -> [Filter]
    var setupFilter: @Sendable (UIImage, String) async throws -> Void
    var updateIntensity: @Sendable (Float) async throws -> UIImage
}

extension MetalFilterClient: DependencyKey {
    static let liveValue: Self = {
        let sharedService = MetalFilterRenderService()
        class FilterCache {
            static var cachedFilters: [Filter]? = nil
        }
        return Self(
            applyFilter: { image, filterType, intensity in
                await sharedService.applyFilter(image, filterType: filterType, intensity: intensity)
            },
            getAllFilters: {
                if let cached = FilterCache.cachedFilters {
                    return cached
                }
                guard let url = Bundle.main.url(forResource: "filters", withExtension: "json"),
                      let data = try? Data(contentsOf: url),
                      let response = try? JSONDecoder().decode(FiltersResponse.self, from: data) else {
                    return []
                }
                let filters = response.filters.map { $0.toDomain() }
                FilterCache.cachedFilters = filters
                return filters
            },
            setupFilter: { image, filterType in
                 try await sharedService.setupFilter(image, filtertype: filterType)
            },
            updateIntensity: { intensity in
                await sharedService.updateIntensity(intensity)
            }
            
        )
    }()
    //
    //    static let testValue = Self(
    //        applyFilter: { image, _, _ in
    //            // 필터 없이 원본 이미지 반환
    //            return image
    //        }
    //    )
    //
    //    static let previewValue = Self(
    //        applyFilter: { image, filterType, intensity in
    //            // 간단한 미리보기용 구현 (예: 명도만 조정)
    //            return image
    //        }
    //    )
}

extension DependencyValues {
    var metalFilterClient: MetalFilterClient {
        get { self[MetalFilterClient.self] }
        set { self[MetalFilterClient.self] = newValue }
    }
}
