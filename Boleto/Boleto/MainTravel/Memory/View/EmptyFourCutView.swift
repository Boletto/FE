//
//  EmptyFourCutView.swift
//  Boleto
//
//  Created by Sunho on 8/17/24.
//

import SwiftUI

struct EmptyFourCutView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [5]))
                .foregroundStyle(Color.white.opacity(1))
                .background(RoundedRectangle(cornerRadius: 20).fill(Color.gray))
                .frame(width: 150, height: 150)
            Circle()
                .fill(Color.gray1.opacity(0.5))
                .frame(width: 40, height: 40)
                .overlay(Image(systemName: "plus").foregroundStyle(.white).font(.system(size: 24)))
        }
    }
}

#Preview {
    EmptyFourCutView()
}
