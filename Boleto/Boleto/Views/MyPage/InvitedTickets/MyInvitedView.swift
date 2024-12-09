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
        ScrollView {
            LazyVStack(spacing: 32) {
                ForEach(store.invitedTickets, id: \.startDate) { ticket in
                    VStack(spacing: 10){
                        HStack {
                            Text("From. \(ticket.participant[0].nickname)")
                                .customTextStyle(.subheadline)
                                .foregroundStyle(.white)
                            Spacer()
                        }
                        SwipalbleTicketCell(ticket: ticket, onAccept: {
                            store.send(.tapAcceptButton(ticket.travelID))
                        }, onDelete: {
                            store.send(.tapRefuseButton(ticket.travelID))
                        }, invitedMode: true)
                    }
                }
                Spacer()
            }.padding(.top, 40)
        }
        .scrollIndicators(.hidden)
            .padding(.horizontal,32)
            .alert($store.scope(state: \.alert, action: \.alert))
       
            .onAppear {
                store.send(.initializeView)
            }
    }
   
}

#Preview {
    MyInvitedView(store: .init(initialState: MyInvitedFeature.State(invitedTickets: Ticket.mockTickets), reducer: {
        MyInvitedFeature()
    }))
}
