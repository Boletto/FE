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
        VStack {
            Text("NOti")
        }.navigationBarBackButtonHidden()
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
            }
    }
}

//#Preview {
//    NotificationView()
//}
