//
//  SVGProcessor.swift
//  Boleto
//
//  Created by Sunho on 12/10/24.
//

import Kingfisher
import SVGKit

struct SVGProcessor: ImageProcessor {
    var identifier: String = "svgIdentifier"
    
    func process(item: ImageProcessItem, options: KingfisherParsedOptionsInfo) -> KFCrossPlatformImage? {
        switch item {
        case .image(let image):
            return image
        case .data(let data):
            return generateSVGImage(data: data) ?? DefaultImageProcessor().process(item: item, options: options)
        }
    }

}

private struct SVGCacheSerilalizer: CacheSerializer {
    func data(with image: KFCrossPlatformImage, original: Data?) -> Data? {
        return original
    }
    func image(with data: Data, options: KingfisherParsedOptionsInfo) -> KFCrossPlatformImage? {
        return  generateSVGImage(data: data) ?? image(with: data, options: options)
    }
}
private func generateSVGImage(data: Data) -> UIImage? {
    // SVGKImage를 사용하여 SVG 데이터를 처리하고 UIImage 객체로 변환합니다.
    guard let svgImage = SVGKImage(data: data) else { return nil }
    return svgImage.uiImage
}
