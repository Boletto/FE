//
//  MetalFilterRenderService.swift
//  Boleto
//
//  Created by Sunho on 4/20/25.
//
import MetalKit
import Foundation

final class MetalFilterRenderService {
    private let device: MTLDevice = MTLCreateSystemDefaultDevice()!
    private let commandQueue: MTLCommandQueue!
    private var defaultLibrary: MTLLibrary!
    private var pipeLineStateCache = PipelineCache()
    
    private var currentImage: UIImage?
    private var currentFilter: String?
    private var preparedTexture: MTLTexture?
    private var preparedPipelineState: MTLComputePipelineState?
    private let ciContext: CIContext

    
    init() {
        self.commandQueue = device.makeCommandQueue()
        self.defaultLibrary = device.makeDefaultLibrary()
        self.ciContext = CIContext(mtlDevice: device, options: [.workingColorSpace: CGColorSpace(name: CGColorSpace.sRGB)!])
    }
    
    func setupFilter(_ image: UIImage, filtertype: String) async throws {
        self.currentImage = image
       self.currentFilter = filtertype
       self.preparedTexture = await makeMTLTexture(from: image)
       self.preparedPipelineState = try await getPipelineState(for: filtertype)
    }
    
    func updateIntensity(_ intensity: Float) async -> UIImage {
            guard let inputTexture = preparedTexture,
                  let pipelineState = preparedPipelineState,
                  let originalImage = currentImage else {
                return currentImage ?? UIImage()
            }
            return await applyFilterInternal(inputTexture: inputTexture, pipelineState: pipelineState, intensity: intensity, originalImage: originalImage)
        }
    func applyFilter(_ image: UIImage, filterType: String, intensity: Float) async -> UIImage {
            do {
                try await setupFilter(image, filtertype: filterType)
                guard let inputTexture = preparedTexture,
                      let pipelineState = preparedPipelineState else {
                    return image
                }
                return await applyFilterInternal(inputTexture: inputTexture, pipelineState: pipelineState, intensity: intensity, originalImage: image)
            } catch {
                print("🔴 필터 적용 실패: \(error.localizedDescription)")
                return image
            }
        }
    private func applyFilterInternal(inputTexture: MTLTexture, pipelineState: MTLComputePipelineState, intensity: Float, originalImage: UIImage) async -> UIImage {
            let startTime = CACurrentMediaTime()
            guard let outputTexture = createOutputTexture(matching: inputTexture) else {
                return originalImage
            }
            
//            guard applyMetalFilter(inputTexture: inputTexture, outputTexture: outputTexture, pipelineState: pipelineState, intensity: intensity) else {
//                return originalImage
//            }
            
        // Use async GPU processing instead of synchronous
                let filteredImage = await withCheckedContinuation { continuation in
                    applyMetalFilterAsync(
                        inputTexture: inputTexture,
                        outputTexture: outputTexture,
                        pipelineState: pipelineState,
                        intensity: intensity
                    ) { success in
                        if success {
                            if let image = self.convertTextureToUIImage(outputTexture, filterImage: originalImage) {
                                continuation.resume(returning: image)
                            } else {
                                continuation.resume(returning: originalImage)
                            }
                        } else {
                            continuation.resume(returning: originalImage)
                        }
                    }
                }
            
            let endTime = CACurrentMediaTime()
            print("필터 적용 완료: \(endTime - startTime) 초 소요")
            return filteredImage
        }
    

    private func createOutputTexture(matching inputTexture: MTLTexture) -> MTLTexture? {
            let descriptor = MTLTextureDescriptor.texture2DDescriptor(
                pixelFormat: inputTexture.pixelFormat,
                width: inputTexture.width,
                height: inputTexture.height,
                mipmapped: false
            )
            descriptor.usage = [.shaderRead, .shaderWrite]
        descriptor.storageMode = .shared
            return device.makeTexture(descriptor: descriptor)
        }
    private func makeMTLTexture(from image: UIImage) async -> MTLTexture? {
          guard let cgImage = image.cgImage else { return nil }
          
          let textureLoader = MTKTextureLoader(device: device)
          let options: [MTKTextureLoader.Option: Any] = [
              .SRGB: true,
              .generateMipmaps: false,
              .textureStorageMode: NSNumber(value: MTLStorageMode.private.rawValue)
          ]
          
          do {
              return try await textureLoader.newTexture(cgImage: cgImage, options: options)
          } catch {
              print("Failed to create texture: \(error)")
              return nil
          }
      }
    private func getPipelineState(for functionName: String) async throws -> MTLComputePipelineState {
        if let cachedState = await pipeLineStateCache.get(functionName) {
            return cachedState
        }
        
        guard let function = defaultLibrary.makeFunction(name: functionName) else {
            throw NSError(domain: "MetalFilterError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Function not found: \(functionName)"])
        }
        
        let newPipelineState = try await device.makeComputePipelineState(function: function)
        await pipeLineStateCache.set(functionName, value: newPipelineState)
        return newPipelineState
    }
    private func applyMetalFilterAsync(
            inputTexture: MTLTexture,
            outputTexture: MTLTexture,
            pipelineState: MTLComputePipelineState,
            intensity: Float,
            completion: @escaping (Bool) -> Void
        ) {
            guard let commandBuffer = commandQueue.makeCommandBuffer(),
                  let encoder = commandBuffer.makeComputeCommandEncoder() else {
                completion(false)
                return
            }
            
            encoder.setComputePipelineState(pipelineState)
            encoder.setTexture(inputTexture, index: 0)
            encoder.setTexture(outputTexture, index: 1)
            
            var intensityValue = intensity
            encoder.setBytes(&intensityValue, length: MemoryLayout<Float>.size, index: 0)
            
            // Optimize thread group size based on texture dimensions
            let w = pipelineState.threadExecutionWidth
            let h = pipelineState.maxTotalThreadsPerThreadgroup / w
            let threadGroupSize = MTLSize(width: w, height: h, depth: 1)
            
            let threadGroupCount = MTLSize(
                width: (inputTexture.width + threadGroupSize.width - 1) / threadGroupSize.width,
                height: (inputTexture.height + threadGroupSize.height - 1) / threadGroupSize.height,
                depth: 1
            )
            
            encoder.dispatchThreadgroups(threadGroupCount, threadsPerThreadgroup: threadGroupSize)
            encoder.endEncoding()
            
            // Use completion handler instead of waitUntilCompleted
            commandBuffer.addCompletedHandler { _ in
                completion(true)
            }
            
            commandBuffer.commit()
        }
    
    private func convertTextureToUIImage(_ texture: MTLTexture, filterImage: UIImage) -> UIImage? {
        guard let ciImage = CIImage(mtlTexture: texture) else {
            return nil
        }
        
     
        
        guard let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent) else {
                    return nil
                }
        
        return UIImage(cgImage: cgImage,
                       scale: filterImage.scale,
                       orientation: filterImage.imageOrientation)
    }

}
actor PipelineCache {
    private var pipeLineStateCache: [String: MTLComputePipelineState] = [:]
    
    func get(_ key: String) -> MTLComputePipelineState? {
        pipeLineStateCache[key]
    }
    
    func set(_ key: String, value: MTLComputePipelineState) {
        pipeLineStateCache[key] = value
    }
}
