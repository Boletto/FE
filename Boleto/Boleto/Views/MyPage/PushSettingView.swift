//
//  PushSettingView.swift
//  Boleto
//
//  Created by Sunho on 10/3/24.
//

import SwiftUI
import ComposableArchitecture
struct PushSettingView: View {
    @Bindable var store: StoreOf<PushSettingFeature>
    var body: some View {
        VStack(alignment: .leading) {
            Text("푸시 설정")
                .customTextStyle(.subheadline)
                .foregroundStyle(.white)
                .padding(.bottom, 15)
            makeToggleView(
                text: "스티커, 네컷프레임 획득 알림",
                toggle: Binding(
                    get: { store.getnotiAlert },
                    set: { store.send(.setGetNotification($0)) }
                )
            )
            makeToggleView(
                text: "친구 신청 알림",
                toggle: Binding(
                    get: { store.frinedAlert },
                    set: { store.send(.setFriendNotification($0)) }
                )
            )
            makeToggleView(
                text: "여행 초대 알림",
                toggle: Binding(
                    get: { store.invitedAlert },
                    set: { store.send(.setInvitationNotification($0)) }
                )
            )
            Spacer()
        }.padding(.horizontal,32).applyBackground(color: .background)
    }
    func makeToggleView(text: String, toggle: Binding<Bool>) -> some View {
        HStack {
            Text(text)
                .foregroundStyle(.white)
                .customTextStyle(.body1)
            Spacer()
            
            Toggle("", isOn:toggle).tint(.main)
                .frame(width: 46,height: 31)
        }
        .padding(.horizontal,15)
        .frame(height: 45)
        .background(RoundedRectangle(cornerRadius: 5).fill(.gray1))
    }
}
