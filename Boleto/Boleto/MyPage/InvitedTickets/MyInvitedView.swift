//
//  MyInvitedView.swift
//  Boleto
//
//  Created by Sunho on 9/12/24.
//

import SwiftUI
import ComposableArchitecture
struct MyInvitedView: View {
    @Bindable var store: StoreOf<MyInvitedFeature>
    var body: some View {
        VStack(spacing: 35) {
            ForEach(store.invitedTickets, id: \.startDate) { ticket in
                SwipalbleTicketCell(ticket: ticket) {
                    store.send(.tapAcceptButton)
                } onDelete: {
                    store.send(.tapRefuseButton)
                }

            }
        }.padding(.horizontal,32)
            .applyBackground(color: .background)
            .alert($store.scope(state: \.alert, action: \.alert))
    }
   
}

#Preview {
    MyInvitedView(store: .init(initialState: MyInvitedFeature.State(), reducer: {
        MyInvitedFeature()
    }))
}
