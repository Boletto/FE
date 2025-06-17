//
//  ResizableRotatableStickerVIew.swift
//  Boleto
//
//  Created by Sunho on 8/27/24.
//

import SwiftUI

struct ResizableRotatableStickerView<T: MemoryItemProtocol>: View {
    enum StickerEvent: CaseIterable {
        case erase
        case rotate
        case resize
        var imageString: String {
            switch self {
            case .erase:
                "xmark"
            case .resize:
                "arrow.down.backward.and.arrow.up.forward"
            case .rotate:
                "arrow.clockwise"
            }
        }
    }
    @Binding var sticker: T
    var editMode: Bool
    var eraseTap: () -> (Void)
    var onMove: (CGPoint) -> Void
    var onSelect: () -> Void
    @State var text: String = ""
    @State private var lastScale: CGFloat = 1.0
    let size = CGSize(width: 80, height: 60)
    @State private var localPosition: CGPoint = .zero
      @State private var localRotation: Angle = .zero
      @State private var localScale: CGFloat = 1.0
    
    var body: some View {
        
        ZStack {
            baseSticker
            if sticker.isSelected {
                Group {
                    makeEventStickerButton(.erase)
                        .position(buttonPosition(for: .topLeft, in: CGSize(width: size.width * sticker.scale, height: size.height * sticker.scale)))
                        .onTapGesture {
                            eraseTap()
                        }
                    makeEventStickerButton(.rotate )
                        .position(buttonPosition(for: .bottomLeft, in: CGSize(width: size.width * sticker.scale, height: size.height * sticker.scale)))
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let center = localPosition // localPosition 사용
                                                let startVector = CGPoint(x: value.startLocation.x - center.x, y: value.startLocation.y - center.y)
                                                let currentVector = CGPoint(x: value.location.x - center.x, y: value.location.y - center.y)
                                                let angleDifference = atan2(currentVector.y, currentVector.x) - atan2(startVector.y, startVector.x)
                                                localRotation = Angle(radians: angleDifference) // 로컬 상태 업데이트
                                }       .onEnded { _ in
                                    sticker.rotation = localRotation
                                }
                        )
                    makeEventStickerButton(.resize)
                        .position(buttonPosition(for: .bottomRight, in: CGSize(width: size.width * sticker.scale, height: size.height * sticker.scale)))
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let deltaX = value.translation.width / 80
                                    let deltaY = value.translation.height / 60
                                    let delta = max(deltaX, deltaY)
                                    sticker.scale = max(0.5, min(2.5, lastScale + delta))
                                }
                                .onEnded { _ in
                                    lastScale = sticker.scale
                                }
                        )
                }
            }
        }
        .onAppear {
                   localPosition = sticker.position
                   localRotation = sticker.rotation
                   localScale = sticker.scale
               }
        .onTapGesture {
            if editMode { onSelect()}
        }
        .gesture(
            DragGesture()
                           .onChanged { value in
                               if editMode {
                                   // 로컬 상태만 즉시 업데이트
                                   localPosition = value.location
                         
                               }
                           }
                           .onEnded { _ in
                               if editMode {
                                   // 드래그 완료시 즉시 업데이트
           
                                   onMove(localPosition)
                               }
                           }
        )
    }
    
    private var baseSticker: some View {
        ZStack {
            AsyncImageView(urlString: sticker.imageString, imagetype: .sticker)
                .scaledToFit()
                .frame(width: size.width * sticker.scale, height: size.height * sticker.scale)
//                .rotationEffect(localRotation) // 로컬 상태 사용
//                .position(localPosition) // 로컬 상태 사용
                .overlay(
                    sticker.isSelected ? Rectangle().stroke(Color.white, lineWidth: 1)
                        .frame(width: size.width * sticker.scale, height: size.height * sticker.scale)
                     : nil
                )
                .rotationEffect(localRotation) // 로컬 상태 사용
                .position(localPosition)
            if let speechItem = sticker as? SpeechItem {
                if sticker.isSelected {
                    TextField("", text: Binding(
                        get: { speechItem.text },
                        set: { newValue in
                            var updatedSpeechItem = speechItem
                            updatedSpeechItem.text = newValue
                            sticker = updatedSpeechItem as! T
                        }
                    ))
                    .multilineTextAlignment(.center)
                    .font(.system(size: 11 * sticker.scale))
                    .frame(width: size.width * sticker.scale)
                    .rotationEffect(sticker.rotation)
                    .offset(x: 0, y: -4 * sticker.scale)
                    .position(sticker.position)
                    .disabled(!sticker.isSelected) // 선택되지 않은 상태에서 비활성화
                } else {
                    // 캡쳐 중에는 Text로 전환
                    Text(speechItem.text)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 11 * sticker.scale))
                        .frame(width: size.width * sticker.scale)
                        .rotationEffect(sticker.rotation)
                        .offset(x: 0, y: -4 * sticker.scale)
                        .position(sticker.position)
                }
            }
        }
        
    }
    private var resizeHandle: some View {
        Circle()
            .fill(Color.blue)
            .frame(width: 8, height: 8)
    }
    private func makeEventStickerButton(_ event: StickerEvent) -> some View{
        ZStack {
            Circle()
                .frame(width: 24, height: 24)
                .foregroundStyle(.white)
            Image(systemName: event.imageString)
                .resizable()
                .foregroundStyle(event == .erase ? .red : .black)
                .frame(width: 14,height: 14)
        }
    }
    private func buttonPosition(for corner: Corner, in size: CGSize) -> CGPoint {
        let angle = localRotation.radians
        let dx = size.width / 2
        let dy = size.height / 2
        
        var x: CGFloat
        var y: CGFloat
        
        switch corner {
        case .topLeft:
            x = -dx
            y = -dy
        case .bottomLeft:
            x = -dx
            y = dy
        case .bottomRight:
            x = dx
            y = dy
        }
        
        let rotatedX = x * CGFloat(cos(angle)) - y * CGFloat(sin(angle))
        let rotatedY = x * CGFloat(sin(angle)) + y * CGFloat(cos(angle))
        
        return CGPoint(
              x: localPosition.x + rotatedX, 
              y: localPosition.y + rotatedY
          )
    }
    
    enum Corner {
        case topLeft, bottomLeft, bottomRight
    }
}


//#Preview {
//    ZStack {
//        Color.black
//        ResizableRotatableStickerView(sticker: .constant(Sticker(id:UUID(), image: "sticker1", position: CGPoint(x: 100, y: 100), type: .bubble, text: "hjfiqfjoiqjfoiqjfoiqjfoi"))) {
//            print("erase")
//        }
//    }
//}
