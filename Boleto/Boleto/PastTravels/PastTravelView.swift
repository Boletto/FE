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
        VStack {
            HStack {
                Text("완료된 여행 ").foregroundStyle(.white) + Text("\(store.tickets.count)개").foregroundStyle(.customSkyBlue)
                Spacer()
            }.padding(EdgeInsets(top: 20, leading: 32, bottom: 16, trailing: 0))
                ScrollView {
                    VStack(alignment: .leading, spacing: 5) {
                        ForEach(store.tickets) {ticket in
                            makeparticipantView(personNum: ticket.participant)
                            TicketCell(ticket: ticket)
                            Spacer().frame(minHeight: 24)
                        }
                    }.padding(.horizontal, 32)
                }
            
        }
    }
    func makeparticipantView(personNum: Int) -> some View {
        ZStack {
            Capsule().foregroundStyle(.gray1)
            HStack(spacing: 8) {
                Text("\(personNum)")
                    .font(.system(size: 11))
                    .foregroundStyle(.white)
                    .background(
                        Circle()
                            .frame(width: 18, height: 18)
                            .foregroundStyle(.gray2))
                Image(systemName: "chevron.down")
                    .foregroundStyle(.white)
            }.padding(.all, 2)
                .padding(.trailing, 2)
        }
        .frame(width: 40, height: 22)
    }
}

#Preview {
    PastTravelView(store: .init(initialState: PastTravelFeature.State()) {
        PastTravelFeature()
    })
        .applyBackground(color: .background)
}
