//
//  TicketView.swift
//  Boleto
//
//  Created by Sunho on 9/5/24.
//

import SwiftUI

struct TicketView: View {
    let ticket: Ticket
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(.yellow)
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 0) {
                    Text(ticket.departaure)
                        .font(.customFont(ticket.keywords[0].boldfont, size: 25))
                    Spacer().frame(width: 8)
                    DottedLine()
                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [3]))
                        .frame(height: 1)
                        .foregroundStyle(.black)
                    Spacer().frame(width: 10)
                    Image(systemName: "airplane")
                        .resizable()
                        .frame(width: 24,height: 24)
                        .padding(.trailing, 2)
                }
                .padding(.bottom, 21)
                Text(ticket.arrival)
                    .font(.customFont(ticket.keywords[0].boldfont, size: 62))
                    .padding(.bottom, 24)
                Rectangle().frame(height: 3)
                HStack(spacing: 0) {
                    Text("DEP\nDATE")
                        .font(.customFont(ticket.keywords[0].boldfont, size: 16))
                        .frame(width: 108, alignment: .leading)
                        .padding(.leading, 1)
                    Rectangle()
                        .frame(width: 1,height: 56)
                        .padding(.trailing,14)
                        .padding(.vertical, 2)
                    Text(ticket.startDate)
                        .font(.customFont(ticket.keywords[0].boldfont, size: 21))
                }
                Rectangle().frame(height: 1)
                HStack(spacing: 0) {
                    Text("ARR\nDATE")
                        .font(.customFont(ticket.keywords[0].boldfont, size: 16))
                        .frame(width: 108, alignment: .leading)
                        .padding(.leading, 1)
                    Rectangle()
                        .frame(width: 1,height: 56)
                        .padding(.trailing,14)
                        .padding(.vertical, 2)
                    Text(ticket.endDate)
                        .font(.customFont(ticket.keywords[0].boldfont, size: 21))
                }
                Rectangle().frame(height: 1)
                HStack(spacing: 0) {
                    Text("TRAVEL\nFOR")
                        .font(.customFont(ticket.keywords[0].boldfont, size: 16))
                        .frame(width: 108, alignment: .leading)
                        .padding(.leading, 1)
                    Rectangle()
                        .frame(width: 1,height: 56)
                        .padding(.trailing,14)
                        .padding(.vertical, 2)
               
                
                    FlowLayout(hspacing: 7, vSpacing: 6) {
                            ForEach(ticket.keywords, id: \.self) { keyword in
                                Text(keyword.rawValue)
                                    .lineLimit(1)
                                    .font(.customFont(ticket.keywords[0].regularfont, size: 10))
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 11)
                                    .background(Capsule().stroke(style: StrokeStyle(lineWidth: 1)))
                            }
                        }
                 
                }
                Rectangle().frame(height: 1)
                    .padding(.bottom, 21)
                Text("Travel With")
                    .font(.customFont(ticket.keywords[0].boldfont, size: 16))
                travelWithView(ticket.participant)
                    .padding(.top, 7)
                    .padding(.bottom, 24)
                HStack(spacing: 6){
                    Rectangle()
                        .frame(width: 11,height: 36)
                    Rectangle()
                        .frame(width: 11,height: 36)
                    Rectangle()
                        .frame(width: 11,height: 36)
                    Rectangle()
                        .frame(width: 11,height: 36)
        
                    Rectangle()
                        .frame(width: 11,height: 36)
                    Rectangle()
                        .frame(width: 11,height: 36)
                    Rectangle()
                        .frame(width: 11,height: 36)
                    Rectangle()
                        .frame(width: 11,height: 36)
                    Rectangle()
                        .frame(width: 11,height: 36)
                    Rectangle()
                        .frame(width: 11,height: 36)
                    Rectangle()
                        .frame(width: 11,height: 36)
                }
                .padding(.bottom, 16)
                HStack {
                    Spacer()
                    Image("logo")
                        .frame(width: 161,height: 43)
                    Spacer()
                }
       
                
            }.padding(.horizontal, 20)
        }.frame(width: 329,height: 600)
    }
    func travelWithView(_ persons: [Person]) -> some View {
        HStack(spacing: 21) {
            ForEach(persons.prefix(4).indices, id: \.self) { index in
                        let person = persons[index]
                        VStack(spacing: 5) {
                            Image("\(person.image)")
                                .resizable()
                                .frame(width: 42, height: 42)
                                .clipShape(Circle())
                                .overlay {
                                    Circle().stroke(.gray2, lineWidth: 1)
                                }
                            
                            Text(person.name)
                                .font(.customFont(ticket.keywords[0].regularfont, size: 8))
                        }
                    }
            if persons.count > 4 {
                VStack {
                    ZStack {
                        Circle()
                            .fill(Color.gray2)
                            .frame(width: 42, height: 42)
                        
                        Text("+\(persons.count - 4)")
                            .font(.customFont(ticket.keywords[0].boldfont, size: 9))
                            .foregroundColor(.white)
                    }
                    Text("")
                }
            }
        }
    }
}
//
//#Preview {
//    TicketView(ticket: Ticket(departaure: "Seoul", arrival: "Busan", startDate: "2024.1.28", endDate: "2024.04.12", participant: [Person(image: "beef3", name: "강병호"),Person(image: "beef1", name: "김수민"),Person(image: "beef2", name: "하잇"),Person(image: "beef4", name: "면답"), Person(image: "beef2", name: "호잇")], keywords: [.activity,.shopping,.backpacking]))
//    
//}
struct FlowLayout: Layout {
    var hspacing: CGFloat
    var vSpacing: CGFloat
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let subSizes = subviews.map { $0.sizeThatFits(proposal) }

        let proposedWidth = proposal.width ?? .infinity
        var maxRowWidth = CGFloat.zero
        var rowCount = CGFloat.zero
        var x = CGFloat.zero
        for subSize in subSizes {
            // This prevents empty rows if any subviews are wider than proposedWidth.
            let lineBreakAllowed = x > 0

            if lineBreakAllowed, x + subSize.width + hspacing > proposedWidth {
                rowCount += 1
                x = 0
            }

            x += subSize.width + hspacing
            maxRowWidth = max(maxRowWidth, x - hspacing)
        }

        if x > 0 {
            rowCount += 1
        }

        let rowHeight = subSizes.lazy.map { $0.height }.max() ?? 0
        return CGSize(
            width: proposal.width ?? maxRowWidth,
            height: rowCount * rowHeight
        )
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let subSizes = subviews.map { $0.sizeThatFits(proposal) }
        let rowHeight = subSizes.lazy.map { $0.height }.max() ?? 0
        let proposedWidth = proposal.width ?? .infinity

        var p = CGPoint.zero
        for (subview, subSize) in zip(subviews, subSizes) {
            // This prevents empty rows if any subviews are wider than proposedWidth.
            let lineBreakAllowed = p.x > 0

            if lineBreakAllowed, p.x + subSize.width + hspacing > proposedWidth {
                p.x = 0
                p.y += rowHeight + vSpacing
            }

            subview.place(
                at: CGPoint(
                    x: bounds.origin.x + p.x,
                    y: bounds.origin.y + p.y + 0.5 * (rowHeight - subSize.height)
                ),
                proposal: proposal
            )

            p.x += subSize.width + hspacing
        }
    }
}
