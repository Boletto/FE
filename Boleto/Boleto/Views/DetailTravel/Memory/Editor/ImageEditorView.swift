//
//  ImageEditorVIew.swift
//  Boleto
//
//  Created by Sunho on 1/3/25.
//

import Foundation
import SwiftUI
import ComposableArchitecture
import MetalKit

struct ImageEditorView: View {
    @Bindable  var store: StoreOf<ImageEditorFeature>
    @State private var imageViewSize: CGSize = .zero
    @State private var cropArea: CGRect = .zero
    @State private var isPressOriginal = false
    
    var body: some View {
        ZStack {
            Color.background
            VStack(spacing: 0) {
                imageWithCropOverlay
                Spacer()
                if  store.selectedFilter != nil {
                    sliderView
                        .padding(.horizontal)
                        .padding(.vertical, 4)
                        .transition(.opacity)
                }
                filterScrollView
                bottomBar
                    .padding(.horizontal, 8)
                    .padding(.bottom, 8)
            }
            VStack {
                HStack {
                    Spacer()
                    rollbackView
                        .padding(.top, 32)
                        .padding(.trailing, 16)
                }
                Spacer()
            }
        }
        .task {
            store.send(.fetchAllFilter)
        }
        
        
    }
    
    private var imageWithCropOverlay: some View {
        Image(uiImage: isPressOriginal ? store.originalImage : store.filteredImage ?? store.originalImage)
            .resizable()
            .scaledToFit()
            .overlay(alignment: .topLeading) {
                GeometryReader { imageGeo in
                    let size = calculateInitialCropSize(viewSize: imageGeo.size)
                    CropBoxView(rect: $cropArea)
                        .onAppear {
                            self.imageViewSize = imageGeo.size
                            self.cropArea = CGRect(
                                x: (imageGeo.size.width - size) / 2,
                                y: (imageGeo.size.height - size) / 2,
                                width: size,
                                height: size
                            )
                        }
                        .onChange(of: imageGeo.size) { old, new in
                            self.imageViewSize = new
                            let newSize = calculateInitialCropSize(viewSize: new)
                            self.cropArea = CGRect(
                                x: (new.width - newSize) / 2,
                                y: (new.height - newSize) / 2,
                                width: newSize,
                                height: newSize
                            )
                        }
                }
            }
            .padding()
    }
    private var sliderView: some View {
        VStack(spacing: 4) {
            HStack {
                Text(store.selectedFilter?.name ?? "")
                    .font(.caption)
                    .foregroundStyle(.white)
                Spacer()
                Text("\(Int(store.sliderValue * 100))")
                    .font(.caption)
                    .foregroundStyle(.white)
            }
            
            Slider(value: $store.sliderValue, in: 0...1,step: 0.01)
                .tint(Color.blue)
        }
    }
    private var rollbackView: some View {
        Image(systemName: "arrow.uturn.left.square")
            .resizable()
            .frame(width: 16, height: 16)
            .foregroundStyle(.white)
            .padding(8)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        isPressOriginal = true
                    }
                    .onEnded { _ in
                        isPressOriginal = false
                    }
            )
    }
    
    private var bottomBar: some View {
        HStack {
            Button {
                store.send(.dismiss)
            } label: {
                Image(systemName: "xmark")
                    .foregroundStyle(.white)
            }
            Spacer()
            Button {
                store.send(.doCropImage(cropArea, imageViewSize))
            } label: {
                Image(systemName: "checkmark")
                    .foregroundStyle(.white)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 30)
    }
    
    private var filterScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ScrollViewReader { proxy in
                LazyHStack(spacing: 8) {
                    Spacer()
                        .frame(width: 8)
                        .layoutPriority(-1)
                    ForEach(store.allfilters) { filter in
                        let isSelected = store.selectedFilter == filter
                        FilterItem(filter: filter.name, thumbNail: store.thumbnails[filter], isSelected: isSelected,onTap: {
                            store.send(.selectFilter(filter))
                        })
                        .frame(width: 56, height: 56)
                        .id(filter.id)
                    }
                }
                .onChange(of: store.selectedFilter) { _, newValue in
                    if let filter = newValue {
                        withAnimation {
                            proxy.scrollTo(filter.id, anchor: .center)
                        }
                    }
                }
            }
        }.frame(height: 96)
    }
    
    private func calculateInitialCropSize(viewSize: CGSize) -> CGFloat {
        min(viewSize.width, viewSize.height) * 0.8 // 뷰의 80% 크기로 설정
    }
    
    
}
//#Preview {
//    let sampleImage = UIImage(systemName: "photo.fill") ?? UIImage()
//    ImageEditorView(store: StoreOf<ImageEditorFeature, imageViewSize: <#T##CGSize#>, cropArea: <#T##CGRect#>, isPressOriginal: <#T##arg#>)
//}
struct MetalFilterView: UIViewRepresentable {
    let image: UIImage
    let filterType: String
    @Binding var intensity: Float
    let onTextureReady: (MTLTexture) -> Void
    
