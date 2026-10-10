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
    @Environment(\.scenePhase) private var scenePhase
    @State private var imageViewSize: CGSize = .zero
    @State private var cropArea: CGRect = .zero
    @State private var isPressOriginal = false

    var body: some View {
        ZStack {
            Color.background
            VStack(spacing: 0) {
                imageWithCropOverlay
                Spacer()
                
                sliderView
                    .padding(.horizontal)
                    .padding(.vertical, 4)
                    .transition(.opacity)
                    .opacity(store.isSliderVisible ? 1 : 0)
                
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
        .onChange(of: scenePhase) {old,new in
            switch new {
            case .background:
                store.send(.ttiRecord("ImageEditor","background"))
            case .active:
                store.send(.ttiRecord("ImageEditor","foreground"))

            default:
                print(new)
            }

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
            
            CustomSlider(value: $store.sliderValue, range: 0...1)
                .frame(height: 32)
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
        }.scrollTargetBehavior(.viewAligned)
            .frame(height: 96)
            
    }
    
    private func calculateInitialCropSize(viewSize: CGSize) -> CGFloat {
        min(viewSize.width, viewSize.height) * 0.8 // 뷰의 80% 크기로 설정
    }
    
    
}

