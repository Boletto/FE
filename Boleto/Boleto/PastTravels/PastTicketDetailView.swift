//
//  PastTicketDetailView.swift
//  Boleto
//
//  Created by Sunho on 9/7/24.
//

import SwiftUI
import ComposableArchitecture

struct PastTicketDetailView: View {
    @Bindable var store: StoreOf<PastTicketDeatilFeature>
    var body: some View {
        VStack {
            
            HStack {
                Spacer()
                NumsParticipantsView(personNum: store.ticket.participant.count)
            }.padding(.top, 44)
       
            TicketView(ticket: store.ticket)
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("지난 여행")
                    .foregroundStyle(.white)
            }
            ToolbarItem(placement: .topBarLeading) {
                Button  {
                    store.send(.tapgobackView)
                } label: {
                    Image(systemName: "chevron.backward")
                        .foregroundStyle(.white)
                }

            }
        }
        .padding(.horizontal, 32)
        .applyBackground(color: .background)
    }
}

//#Preview {
//    NavigationStack {
//        PastTicketDetailView(ticket: Ticket(departaure: "Seoul", arrival: "Busan", startDate: "2024.1.28", endDate: "2024.04.12", participant: [Person(image: "beef3", name: "강병호"),Person(image: "beef1", name: "김수민"),Person(image: "beef2", name: "하잇"),Person(image: "beef4", name: "면답"), Person(image: "beef2", name: "호잇")], keywords: [.activity,.exercise]))
//    }
//}
