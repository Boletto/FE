//
//  NumsParticipantsView.swift
//  Boleto
//
//  Created by Sunho on 9/7/24.
//

import SwiftUI

struct NumsParticipantsView: View {
    let personNum: Int
    var body: some View {
       ZStack {
           Circle()
               .fill(.gray1)
               .frame(width: 22,height: 22)
           ZStack {
               Circle()
                   .fill(.gray2)
                   .frame(width: 18,height: 18)
               Text("\(personNum)")
                   .customTextStyle(.small)
                   .foregroundStyle(.white)
               
           }
        }
    }
}

