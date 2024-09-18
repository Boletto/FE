//
//  PastTravelView.swift
//  Boleto
//
//  Created by Sunho on 9/5/24.
//

import SwiftUI
import ComposableArchitecture

struct MainTravelTicketsView: View {
    @Bindable var store: StoreOf<MainTravelTicketsFeature>
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Text("진행 중인 여행")
                        .foregroundStyle(.white)
                        .customTextStyle(.subheadline)
                    Spacer()
                }
                if let currentTicket = store.currentTicket {
                    SwipalbleTicketCell(ticket: currentTicket, onAccpet: {
                        store.send(.touchTicket(currentTicket))
                    }, onDelete: {
                        
                    }, invitedMode: false)
                } else {
                    Button {
                        store.send(.touchAddTravel)
                    } label: {
                        
                        addTicketCell
                    }

                    
                }
                ScrollView {
                    if let futureTickets = store.futureTicket {
                        HStack {
                            Text("예정된 여행 ").foregroundStyle(.white) + Text("\(futureTickets.count)개").foregroundStyle(.customSkyBlue)
                            Spacer()
                        }.customTextStyle(.subheadline)
                        LazyVStack(spacing: 5) {
                            ForEach(futureTickets) { ticket in
                                SwipalbleTicketCell(ticket: ticket, onAccpet: {
                                    store.send(.touchTicket(ticket))
                                }, onDelete: {
                                    
                                }, invitedMode: false)
                            }
                        }
                    }
                 
                HStack {
                    Text("완료된 여행 ").foregroundStyle(.white) + Text("\(store.tickets.count)개").foregroundStyle(.customSkyBlue)
                    Spacer()
                }.padding(EdgeInsets(top: 20, leading: 32, bottom: 16, trailing: 0))
               
                    VStack(alignment: .leading, spacing: 5) {
                        ForEach(store.tickets) {ticket in
//                            GeometryReader{ geo in
//                                NumsParticipantsView(personNum: ticket.participant.count)
//                                    .onTapGesture {
//                                        let frame = geo.frame(in: .global)
//                                        let bottomY = frame.maxY
//                                        let startX = frame.minX
//                                        store.send(.tapNums(ticket, CGPoint(x: startX, y: bottomY)))
//                                    }
//                            }
//                            .frame(height: 24)
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
//            if store.showingModal {
//                ZStack {
//                    Color.black.opacity(0.5)
//                        .onTapGesture {
//                            store.send(.hideModal)
//                        }
//                    TravelCompanionsView(persons: store.selectedTicket!.participant)
//                        .position(x: store.modalPosition.x + 100, y: store.modalPosition.y + 20 )
//                }
//            }
        }
    }
    var addTicketCell: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(.gray1)
                .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [7]))
                .foregroundStyle(.gray2)
            VStack(spacing: 0) {
                ZStack {
                    Circle().fill(.main)
                        .frame(width: 42,height: 42)
                    Image(systemName: "plus")
                        .resizable()
                        .frame(width: 21,height: 21)
                        .foregroundStyle(.gray1)
                }.padding(.top, 40)
                    .padding(.bottom, 20)
                Text("여행 추가해 추억을 기록해보세요!")
                    .foregroundStyle(.gray4)
                    .customTextStyle(.small)
            }
        }.frame(width: 329,height: 141)
    }
}

#Preview {
    MainTravelTicketsView(store: .init(initialState: MainTravelTicketsFeature.State()) {
        MainTravelTicketsFeature()
    })
    .applyBackground(color: .background)
}
