//
//  FilterItem.swift
//  Boleto
//
//  Created by Sunho on 4/17/25.
//

import SwiftUI

struct FilterItem: View {
    let filter: String
    let thumbNail: UIImage?
    let isSelected: Bool
    let onTap: () -> Void
    @State private var isAnimating = false
    var body: some View {
        VStack(spacing: 4) {
            if let thumbNail = thumbNail {
                Image(uiImage: thumbNail)
                    .resizable()
                    .frame(width: 56, height: 56)
                    .scaledToFill()
                    .cornerRadius(5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(isSelected ?  Color.main.opacity(0.7) : Color.clear)
                    )
            } else {
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: 56, height: 56)
                    .cornerRadius(5)
            }
            Text(filter)
                .font(.system(size: 10,weight: .regular))
                .foregroundColor(.white)
        }
        .offset(y: isAnimating ? -6 : 0)
        .onTapGesture {
            withAnimation(.spring(response: 0.4,dampingFraction: 0.4)){
                isAnimating = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.spring(response: 0.4,dampingFraction: 0.4)) {
                    isAnimating = false
                }
            }
            onTap()
        }
    }
}
