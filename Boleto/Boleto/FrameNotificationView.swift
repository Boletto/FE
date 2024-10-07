//
//  FrameNotificationView.swift
//  Boleto
//
//  Created by Sunho on 9/18/24.
//

import SwiftUI
import ComposableArchitecture
import PhotosUI
struct FrameNotificationView: View {
    @Bindable var store: StoreOf<FrameNotificationFeature>
    var body: some View {
        VStack(spacing: 0) {
            Group {
                Text("✈️\(store.badgeType.rawValue)에 도착했어요")
                    .font(.system(size: 22, weight: .semibold))
                    .padding(.bottom,14)
                Text("직접 찍은 사진을 넣어 직접 프레임을 만들 수 있어요!")
                    .padding(.bottom,2)
                Text("여행 추억이 담긴 나만의 네컷 프레임을 만들어보세요")
            }.foregroundStyle(.white)
                .font(.system(size: 14))
               
            PhotosPicker(selection: Binding(get: {
                store.selectedItem
            }, set: { newValue in
                store.send(.imagePickerSelection(newValue))
            }), matching: .images) {
               frameView
            }
            .padding(.top, 64)
            
            Button(action: {
                store.send(.tapsaveFrame)
            }, label: {
                Text("프레임 보관하기")
                    .frame(width: 361, height: 56)
                    .foregroundStyle(.black)
                    .background(Capsule().fill(.main))
              
            })
            .padding(.top, 111)
        }.applyBackground(color: .background)
    }
    var frameView: some View {
        ZStack(alignment: .bottomTrailing) {
            ZStack {
                if let selectedFrame = store.selectedFrame {
                    Image(uiImage: selectedFrame)
                        .resizable()
                        .frame(width: 316, height: 354)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                } else {
                    Image( "CustomDefaultFrame")
                        .resizable()
                        .frame(width: 316, height: 354)
                }
                
                
                VStack(spacing: 20) {
                    HStack(spacing: 20) {
                        RoundedRectangle(cornerRadius: 15   )
                            .fill(Color.background)
                            .frame(width: 129,height: 129)
                        RoundedRectangle(cornerRadius: 15   )
                            .fill(Color.background)
                            .frame(width: 129,height: 129)
                    }
                    HStack(spacing: 20) {
                        RoundedRectangle(cornerRadius: 15   )
                            .fill(Color.background)
                            .frame(width: 129,height: 129)
                        RoundedRectangle(cornerRadius: 15   )
                            .fill(Color.background)
                            .frame(width: 129,height: 129)
                    }
                }
                .padding(.bottom,30)
                
                
            }
            ZStack {
                Circle()
                    .fill(.gray4)
                    .frame(width: 56,height: 56)
                Image(systemName: "photo.badge.plus")
                    .symbolVariant(.circle.fill)
                    .foregroundStyle(.white)
                    .font(.system(size: 24))
            }.offset(x: 8, y: 24)
        }
    }
}

//#Preview {
//    FrameNotificationView(store: .init(initialState: FrameNotificationFeature.State(), reducer: {
//        FrameNotificationFeature()
//    }))
//}
