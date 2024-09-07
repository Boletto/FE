//
//  PastTicketDetailView.swift
//  Boleto
//
//  Created by Sunho on 9/7/24.
//

import SwiftUI

struct PastTicketDetailView: View {
    let ticket: Ticket
    var body: some View {
        VStack {
            
            HStack {
                Spacer()
                NumsParticipantsView(personNum: ticket.participant.count)
            }
       
            TicketView(ticket: ticket)
        }
        .padding(.horizontal, 32)
        .applyBackground(color: .background)
//        .toolbar {
//            ToolbarItem(placement: ., content: <#T##() -> View#>)
//        }
//        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        PastTicketDetailView(ticket: Ticket(departaure: "Seoul", arrival: "Busan", startDate: "2024.1.28", endDate: "2024.04.12", participant: [Person(image: "beef3", name: "강병호"),Person(image: "beef1", name: "김수민"),Person(image: "beef2", name: "하잇"),Person(image: "beef4", name: "면답"), Person(image: "beef2", name: "호잇")], keywords: [.activity,.exercise]))
    }
}
