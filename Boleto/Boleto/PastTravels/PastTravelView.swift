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
                            NumsParticipantsView(personNum: ticket.participant.count)
                            
                            TicketCell(ticket: ticket)
                                .onTapGesture {
                                    
                                }
                            Spacer().frame(minHeight: 24)
                        }
                    }.padding(.horizontal, 32)
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
