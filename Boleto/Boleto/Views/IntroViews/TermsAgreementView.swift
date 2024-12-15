//
//  TermsAgreementView.swift
//  Boleto
//
//  Created by Sunho on 12/11/24.
//

import SwiftUI

struct TermsAgreementView: View {
    @State private var isAllAgreed = false
    @State private var iscollectAgreed = false
    @State private var isLocationInfoAgreed = false
    var onTapStart: () -> Void
    var body: some View {
        VStack {
        VStack(alignment: .leading) {
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 174)
                .padding(.top, 132)
                .padding(.bottom,16)
            VStack(alignment: .leading, spacing: 8) {
                Text("볼레또에")
                Text("오신 것을 환영합니다!")
            }
                .foregroundStyle(.white)
                .customTextStyle(.title)
                .padding(.bottom,19)
            Text("볼레또의 특별한 서비스를 이용하시려면\n이용약관에 동의가 필요합니다. 약관에 동의하시고\n볼레또에서 여행 추억을 쌓아보세요!")
                .multilineTextAlignment(.leading)
                .foregroundColor(.gray4)
                .lineSpacing(2.2)
                .customTextStyle(.body1)
            Spacer()
            HStack(spacing: 15) {
                toggleIcon(isSelected: isAllAgreed)
                    .frame(width: 22,height: 22)
                    .onTapGesture {
                        toggleAllAgreements()
                    }
                
                Text("전체 동의")
                    .customTextStyle(.title)
                    .foregroundColor(.white)
            }
            Divider()
                .background(Color.gray2)
                .frame(height: 1)
                .padding(.vertical,14)
            HStack {
                toggleIcon(isSelected: iscollectAgreed)
                    .frame(width: 15,height: 15)
                    .onTapGesture {
                        iscollectAgreed.toggle()
                        updateAllAgreementStatus()
                    }
                Group {
                    Text("(필수) ")
                        .foregroundColor(.main) + Text("개인정보 수집 및 이용 안내").foregroundColor(.white)
                }                    .customTextStyle(.body1)
                
                Spacer()
                Link(destination: URL(string: "https://rough-step-a19.notion.site/15892ce4668880c5812dfe417feb228a?pvs=4")!) {
                    Text("보기")
                        .customTextStyle(.body1)
                        .foregroundStyle(.gray4)
                }
            }.padding(.bottom,13)
            HStack {
                toggleIcon(isSelected: isLocationInfoAgreed)
                    .frame(width: 15,height: 15)
                    .onTapGesture {
                        isLocationInfoAgreed.toggle()
                        updateAllAgreementStatus()
                    }
                Group {
                    Text("(필수) ")
                        .foregroundColor(.main) + Text("위치기반서비스 이용약관").foregroundColor(.white)
                }                    .customTextStyle(.body1)
                Spacer()
                Link(destination: URL(string: "https://rough-step-a19.notion.site/15892ce4668880f39dfbef9850377eee?pvs=4")!) {
                    Text("보기")
                        .customTextStyle(.body1)
                        .foregroundStyle(.gray4)
                }
            }
        }.padding(.horizontal,32)
                .padding(.bottom, 42)
            Button {
                onTapStart()
            } label: {
                Text("시작하기")
                    .foregroundStyle(isAllAgreed ? .black : .gray3)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(RoundedRectangle(cornerRadius: 30).fill(Color.main))
            }
            .disabled(!isAllAgreed)
            .padding(.bottom,40)
            .padding(.horizontal,16)

    }
            .applyBackground(color: .background)
    }
    private func toggleAllAgreements() {
         isAllAgreed.toggle()
        iscollectAgreed = isAllAgreed
         isLocationInfoAgreed = isAllAgreed
     }
     
     /// 나머지 동의 상태에 따라 전체 동의 상태를 업데이트
     private func updateAllAgreementStatus() {
         isAllAgreed = iscollectAgreed && isLocationInfoAgreed
     }
     
     /// 선택 상태에 따라 아이콘을 반환
     @ViewBuilder
     private func toggleIcon(isSelected: Bool) -> some View {
         if !isSelected {
             Image(systemName: "circle")
                 .resizable()
                 .scaledToFit()
                 .foregroundStyle(.white)
         } else {
             Image("checktoggle")
                 .resizable()
                 .scaledToFit()
         }
     }
}

#Preview {
    TermsAgreementView() {
        print("hi")
    }
}
