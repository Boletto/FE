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
    var columns: [GridItem] = [GridItem(.flexible(), spacing: 16), GridItem(.flexible())]
    var rotations: [Double] = [-4.5, 4.5, 4.5, -4.5, -4.5, 4.5, -4.5, 4.5, -4.5, 4.5]

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Spacer()
                NumsParticipantsView(personNum: store.ticket.participant.count)
            }.padding(.top, 44)
                .padding(.trailing, 32)

            ZStack {
                TicketView(ticket: store.ticket)
                    .opacity(store.flipped ? 0.0 : 1.0)
                
                ZStack {
                    LazyVGrid(columns: columns, spacing: 32) {
                        ForEach(0..<store.imagesString.count, id: \.self) { index in
                            PolaroidView(imageView: Image(store.imagesString[index]), showTrashButton: false)
                                .frame(width: 126, height: 145)
                                .rotationEffect(Angle(degrees: rotations[index % rotations.count]))
                        }
                    }
                }
                .opacity(store.flipped ? 1.0 : 0.0)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 80)
            .modifier(FlipEffect(flipped: store.flipped, angle: store.flipped ? 180 : 0, axis: (x: 0, y: 1)))
            .onTapGesture {
                store.send(.tapTicket, animation: .linear(duration: 0.8))
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("지난 여행")
                    .foregroundStyle(.white)
            }
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    store.send(.tapgobackView)
                } label: {
                    Image(systemName: "chevron.backward")
                        .foregroundStyle(.white)
                }
            }
        }
        .applyBackground(color: .background)
    }
}

struct FlipEffect: GeometryEffect {
    var animatableData: Double {
        get { angle }
        set { angle = newValue }
    }

    var flipped: Bool
    var angle: Double
    let axis: (x: CGFloat, y: CGFloat)

    func effectValue(size: CGSize) -> ProjectionTransform {
        let tweakedAngle = flipped ? -180 + angle : angle
        let a = CGFloat(Angle(degrees: tweakedAngle).radians)

        var transform3d = CATransform3DIdentity
        transform3d.m34 = -1/max(size.width, size.height)

        transform3d = CATransform3DRotate(transform3d, a, axis.x, axis.y, 0)
        transform3d = CATransform3DTranslate(transform3d, -size.width/2.0, -size.height/2.0, 0)

        let affineTransform = ProjectionTransform(CGAffineTransform(translationX: size.width/2.0, y: size.height / 2.0))

        return ProjectionTransform(transform3d).concatenating(affineTransform)
    }
}

