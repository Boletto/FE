//
//  RewardView.swift
//  Boleto
//
//  Created by Sunho on 12/11/24.
//

import SwiftUI

struct RewardView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Text("Welcome")
                    .foregroundStyle(.white)
                    .font(  .customFont(.cafefont, size: 36))
                    .padding(.bottom, 16)
                    .padding(.top, 70)
                HStack(spacing: 8) {
                    Text("GIF")
                        .foregroundStyle(.white)
                        .font(.customFont(.sbboldFont, size: 96))
                    Image("giftBox")
                        .resizable().scaledToFit()
                        .frame(width: 73)
                        .offset(y: -10)
                }
                .padding(.bottom,21)
                Text("12.21 - 12.31")
                    .customTextStyle(.pageTitle)
                    .foregroundStyle(.gray3)
                    .padding(.bottom,42)
                Image("reward2")
                    .resizable()
                    .scaledToFit()
                    .padding(.horizontal,128)
                    .padding(.bottom,12)
                Text("볼레또에 가입하신 걸 환영해요!\n출시 기념으로 기간 한정 특별 선물을 준비했어요")
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .customTextStyle(.body1)
                    .padding(.bottom,25)
                Image("reward3")
                    .resizable()
                    .scaledToFit()
                    .padding(.horizontal,32)
                    .padding(.bottom,28)
                HStack(spacing: 12) {
                    Text("증정기간")
                        .foregroundStyle(.black)
                        .customTextStyle(.body1)
                        .frame(width: 87,height: 30)
                        .background(Capsule().fill(.white))
                    Text("2024.12.21 - 2025.01.04")
                        .foregroundStyle(.gray5)
                        .customTextStyle(.body1)
                    Spacer()
                }.padding(.bottom,12)
                    .padding(.leading,44)
                HStack(spacing: 12) {
                    Text("대상")
                        .foregroundStyle(.black)
                        .customTextStyle(.body1)
                        .frame(width: 87,height: 30)
                        .background(Capsule().fill(.white))
                    Text("볼레또 첫 가입 시 누구나")
                        .foregroundStyle(.gray5)
                        .customTextStyle(.body1)
                    Spacer()
                }
                .padding(.leading,44)
                Image(systemName: "plus")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24,height: 24)
                    .foregroundStyle(.main)
                    .padding(.vertical,28)
                Text("Coming Soon")
                    .foregroundStyle(.gray5)
                    .customTextStyle(.body1)
                    .padding(.bottom,8)
                Group {
                    Text("Christmas")
                        .foregroundStyle(.rewardorange) + Text("GIFT").foregroundStyle(.rewardgreen)
                }.font(.customFont(.cafefont, size: 32))
                    .padding(.bottom,28)
                Text("볼레또가 주는 크리스마스 선물!\n크리스마스 테마 티켓 3종")
                    .foregroundStyle(.white)
                    .customTextStyle(.body1)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 15)
                Image("reward4")
                    .resizable()
                    .scaledToFit()
                    .padding(.horizontal,37)
                    .padding(.bottom,15)
                Text("2024.12.21 - 2024.12.31")
                    .foregroundStyle(.gray5)
                    .customTextStyle(.body1)
                
                
            }.toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.backward")
                            .foregroundStyle(.white)
                    }
                }
            }
        }.applyBackground(color: .background)
            .navigationBarBackButtonHidden()
            .toolbarBackground(Color.background, for: .navigationBar)
            
    }
}

#Preview {
    RewardView()
}
