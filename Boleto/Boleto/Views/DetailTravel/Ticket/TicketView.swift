//
//  TicketView.swift
//  Boleto
//
//  Created by Sunho on 9/5/24.
//
import Kingfisher
import SwiftUI

struct TicketView: View {
    @Binding var showModal: Bool
    let ticket: Ticket
    let tapNavigate: () -> Void
    @State private var showAlert = false
    var body: some View {
        singleticketView
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("저장 완료"),
                    message: Text("이미지가 성공적으로 갤러리에 저장되었습니다"),
                    dismissButton: .default(Text("OK"))
                )
            }
    }
    func travelWithView(_ persons: [MemberModel]) -> some View {
        HStack(spacing: 12) {
            ForEach(persons.prefix(4), id: \.id) { person in
                VStack(spacing: 5) {
                    Group {
                        if let imageUrl = person.imageUrl {
                            URLImageView(urlstring: imageUrl, size: CGSize(width: 42, height: 42))
                        } else {
                            Image("defaultprofile")
                                .resizable()
                        }
                    }
                    .frame(width: 42, height: 42)
                    .clipShape(Circle())
                    .overlay {
                        Circle().stroke(.gray2, lineWidth: 1)
                    }
                    Text(person.nickname)
                        .font(.customFont(ticket.keywords[0].regularfont, size: 11))
                }
            }
            if persons.count > 4 {
                VStack {
                    ZStack {
                        Circle()
                            .fill(Color.gray2)
                            .frame(width: 42, height: 42)
                        
                        Text("+\(persons.count - 4)")
                            .font(.customFont(ticket.keywords[0].boldfont, size: 11))
                            .foregroundColor(.white)
                    }
                    Text("")
                }.onTapGesture {
                    showModal = true
                }
            }
        }
    }
    var singleticketView: some View {
        let isSmallDevice = self.getScreenBounds().height < 700
        return VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                Text(ticket.departaure.spot.upperString)
                    .font(.customFont(ticket.keywords[0].boldfont, size: isSmallDevice ? 8 :  16))
                    .lineLimit(1)
                    .layoutPriority(1)
                Spacer().frame(width: 18)
                DottedLine()
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [3]))
                    .frame(height: 1)
                    .foregroundStyle(.black)
                Spacer().frame(width: 10)
                Image(systemName: "airplane")
                    .resizable()
                    .frame(width:isSmallDevice ? 16 :  24,height: isSmallDevice ? 16 : 24)
                    .padding(.trailing, 2)
            }
            .padding(.bottom, isSmallDevice ? 14 : 28)
            Text(ticket.arrival.spot.upperString)
                .font(.customFont(ticket.keywords[0].boldfont, size: isSmallDevice ? 26 : 40))
                .lineLimit(1)
                .padding(.bottom, isSmallDevice ? 16 : 30)
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
                Text(ticket.startDate.toString("YYYY.MM.dd"))
                    .frame(width: 130)
                    .font(.customFont(ticket.keywords[0].boldfont, size: 21))
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
            }
            .frame(height: 51)
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
                Text(ticket.endDate.toString("YYYY.MM.dd"))
                    .frame(width: 130)
                    .font(.customFont(ticket.keywords[0].boldfont, size: 21))
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
            }
            .frame(height: 51)
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
            .frame(maxHeight: 62)
            Rectangle().frame(height: 1)
                .padding(.bottom, 21)
            Text("Travel With")
                .font(.customFont(ticket.keywords[0].boldfont, size: 16))
            travelWithView(ticket.participant)
                .padding(.top, 7)
                .padding(.bottom,isSmallDevice ? 10 : 24)
            Image("barcode")
                .resizable()
                .frame(height: isSmallDevice ? 24 : 38)
                .padding(.horizontal,25)
                .padding(.bottom, isSmallDevice ? 10 : 24)
            HStack {
                Spacer()
                Image("logo")
                    .resizable()
                    .frame(width: 103,height: 28)
                Spacer()
            }
        }
        .padding(.horizontal, 20)
        .padding(.top,isSmallDevice ? 16 : 30)
        .padding(.bottom,isSmallDevice ? 12 : 26)
        .frame(height: isSmallDevice ? self.getScreenBounds().height * 0.75: self.getScreenBounds().height * 0.7)
        .frame(width: self.getScreenBounds().width * 0.83)
            .background(
                KFImageView(url: ticket.fullSizeURL)
            )
    }
}

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
#Preview {
    TicketView(showModal: .constant(false), ticket: Ticket.mockTickets[0], tapNavigate: {
        print("HI")
    })
}
