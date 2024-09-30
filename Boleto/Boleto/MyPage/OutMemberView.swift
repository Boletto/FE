//
//  OutMemberView.swift
//  Boleto
//
//  Created by Sunho on 9/28/24.
//

import SwiftUI
import ComposableArchitecture
struct OutMemberView: View {
    @Bindable var store: StoreOf<OutMemberFeature>
    var body: some View {
        VStack(spacing:0) {
            ZStack {
                HStack {
                    Button(action: {store.send(.tapCloseButton)}, label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.gray6)
                    })
         
                    Spacer()
                }.padding(.leading,32)
                HStack {
                    Text("회원 탈퇴")
                        .customTextStyle(.subheadline)
                        .foregroundStyle(.gray6)
                }
            }
            .padding(.bottom,41)
            Text("정말 BOLETO를 떠나시겠어요?")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(.gray6)
                .padding(.bottom,10)
            
            Text("탈퇴하기 전에 아래 내용을 확인해주세요")
                .customTextStyle(.body1)
                .foregroundStyle(.gray6)
            Image("OutMember")
                .resizable()
                .padding(.horizontal, 97)
                .aspectRatio(contentMode: .fit)
                .padding(.bottom,55)
                .padding(.top,40)
            
            VStack(alignment:. leading, spacing: 10){
                Text("처음부터 다시 가입해야 해요")
                    .customTextStyle(.body1)
                    .foregroundStyle(.gray6)
                Text("탈퇴 회원의 정보는 며칠간 임시 보관후 삭제해요.\n탈퇴 후 재가입시 처음부터 다시 정보를 입력해야 해요.")
                    .customTextStyle(.small)
                    .foregroundColor(.gray5)
            }
                .padding(.vertical, 15)
                .padding(.horizontal,24)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 10).fill(.gray1))
                .padding(.horizontal, 32)
                .padding(.bottom, 20)
            VStack(alignment:. leading, spacing: 10){
                Text("추억들이 모두 사라져요")
                    .customTextStyle(.body1)
                    .foregroundStyle(.gray6)
                Text("BOLETO에 저장된 티켓, 스티커, 네컷 등이 완전히 사라져요.\n재가입에도 이 데이터들은 복구가 불가해요,")
                    .customTextStyle(.small)
                    .foregroundColor(.gray5)
            }.padding(.leading, 25)
                .padding(.vertical, 15)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 10).fill(.gray1))
                .padding(.horizontal, 32)
            Spacer()
            Button {
                store.send(.outMemberTapped)
            } label: {
                Text("탈퇴하기")
                    .foregroundStyle(.black)
                    .customTextStyle(.normal)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(RoundedRectangle(cornerRadius: 30).fill(.main))
                
            }
            .padding(.horizontal, 16)
    
        }.applyBackground(color: .background)
        .alert($store.scope(state: \.alert, action: \.alert))
    }
}
//#Preview {
//    OutMemberView(store: .init(initialState: MyPageFeature.State(), reducer: {
//        MyPageFeature()
//    }))
//}
