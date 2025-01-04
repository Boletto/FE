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
    private let minSize = CGSize(width: 100, height: 100)
    @State private var initialRect:CGRect? = nil
    @State private var frameSize: CGSize = .zero
    @State private var draggedCorner: UIRectCorner? = nil
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
    var body: some View {
        ZStack(alignment: .topLeading) {
            blur
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
    private var blur: some View {
        Color.black.opacity(0.5)
            .overlay(alignment: .topLeading) {
                Color.white
                    .frame(width: rect.width - 1, height: rect.height - 1)
                    .offset(x: rect.origin.x, y: rect.origin.y)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
           .drawingGroup()
           .blendMode(.multiply)
    }
    private var box: some View {
        ZStack {
            gridLines
            makePinShape(corner: .topLeft)
            makePinShape(corner: .topRight)
            makePinShape(corner: .bottomLeft)
            makePinShape(corner: .bottomRight)
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
        .foregroundColor(.gray5)
    }

    private func makePinShape(corner: UIRectCorner) -> some View {
        Path { path in
            switch corner {
            case .topLeft:
                path.move(to: .init(x: -1 , y: 8))
                path.addLine(to: CGPoint(x: -1, y: -1))
                path.addLine(to: CGPoint(x: 8, y: -1))
            case .topRight:
                path.move(to: .init(x: rect.width + 1, y: 8))
                path.addLine(to: .init(x: rect.width + 1, y: -1))
                path.addLine(to: .init(x: rect.width - 8, y: -1))
            case .bottomLeft:
                path.move(to: .init(x: -1, y: rect.height - 8))
                 path.addLine(to: CGPoint(x: -1, y: rect.height + 1)) // 세로 선
                 path.addLine(to: CGPoint(x: 8, y: rect.height + 1)) // 가로 선
            case .bottomRight:
                path.move(to: .init(x: rect.width + 1, y: rect.height - 8))
                path.addLine(to: CGPoint(x: rect.width + 1, y: rect.height + 1))
                path.addLine(to: CGPoint(x: rect.width - 8, y: rect.height + 1))
            default:
                break
            }
        }
        .stroke(Color.black, lineWidth: 1.5)
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
        guard let initialRect = initialRect else {return}
        var newRect = initialRect
        switch draggedCorner {
             case .topLeft:
                 newRect.origin.x += translation.width
                 newRect.origin.y += translation.height
                 newRect.size.width -= translation.width
                 newRect.size.height -= translation.height
             case .topRight:
                 newRect.size.width += translation.width
                 newRect.origin.y += translation.height
                 newRect.size.height -= translation.height
             case .bottomLeft:
                 newRect.origin.x += translation.width
                 newRect.size.width -= translation.width
                 newRect.size.height += translation.height
             case .bottomRight:
                 newRect.size.width += translation.width
                 newRect.size.height += translation.height
             default:
                 break
             }
        newRect.size.width = max(newRect.size.width, minSize.width)
           newRect.size.height = max(newRect.size.height, minSize.height)

           self.rect = newRect
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
