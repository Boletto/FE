//
//  CropBoxView.swift
//  Boleto
//
//  Created by Sunho on 1/3/25.
//

import Foundation
import SwiftUI

struct CropBoxView: View {
    @Binding var rect: CGRect
    private let minSize: CGFloat = 100
    @State private var initialRect:CGRect? = nil
    @State private var frameSize: CGSize = .zero
    @State private var draggedCorner: UIRectCorner? = nil
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            darkenedOverlay
            box
        }
        .background {
            GeometryReader { geometry in
                Color.clear
                    .onAppear {self.frameSize = geometry.size}
                    .onChange(of: geometry.size) {oldvalue, newvalue in
                        self.frameSize = newvalue}
            }
        }
    }
    
    private var rectDragGesture: some Gesture {
        DragGesture()
            .onChanged { gesture in
                if initialRect == nil {
                    initialRect = rect
                    draggedCorner = closestCorner(point: gesture.startLocation, rect: rect)
                }
                if let draggedCorner {
                    resizeBox(draggedCorner: draggedCorner, translation: gesture.translation)
                } else {
                    self.rect = drag(initialRect: initialRect!, frameSize: frameSize, translation: gesture.translation)
                }
            }
            .onEnded { _ in
                initialRect = nil
                draggedCorner = nil
            }
    }
    
    private var darkenedOverlay: some View {
        Color.black.opacity(0.5)
            .overlay(alignment: .topLeading) {
                Color.clear
                    .frame(width: rect.width, height: rect.height)
                    .offset(x: rect.origin.x, y: rect.origin.y)
            }
            .compositingGroup()
            .luminanceToAlpha()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    private var box: some View {
        ZStack {
            gridLines
            cornerHandle(.topLeft)
            cornerHandle(.topRight)
            cornerHandle(.bottomLeft)
            cornerHandle(.bottomRight)
        }
        .border(.gray2, width: 1)
        .background(Color.white.opacity(0.01))
        .frame(width: rect.width,height: rect.height)
        .offset(x: rect.origin.x, y: rect.origin.y)
        .gesture(rectDragGesture)
    }
    
    private var gridLines: some View {
        ZStack {
            HStack {
                Spacer()
                Rectangle().frame(width: 1).frame(maxHeight: .infinity)
                Spacer()
                Rectangle().frame(width: 1).frame(maxHeight: .infinity)
                Spacer()
            }
            VStack {
                Spacer()
                Rectangle().frame(height: 1).frame(maxWidth: .infinity)
                Spacer()
                Rectangle().frame(height: 1).frame(maxWidth: .infinity)
                Spacer()
            }
        }
        .foregroundColor(.white.opacity(0.5))
    }
    
    private func cornerHandle(_ corner: UIRectCorner) -> some View {
        Path { path in
            let lineLength: CGFloat = 12
            
            switch corner {
            case .topLeft:
                path.move(to: CGPoint(x: 0, y: lineLength))
                path.addLine(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: lineLength, y: 0))
            case .topRight:
                path.move(to: CGPoint(x: rect.width, y: lineLength))
                path.addLine(to: CGPoint(x: rect.width, y: 0))
                path.addLine(to: CGPoint(x: rect.width - lineLength, y: 0))
            case .bottomLeft:
                path.move(to: CGPoint(x: 0, y: rect.height - lineLength))
                path.addLine(to: CGPoint(x: 0, y: rect.height))
                path.addLine(to: CGPoint(x: lineLength, y: rect.height))
            case .bottomRight:
                path.move(to: CGPoint(x: rect.width, y: rect.height - lineLength))
                path.addLine(to: CGPoint(x: rect.width, y: rect.height))
                path.addLine(to: CGPoint(x: rect.width - lineLength, y: rect.height))
            default:
                break
            }
        }
        .stroke(Color.black, lineWidth: 2.5)
    }
    
    private func closestCorner(point: CGPoint, rect: CGRect, dist: CGFloat = 16) -> UIRectCorner? {
        let ldx = abs(rect.minX.distance(to: point.x)) < dist
        let rdx = abs(rect.maxX.distance(to: point.x)) < dist
        let ldy = abs(rect.minY.distance(to: point.y)) < dist
        let rdy = abs(rect.maxY.distance(to: point.y)) < dist
        guard (ldx || rdx) && (ldy || rdy) else { return nil }
        if ldx && ldy {
            return .topLeft
        } else if rdx && ldy {
            return .topRight
        } else if ldx && rdy {
            return .bottomLeft
        } else if rdx && rdy {
            return .bottomRight
        }
        else { return nil}
    }
    
    private func resizeBox(draggedCorner: UIRectCorner, translation: CGSize) {
        guard let initialRect = initialRect else { return }
        // 어느 모서리를 드래그 중인지 확인
        let isLeft = draggedCorner == .topLeft || draggedCorner == .bottomLeft
        let isTop = draggedCorner == .topLeft || draggedCorner == .topRight
        // 새 가로 및 세로 크기 계산
        let width = isLeft ?
        initialRect.width - translation.width :
        initialRect.width + translation.width
        let height = isTop ?
        initialRect.height - translation.height :
        initialRect.height + translation.height
        // 정사각형 유지를 위해 더 작은 값 사용하고, 최소 크기 제한
        let sideLength = max(min(width, height), minSize)
        // 새 원점 계산
        let newOrigin: CGPoint = {
            var origin = initialRect.origin
            if isLeft { origin.x = initialRect.maxX - sideLength }
            if isTop { origin.y = initialRect.maxY - sideLength }
            // 프레임 경계 내로 제한
            return CGPoint(
                x: max(0, min(origin.x, frameSize.width - sideLength)),
                y: max(0, min(origin.y, frameSize.height - sideLength))
            )
        }()
        // 최종 사각형 설정
        self.rect = CGRect(origin: newOrigin, size: CGSize(width: sideLength, height: sideLength))
    }
    
    private func drag(initialRect: CGRect, frameSize: CGSize, translation: CGSize) -> CGRect {
        let maxX = frameSize.width - initialRect.width
        let newX = min(max(initialRect.origin.x + translation.width, 0), maxX)
        let maxY = frameSize.height - initialRect.height
        let newY = min(max(initialRect.origin.y + translation.height, 0), maxY)
        
        return .init(origin: .init(x: newX, y: newY), size: initialRect.size)
    }
}
#Preview {
    @Previewable @State var rect = CGRect(x: 10, y: 20, width: 100, height: 100) // 초기 CGRect 값
    
    return CropBoxView(rect: $rect) // rect를 Binding으로 전달
}
