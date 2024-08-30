//
//  PolaroidView.swift
//  Boleto
//
//  Created by Sunho on 8/12/24.
//

import SwiftUI

import ComposableArchitecture

struct PolaroidView: View {
    let imageView: Image
    let showTrashButton: Bool
    var body: some View {
        ZStack {
            imageView
                .resizable()
                .clipShape(.rect(cornerRadius:  10))
                .padding(.top, 8)
                .padding(.horizontal,  8)
                .padding(.bottom,40)
        }
        .background(Color.black.opacity(0.8)) // 확대 시 배경색을 더 진하게 변경
        .cornerRadius(10) // 확대 시 모서리를 둥글게 하는 것을 제거
        .overlay {
            if showTrashButton {
                Color.black.opacity(0.6)
                Image(systemName: "trash")
                    .foregroundStyle(.white)
                    .font(.system(size: 24))
                    .background(Circle().frame(width: 32,height: 32).foregroundStyle(Color.black))
            }
        }
    
    }
}
struct PolaroaidFullView: View {
    let imageView: Image
    var body: some View {
        ZStack {
            imageView
                .resizable()
                .clipShape(.rect(cornerRadius:  10))
                .padding(.top, 24)
                .padding(.horizontal,18)
                .padding(.bottom,62)
                .zIndex(1)
        }        .background(Color.black.opacity(0.8)) // 확대 시 배경색을 더 진하게 변경
            .cornerRadius(10) // 확대 시 모서리를 둥글게 하는 것을 제거
    }
    
}
//#Preview {
//    PolaroaidView()
//}
