//
//  PastTravelView.swift
//  Boleto
//
//  Created by Sunho on 9/5/24.
//

import SwiftUI
import ComposableArchitecture

struct PastTravelView: View {
    @Bindable var store: StoreOf<PastTravelFeature>
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Text("완료된 여행 ").foregroundStyle(.white) + Text("\(store.tickets.count)개").foregroundStyle(.customSkyBlue)
                    Spacer()
                }.padding(EdgeInsets(top: 20, leading: 32, bottom: 16, trailing: 0))
                ScrollView {
                    VStack(alignment: .leading, spacing: 5) {
                        ForEach(store.tickets) {ticket in
                            GeometryReader{ geo in
                                NumsParticipantsView(personNum: ticket.participant.count)
                                    .onTapGesture {
                                        let frame = geo.frame(in: .global)
                                        let bottomY = frame.maxY
                                        let startX = frame.minX
                                        store.send(.tapNums(ticket, CGPoint(x: startX, y: bottomY)))
                                    }
                            }
                            .frame(height: 24)
                            SwipalbleTicketCell(ticket: ticket, onAccpet: {
                                store.send(.touchTicket(ticket))
                            }, onDelete: {
                                print("delete")
                            }, invitedMode: false)
                                .onTapGesture {
                                    store.send(.touchTicket(ticket))
                                }
                            Spacer().frame(minHeight: 24)
                        }
                    }.padding(.horizontal, 32)
                }
                
            }
            if store.showingModal {
                ZStack {
                    Color.black.opacity(0.5)
                        .onTapGesture {
                            store.send(.hideModal)
                        }
                    TravelCompanionsView(persons: store.selectedTicket!.participant)
                        .position(x: store.modalPosition.x + 100, y: store.modalPosition.y + 20 )
                }
            }
        }
    }
    
}

#Preview {
    PastTravelView(store: .init(initialState: PastTravelFeature.State()) {
        PastTravelFeature()
    })
    .applyBackground(color: .background)
}