    func makeUIView(context: Context) -> MTKView {
        let view = MTKView()
        view.device = MTLCreateSystemDefaultDevice()
        view.delegate = context.coordinator
        context.coordinator.setupMetal(view: view, image: image, filterType: filterType)
        return view
    }
    
    func updateUIView(_ uiView: MTKView, context: Context) {
        context.coordinator.updateIntensity(intensity)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(intensity: $intensity, onTextureReady: onTextureReady)
    }
    
    class Coordinator: NSObject, MTKViewDelegate {
        private var device: MTLDevice!
        private var commandQueue: MTLCommandQueue!
        private var computePipelineState: MTLComputePipelineState?
        private var inputTexture: MTLTexture?
        private var intensity: Float
        private let onTextureReady: (MTLTexture) -> Void
        
        init(intensity: Binding<Float>, onTextureReady: @escaping (MTLTexture) -> Void) {
            self.intensity = intensity.wrappedValue
            self.onTextureReady = onTextureReady
            super.init()
        }
        
        func setupMetal(view: MTKView, image: UIImage, filterType: String) {
            device = view.device!
            commandQueue = device.makeCommandQueue()
            let library = device.makeDefaultLibrary()
            let function = library?.makeFunction(name: filterType)
            computePipelineState = try? device.makeComputePipelineState(function: function!)
            
            let textureLoader = MTKTextureLoader(device: device)
            do {
                inputTexture = try textureLoader.newTexture(cgImage: image.cgImage!, options: nil)
            } catch {
                print("Failed to load texture: \(error)")
            }
        }
        
        func updateIntensity(_ newIntensity: Float) {
            intensity = newIntensity
        }
        
        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
        
        func draw(in view: MTKView) {
            guard let drawable = view.currentDrawable,
                  let commandBuffer = commandQueue.makeCommandBuffer(),
                  let computeEncoder = commandBuffer.makeComputeCommandEncoder(),
                  let pipelineState = computePipelineState,
                  let inputTex = inputTexture else { return }
            
            computeEncoder.setComputePipelineState(pipelineState)
            computeEncoder.setTexture(inputTex, index: 0)
            computeEncoder.setTexture(drawable.texture, index: 1)
            var intensityValue = intensity
            computeEncoder.setBytes(&intensityValue, length: MemoryLayout<Float>.size, index: 0)
            
            let threadgroupSize = MTLSize(width: 16, height: 16, depth: 1)
            let threadgroupCount = MTLSize(
                width: (inputTex.width + threadgroupSize.width - 1) / threadgroupSize.width,
                height: (inputTex.height + threadgroupSize.height - 1) / threadgroupSize.height,
                depth: 1
            )
            
            computeEncoder.dispatchThreadgroups(threadgroupCount, threadsPerThreadgroup: threadgroupSize)
            computeEncoder.endEncoding()
            
            commandBuffer.present(drawable)
            commandBuffer.commit()
            
            onTextureReady(drawable.texture)
        }
    }
}
