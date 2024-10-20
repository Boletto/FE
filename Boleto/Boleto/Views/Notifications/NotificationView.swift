//
//  NotificationView.swift
//  Boleto
//
//  Created by Sunho on 9/14/24.
//

import SwiftUI
import ComposableArchitecture
struct NotificationView: View {
    @Bindable var store: StoreOf<NotificationFeature>
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
               
                    Text("오늘 ")
                        .customTextStyle(.subheadline)
                        .foregroundStyle(.white)
                    
               
                Text("경희대학교 스티커를 획득했어요")
                    .foregroundStyle(.white)
                    .padding(.vertical, 26)
                Divider().frame(height: 1)
                Text("경희대학교 네컷제작이 활성화되었어요.")
                    .foregroundStyle(.white)
                    .padding(.vertical, 26)
                Divider().frame(height: 1)
                HStack {
                    Text("지난 ")
                        .customTextStyle(.subheadline)
                        .foregroundStyle(.white)
                }
                Text("경복궁 스티커를 획득했어요")
                    .foregroundStyle(.white)
                    .padding(.vertical, 26)
                Divider().frame(height: 1)
                Text("서울 네컷제작이 활성화되었어요")
                    .foregroundStyle(.white)
                    .padding(.vertical, 26)
                Divider().frame(height: 1)
                
            } }.customTextStyle(.subheadline).navigationBarBackButtonHidden()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("알림")
                        .foregroundStyle(.white)
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {store.send(.tapbackbutton)}, label: {
                        Image(systemName: "chevron.backward")
                            .foregroundStyle(.white)
                    })
                }
            }.applyBackground(color: .background)
    }
}

#Preview {
    NotificationView(store: .init(initialState: NotificationFeature.State(), reducer: {
        NotificationFeature()
    }))
}
