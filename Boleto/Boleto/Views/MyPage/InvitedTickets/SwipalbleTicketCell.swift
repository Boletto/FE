//
//  SwipalbleTicketCell.swift
//  Boleto
//
//  Created by Sunho on 9/13/24.
//

import SwiftUI
import Kingfisher
struct SwipalbleTicketCell: View {
    let ticket: Ticket
    let onAccept: () -> Void
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
                KFImage.url(ticket.smallSizeURL)
                
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text(ticket.departaure.spot.upperString)
                            .lineLimit(1)
                            .font(.customFont(ticket.keywords[0].regularfont, size: 16))
                            .layoutPriority(1)
                        DottedLine()
                            .stroke(style: StrokeStyle(lineWidth: 1, dash: [2]))
                            .frame(height: 1)
                            .foregroundStyle(.black)
                        Image(systemName: "airplane")
                            .resizable()
                            .frame(width: 18,height: 18)
                    }
                    .padding(.trailing,74)
                    .padding(.bottom, 8)
                    Text(ticket.arrival.spot.upperString)
                        .font(.customFont(ticket.keywords[0].regularfont, size: 32))
                        .padding(.bottom, 24)
                    Text("\(ticket.startDate.ticketformat) ~ \(ticket.endDate.ticketformat)")
                        .font(.customFont(ticket.keywords[0].regularfont, size: 13))
                }.padding(.all, 20)
                HStack{
                    Spacer()
                    Button(action: {onAccept()}, label: {
                        if invitedMode {
                            Image(systemName: "checkmark")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 23,height: 16)
                                .foregroundStyle(Color.white)
                                .padding(.all, 14)
                                .background(
                                    Circle()
                                        .fill(Color.gray1)
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
                    DragGesture(minimumDistance: 25.0).onChanged({ value in
                        if value.translation.width < 0 {
                            offset = value.translation.width
                        }
                    })
                    .onEnded{ value in
                        withAnimation {
                            if value.translation.width < -50 {
                                offset = -70
                                
                            }else { offset = 0}
                        }
                    }
                    
                    
                )
        }
        .frame(height: 141)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    SwipalbleTicketCell(ticket: Ticket.mockTickets[0], onAccept: {
        
    }, onDelete: {
        
    }, invitedMode: true)
}
