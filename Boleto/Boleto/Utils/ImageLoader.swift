import UIKit
import Foundation

actor ImageLoader {
    static let shared = ImageLoader()
    private let cache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    private init() {
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB
        
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = paths[0].appendingPathComponent("ImageCache")
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    func loadImage(from url: URL, targetSize: CGSize? = nil) async throws -> UIImage {
        // 1. 메모리 캐시 확인
        if let cachedImage = cache.object(forKey: url.absoluteString as NSString) {
            return cachedImage
        }
        
        // 2. 디스크 캐시 확인
        if let diskCachedImage = try? loadFromDisk(url: url) {
            cache.setObject(diskCachedImage, forKey: url.absoluteString as NSString)
            return diskCachedImage
        }
        
        // 3. 네트워크에서 이미지 다운로드
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // 4. 이미지 다운샘플링
        let image = try await downsampleImage(data: data, targetSize: targetSize)
        
        // 5. 캐시에 저장
        cache.setObject(image, forKey: url.absoluteString as NSString)
        try? saveToDisk(image: image, url: url)
        
        return image
    }
    
    private func downsampleImage(data: Data, targetSize: CGSize?) async throws -> UIImage {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, imageSourceOptions) else {
            throw ImageError.invalidImageData
        }
        
        let maxDimension: CGFloat = targetSize?.width ?? 1024
        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimension
        ] as CFDictionary
        
        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else {
            throw ImageError.downsamplingFailed
        }
        
        return UIImage(cgImage: downsampledImage)
    }
    
    private func loadFromDisk(url: URL) throws -> UIImage? {
        let fileURL = cacheDirectory.appendingPathComponent(url.lastPathComponent)
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return UIImage(data: data)
    }
    
    private func saveToDisk(image: UIImage, url: URL) throws {
        let fileURL = cacheDirectory.appendingPathComponent(url.lastPathComponent)
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        try data.write(to: fileURL)
    }
    
    func clearCache() {
        cache.removeAllObjects()
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
}

enum ImageError: Error {
    case invalidImageData
    case downsamplingFailed
} 