//
//  NumsParticipantsView.swift
//  Boleto
//
//  Created by Sunho on 9/7/24.
//

import SwiftUI

struct NumsParticipantsView: View {
    let personNum: Int
//    var onPositionChange: (CGPoint) -> Void
    var body: some View {
        ZStack {
            Capsule().foregroundStyle(.gray1)
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .frame(width: 18, height: 18)
                        .foregroundStyle(.gray2)
                    Text("\(personNum)")
                        .font(.system(size: 11))
                        .foregroundStyle(.white)
                }
      
                   
                      
                Image(systemName: "chevron.down")
                    .foregroundStyle(.white)
            }.padding(.all, 2)
                .padding(.trailing, 2)
        }
        .frame(width: 40, height: 22)
//        .background(GeometryReader { geo in
//            Color.clear.ona
//        })
    }
}

