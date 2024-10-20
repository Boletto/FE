//
//  SwiftUIView.swift
//  Boleto
//
//  Created by Sunho on 8/30/24.
//

import SwiftUI

struct BubbleView: View {
    @Binding var text: String 
    var scale: CGFloat
    var rotation: Angle
    var position: CGPoint
    var isSelected: Bool
    var body: some View {
        
        TextField("\(text)" ,text:$text)
            .padding()
            .background(Color.white)
            .foregroundStyle(.black)
            .clipShape(RoundedRectangle(cornerRadius: 18,style: .circular))
            .overlay(alignment:.bottomTrailing) {
                Image(systemName: "arrowtriangle.down.fill")
                    .font(.largeTitle)
                    .rotationEffect(.degrees(-30))
                    .offset(x: -5, y : 15)
                    .foregroundStyle(.white)
            }
            .frame(width: 80 * scale, height: 50 * scale)
            .rotationEffect(rotation)
            .position(position)
    }
}
//
//#Preview {
//    ZStack {
//        Color.black
//        BubbleView(text: "내가만들었어유 어때요 똑같쥬?")
//    }
//}
