//
//  TicketCell.swift
//  Boleto
//
//  Created by Sunho on 9/5/24.
//

import SwiftUI

struct TicketCell: View {
    let ticket: Ticket
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(ticket.departaure)
                        .lineLimit(1)
                        .font(.customFont(.sbboldFont, size: 20))
                        .layoutPriority(1)
                    DottedLine()
                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [2]))
                        .frame(height: 1)
                        .foregroundStyle(.black)
                    Image(systemName: "airplane")
                }
                .padding(.trailing,123)
                .padding(.bottom, 8)
                Text(ticket.arrival)
                    .font(.customFont(.sbboldFont, size: 44))
                    .padding(.bottom, 8)
                Text("\(ticket.startDate) ~ \(ticket.endDate)")
                    .font(.customFont(.cafefont, size: 16))
            }.padding(.all, 20)
            HStack{
                Spacer()
                Button(action: {}, label: {
                    Image(systemName: "chevron.forward")
                        .foregroundStyle(Color.white)
                        .background(
                            Circle()
                                .frame(width: 26,height: 26)
                                .foregroundStyle(Color.gray1)
                        )
                    
                })
                .padding(.trailing, 20)
            }
        }.frame(maxWidth: .infinity)
            .background(
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(Color.yellow)
        )
    }
}

//#Preview {
//    TicketCell(ticket: Ticket(departaure: "Seoul", arrival: "Busan", startDate: "2024.1.28", endDate: "2024.04.12", participant: [Person(image: "beef3", name: "강병호"),Person(image: "beef1", name: "김수민"),Person(image: "beef2", name: "하잇"),Person(image: "beef4", name: "면답")], keywords: [.couple,.activity]))
//}
