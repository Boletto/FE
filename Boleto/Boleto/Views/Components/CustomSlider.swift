//
//  CustomSlider.swift
//  Boleto
//
//  Created by Sunho on 4/20/25.
//
import SwiftUI

struct CustomSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    
    @State private var isDragging = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundColor(.gray.opacity(0.3))
                    .frame(height: 2)
                
                // 활성화된 트랙 부분
                RoundedRectangle(cornerRadius: 8)
                    .foregroundColor(.white)
                    .frame(width: geometry.size.width * CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound)), height: 2)
                
                ZStack {
                    // 바깥쪽 흰색 원
                    Circle()
                        .stroke(Color.white, lineWidth: 1.5)
                        .frame(width: 24, height: 24)
                    
                    // 안쪽 파란색 원 (더 작게)
                    Circle()
                        .fill(Color.mainColor) // 매우 옅은 색상으로 채움
                        .frame(width: 8, height: 8)
                }
                    .offset(x: geometry.size.width * CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound)) - 10)
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                isDragging = true
                                updateValue(geometry: geometry, gesture: gesture)
                            }
                            .onEnded { _ in
                                isDragging = false
                            }
                    )
            }
        }
    }
    
    private func updateValue(geometry: GeometryProxy, gesture: DragGesture.Value) {
        let dragLocation = gesture.location.x
        let newValue = (dragLocation / geometry.size.width) * (range.upperBound - range.lowerBound) + range.lowerBound
        
        // 값의 범위를 제한
        value = min(max(newValue, range.lowerBound), range.upperBound)
    }
}
