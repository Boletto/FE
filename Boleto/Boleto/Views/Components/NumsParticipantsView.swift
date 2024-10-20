//
//  NumsParticipantsView.swift
//  Boleto
//
//  Created by Sunho on 9/7/24.
//

import SwiftUI

struct NumsParticipantsView: View {
    let personNum: Int
    @Binding var isLocked: Bool
    var body: some View {
       ZStack {
           Circle()
               .fill(isLocked ? .red1 : .gray1)
               .frame(width: 22,height: 22)
           ZStack {
               Circle()
                   .fill(isLocked ? .red2: .gray2)
                   .frame(width: 18,height: 18)
               Text("\(personNum)")
                   .customTextStyle(.small)
                   .foregroundStyle(.white)
               
           }
        }
    }
}

