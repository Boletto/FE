//
//  ImageLoader.swift
//  Boleto
//
//  Created by Sunho on 4/13/25.
//
import UIKit

actor ImageLoader {
    static let shared = ImageLoader()
    //메모리캐시
    private let cache = NSCache<NSString, UIImage>()
    //디스크캐시
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    private let maxUnusedPeriod: TimeInterval = 24 * 60 * 60
    private let maxDiskCacheSize: UInt = 200 * 1024 * 1024 // 200MB
    private let lastUsedDateKey = "ImageLoader.lastUsedDate"

    private init() {
        UserDefaults.standard.set(Date(), forKey: lastUsedDateKey)
        cache.countLimit = 100 // 메모리 캐시 제한
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB
        
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = paths[0].appendingPathComponent("ImageCache")
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)

    }
    func updateLatestaccesstime() {
        UserDefaults.standard.set(Date(), forKey: lastUsedDateKey)
    }
    
    func checkInactiveTime() async {
        if let lastActiveTime = UserDefaults.standard.object(forKey: lastUsedDateKey) as? Date {
            let inactiveTime = Date().timeIntervalSince(lastActiveTime)
            
            // 마지막 활성 시간으로부터 24시간 이상 지났으면 캐시 전체 삭제
            if inactiveTime >= maxUnusedPeriod {
                print("앱이 24시간 이상 비활성 상태였습니다. 캐시를 모두 삭제합니다.")
                await clearCache()
            }
        }
    }

    
    
    func loadImage(from url: URL, targetSize: CGSize? = nil, isSticker: Bool = false) async throws -> UIImage {
        if let cachedImage = cache.object(forKey: url.absoluteString as NSString) {
            return cachedImage
        }
        
        if let diskCachedImage = try? loadFromDisk(url: url) {
            cache.setObject(diskCachedImage, forKey: url.absoluteString as NSString)
            return diskCachedImage
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let image: UIImage
        if let targetSize = targetSize {
            // targetSize가 있을 때만 다운샘플링
            image = try await downsampleImage(data: data, targetSize: targetSize)
        } else {
            guard let originalImage = UIImage(data: data) else {
                throw ImageError.invalidImageData
            }
            image = originalImage
        }
        
        cache.setObject(image, forKey: url.absoluteString as NSString)
        try? saveToDisk(image: image, url: url, isSticker: isSticker)
        
        return image
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
                        let image = try await self.loadImage(from: frameUrl,targetSize: CGSize(width: 1024,height: 1024))
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
                    let image = try await self.loadImage(from: url,targetSize: CGSize(width: 640,height: 640))
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
    private func saveToDisk(image: UIImage, url: URL, isSticker: Bool = false) throws {
        let fileURL = cacheDirectory.appendingPathComponent(url.lastPathComponent)
        let data: Data?
        if isSticker {
            data = image.pngData() // PNG 형식으로 저장 (투명도 유지)
        } else {
            data = image.jpegData(compressionQuality: 0.8) // JPEG 형식으로 저장 (용량 절약)
        }
        
        guard let imageData = data else { return }
        try imageData.write(to: fileURL)
        try fileManager.setAttributes([.modificationDate: Date()], ofItemAtPath: fileURL.path)
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
        try? fileManager.setAttributes([.modificationDate: Date()], ofItemAtPath: fileURL.path)
        return UIImage(data: data)
    }
    
    
    
    func clearCache() async {
        cache.removeAllObjects()
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    

}
