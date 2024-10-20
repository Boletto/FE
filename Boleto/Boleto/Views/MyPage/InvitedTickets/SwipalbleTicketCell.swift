//
//  SwipalbleTicketCell.swift
//  Boleto
//
//  Created by Sunho on 9/13/24.
//

import SwiftUI

struct SwipalbleTicketCell: View {
    let ticket: Ticket
    let onAccpet: () -> Void
    let onDelete: () -> Void
    let invitedMode: Bool
    @State private var offset: CGFloat = 0
    @State private var showDeleButton = false
    var body: some View {
        ZStack {
            Color.red
            HStack {
                Spacer()
                Button(invitedMode ? "거절하기" : "삭제하기") {
                    onDelete()
                }
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white)
                .padding(.trailing)
            }
            ZStack {
                ticket.color.color
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text(ticket.departaure.upperString)
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
                    Text(ticket.arrival.upperString)
                        .font(.customFont(.sbboldFont, size: 44))
                        .padding(.bottom, 8)
                    Text("\(ticket.startDate.ticketformat) ~ \(ticket.endDate.ticketformat)")
                        .font(.customFont(.cafefont, size: 16))
                }.padding(.all, 20)
                HStack{
                    Spacer()
                    Button(action: {onAccpet()}, label: {
                        if invitedMode {
                            Image(systemName: "checkmark")
                                .resizable()
                                .frame(width: 29,height: 29)
                                .foregroundStyle(Color.white)
                                .background(
                                    Circle()
                                        .frame(width: 42,height: 42)
                                        .foregroundStyle(Color.gray1)
                                )
                        } else {
                            Image(systemName: "chevron.forward")
                                .foregroundStyle(Color.white)
                                .background(
                                    Circle()
                                        .frame(width: 26,height: 26)
                                        .foregroundStyle(Color.gray1)
                                )
                        }
       
                        
                    })
                    .padding(.trailing, 20)
                }
            }.frame(height: 141)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .offset(x: offset)
                .gesture(
                    DragGesture().onChanged({ value in
                        if value.translation.width < 0 {
                            offset = value.translation.width
                        }
                    })
                    .onEnded({ value in
                        withAnimation {
                            if value.translation.width < -50 {
                                offset = -70
                                
                            }else { offset = 0}
                        }
                    }))
        }
        .frame(height: 141)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

//#Preview {
//    SwipalbleTicketCell(ticket: Ticket(departaure: "Seoul", arrival: "Busan", startDate: "2024.1.28", endDate: "2024.04.12", participant: [Person(image: "beef3", name: "강병호"),Person(image: "beef1", name: "김수민"),Person(image: "beef2", name: "하잇"),Person(image: "beef4", name: "면답")], keywords: [.activity])) {
//        print("HI")
//    }
//}
