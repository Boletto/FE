//
//  ImageLoader.swift
//  Boleto
//
//  Created by Sunho on 4/13/25.
//
import UIKit

actor ImageLoader {
    private var imageAccessTimes: [String: Date] = [:]
    static let shared = ImageLoader()
    //메모리캐시
    private let cache = NSCache<NSString, UIImage>()
    //디스크캐시
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    private let maxUnusedPeriod: TimeInterval = 24 * 60 * 60
    private let maxDiskCacheSize: Int64 = 200 * 1024 * 1024 // 200MB
    
    private init() {
        cache.countLimit = 100 // 메모리 캐시 제한
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB
        
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = paths[0].appendingPathComponent("ImageCache")
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        
    }
    
    func loadImage(from url: URL, imageType: AsyncImageType) async throws -> UIImage {
        let key = url.absoluteString
        imageAccessTimes[key] = Date()
        if let cachedImage = cache.object(forKey: key as NSString) {
            return cachedImage
        }
        
        
        if let diskCachedImage = try? loadFromDisk(url: url) {
            
            updateFileAccessTime(for: url)
            switch imageType {
            case .sticker:
                
                cache.setObject(diskCachedImage, forKey: key as NSString)
                print("→ 스티커이므로 메모리에 저장")
            case .image, .fourCut:
                
                break
            }
            return diskCachedImage
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let image: UIImage
        switch imageType {
        case .image:
            image = try await downsampleImage(data: data, maxDimension: 2048)
        case .sticker:
            image = try await downsampleImage(data: data, maxDimension: 512)
        case .fourCut:
            image = try await downsampleImage(data: data, maxDimension: 1024)
        }
        
        switch imageType {
        case .sticker:
            // 스티커: 메모리 + 디스크 둘 다 저장
            cache.setObject(image, forKey: key as NSString)
            try? saveToDisk(image: image, url: url, imageType: imageType)
        case .image, .fourCut:
            // 일반 이미지/네컷: 디스크만 저장
            try? saveToDisk(image: image, url: url, imageType: imageType)
        }
        return image
    }
    private func updateFileAccessTime(for url: URL) {
        let fileURL = cacheDirectory.appendingPathComponent(url.lastPathComponent)
        try? fileManager.setAttributes([.modificationDate: Date()],
                                       ofItemAtPath: fileURL.path)
    }
    func loadFourCutImages(frameUrl: String, imageUrls: [String]) async throws -> (UIImage?, [UIImage]) {
        var frameImage: UIImage? = nil
        var images: [UIImage] = Array(repeating: UIImage(), count: imageUrls.count)
        guard let frameUrl = URL(string: frameUrl) else {
            throw ImageError.invalidURL
        }
        try await withThrowingTaskGroup(of: (Int, UIImage).self) { group in
            // 프레임 이미지 로드 (인덱스 -1)
            group.addTask {
                do {
                    let image = try await self.loadImage(from: frameUrl,imageType: .fourCut(urls: imageUrls, isLargeMode: false))
                    return (-1, image)
                } catch {
                    throw error
                }
            }
            
            // 네컷 이미지 병렬 로드
            for (index, urlString) in imageUrls.enumerated() {
                guard let url = URL(string: urlString) else {
                    throw ImageError.invalidURL
                }
                group.addTask {
                    let image = try await self.loadImage(from: url, imageType: .fourCut(urls: imageUrls, isLargeMode: false))
                    return (index, image)
                    
                }
            }
            // 결과 처리
            for try await (index, image) in group {
                if index == -1 {
                    frameImage = image
                } else if index >= 0 && index < images.count {
                    images[index] = image
                }
            }
        }
        
        return (frameImage, images)
    }
    private func saveToDisk(image: UIImage, url: URL, imageType: AsyncImageType) throws {
        let fileURL = cacheDirectory.appendingPathComponent(url.lastPathComponent)
        let data: Data?
        switch imageType {
        case .image:
            data = image.jpegData(compressionQuality: 0.9)
        case .sticker:
            data = image.pngData()
        case .fourCut:
            data = image.jpegData(compressionQuality: 0.8)
        }
        guard let imageData = data else { return }
        let newImageSize = Int64(imageData.count)
        let currentSize = calculateCurrentDiskSize()
          let futureSize = currentSize + newImageSize
        if futureSize > maxDiskCacheSize {
             let excessSize = futureSize - maxDiskCacheSize + (5 * 1024 * 1024) // 5MB 여유
//             try performSmartCleanup(targetRemovalSize: excessSize, excludeType: imageType)

         }
        try imageData.write(to: fileURL)
        try fileManager.setAttributes([.modificationDate: Date()], ofItemAtPath: fileURL.path)
    }
    private func calculateCurrentDiskSize() -> Int64 {
        guard let fileURLs = try? fileManager.contentsOfDirectory(
            at: cacheDirectory,
            includingPropertiesForKeys: [.fileSizeKey]
        ) else { return 0 }
        
        return fileURLs.compactMap { url -> Int64? in
            guard let resourceValues = try? url.resourceValues(forKeys: [.fileSizeKey]),
                  let fileSize = resourceValues.fileSize else { return nil }
            return Int64(fileSize)
        }.reduce(0, +)
    }
    private func downsampleImage(data: Data, maxDimension: CGFloat) async throws -> UIImage {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, imageSourceOptions) else {
            throw ImageError.invalidImageData
        }
        
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
        try? fileManager.setAttributes([.modificationDate: Date()], ofItemAtPath: fileURL.path)
        return UIImage(data: data)
    }
    
    
    
    func cleanupOldImages() async {
        let now = Date()
        
        guard let fileURLs = try? fileManager.contentsOfDirectory(
            at: cacheDirectory,
            includingPropertiesForKeys: [.contentModificationDateKey]
        ) else { return }
        
        for fileURL in fileURLs {
            if let modificationDate = try? fileURL.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate {
                let timeSinceLastAccess = now.timeIntervalSince(modificationDate)
                
                // 24시간 이상 된 파일 삭제
                if timeSinceLastAccess > maxUnusedPeriod {
                    try? fileManager.removeItem(at: fileURL)
                    // 메모리 캐시에서도 제거
                    let fileName = fileURL.lastPathComponent
                    cache.removeObject(forKey: fileName as NSString)
                }
            }
        }
    }
    
    
}
