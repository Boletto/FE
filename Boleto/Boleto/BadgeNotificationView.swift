//
//  BadgeNotificationView.swift
//  Boleto
//
//  Created by Sunho on 9/18/24.
//

import SwiftUI
import ComposableArchitecture
struct BadgeNotificationView: View {
    @Bindable var store: StoreOf<BadgeNotificationFeature>
    var body: some View {
        VStack {
            Group {
                Text("✈️ 에 도착했어요")
                    .font(.system(size: 22, weight: .semibold))
                    .padding(.bottom,14)
                Text("획득한 스티커를 이용해 여행 추억을")
                    .padding(.bottom,2)
                Text("더욱 새롭게 꾸밀 수 있어요!")
            }.foregroundStyle(.white)
                .font(.system(size: 14))
                
            badgeFrameView
                .padding(EdgeInsets(top: 40, leading: 39, bottom: 20, trailing: 39))
    
            Button(action: {
                store.send(.saveBadgeInLocal)
            }, label: {
                HStack {
                    Image(systemName: "arrow.down.to.line.compact")
                    Text("이미지 저장")
                     
                }   .customTextStyle(.subheadline)
                    .foregroundStyle(.white)
            })
            Spacer()
            Button(action: {}, label: {
                Text("확인")
                    .frame(width: 361, height: 56)
                    .foregroundStyle(.black)
                    .background(Capsule().fill(.main))
              
            })
        }.padding(.top,40).applyBackground(color: .background)
            .alert($store.scope(state: \.alert, action: \.alert))
    }
    var badgeFrameView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.gray1)
               
            VStack {
                HStack(spacing: 0) {
                    Text(Date.now.toString("yyyy.MM.dd"))
                
                        .padding(.trailing,12)
                        .layoutPriority(1)
                    DottedLine()
                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [3]))
                        .frame(height: 1)
                    Spacer().frame(width: 10)
                    Image(systemName: "airplane")
                        .resizable()
                        .frame(width: 20,height: 20)
                        .padding(.trailing, 4)
                    Text("Busan")
                        .layoutPriority(1)
                }.foregroundStyle(.main)
                    .font(.system(size: 15,weight: .semibold))
                    .padding(.top, 18)
                    .padding(.horizontal,26)
                Spacer()
                Image(store.badgeType.rawValue)
                    .resizable()
                    .scaledToFit()
                    .padding(.all,42)
                Text(store.badgeType.koreanString)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(.gray2))
                    .padding(.bottom,24)
                
                
            }
        } .frame(height: 397)
    }
}

#Preview {
    BadgeNotificationView(store: .init(initialState: BadgeNotificationFeature.State(badgeType: .bcc), reducer: {
        BadgeNotificationFeature()
    }))
}
