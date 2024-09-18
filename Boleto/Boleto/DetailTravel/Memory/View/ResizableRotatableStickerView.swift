//
//  ResizableRotatableStickerVIew.swift
//  Boleto
//
//  Created by Sunho on 8/27/24.
//

import SwiftUI

struct ResizableRotatableStickerView: View {
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
    @Binding var sticker: Sticker
    @State var text: String = ""
    @State private var lastScale: CGFloat = 1.0
    var eraseTap: () -> (Void)
    var body: some View {
        let size = CGSize(width: 80 * sticker.scale, height: 60 * sticker.scale)
        ZStack {
            Rectangle()
                .stroke(sticker.isSelected ? Color.white : Color.clear, lineWidth: 1)
                .frame(width: 80 * sticker.scale, height: 60 * sticker.scale)
                .rotationEffect(sticker.rotation)
                .position(sticker.position)
            if sticker.type == .bubble {
                Image("bubble")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80 * sticker.scale, height: 50 * sticker.scale)
                    .overlay {
                        TextField(text, text: $text)
                            .multilineTextAlignment(.center)
                            .font(.system(size: 11 * sticker.scale))
                            .offset(x: 0, y: -4 * sticker.scale)
                            .padding(.horizontal,4)
                    }
                    .rotationEffect(sticker.rotation)
                    .position(sticker.position)
//                BubbleView(text: $text, scale: sticker.scale, rotation: sticker.rotation, position: sticker.position, isSelected: sticker.isSelected)
            } else {
                Image(sticker.image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80 * sticker.scale, height: 60 * sticker.scale)
                    .rotationEffect(sticker.rotation)
                    .position(sticker.position)
            }
            if sticker.isSelected {
                Group {
                    makeEventStickerButton(.erase)
                        .position(buttonPosition(for: .topLeft, in: size))
                        .onTapGesture {
                            eraseTap()
                        }
                    makeEventStickerButton(.rotate )
                        .position(buttonPosition(for: .bottomLeft, in: size))
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let center = sticker.position
                                    let startVector = CGPoint(x: value.startLocation.x - center.x, y: value.startLocation.y - center.y)
                                    let currentVector = CGPoint(x: value.location.x - center.x, y: value.location.y - center.y)
                                    let angleDifference = atan2(currentVector.y, currentVector.x) - atan2(startVector.y, startVector.x)
                                    sticker.rotation = Angle(radians: angleDifference)
                                }
                        )
                    makeEventStickerButton(.resize)
                        .position(buttonPosition(for: .bottomRight, in: size))
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    print(value)
                                    let deltaX = value.translation.width / 80
                                    let deltaY = value.translation.height / 60
                                    let delta = max(deltaX, deltaY)
                                    sticker.scale = max(0.5, min(3.0, lastScale + delta))
                                }
                                .onEnded { _ in
                                    lastScale = sticker.scale
                                }
                        )
                    
                }
                
            }
        }
        
    }
    var resizeHandle: some View {
        Circle()
            .fill(Color.blue)
            .frame(width: 8, height: 8)
    }
    func makeEventStickerButton(_ event: StickerEvent) -> some View{
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
    func buttonPosition(for corner: Corner, in size: CGSize) -> CGPoint {
        let angle = sticker.rotation.radians
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
            x: sticker.position.x + rotatedX,
            y: sticker.position.y + rotatedY
        )
    }
    
    enum Corner {
        case topLeft, bottomLeft, bottomRight
    }
}


#Preview {
    ZStack {
        Color.black
        ResizableRotatableStickerView(sticker: .constant(Sticker(id:UUID(), image: "sticker1", position: CGPoint(x: 100, y: 100), type: .bubble, text: "hjfiqfjoiqjfoiqjfoiqjfoi"))) {
            print("erase")
        }
    }
}
