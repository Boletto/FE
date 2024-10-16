//
//  TravelCompanionsView.swift
//  Boleto
//
//  Created by Sunho on 9/8/24.
//

import SwiftUI

struct TravelCompanionsView: View {

    let persons: [Person]
    var body: some View {
        ZStack{
                Color.modal
                VStack {
                    ZStack {
                        Text("함께하는 친구")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.white)
                        HStack {
                           Spacer()
                            Image(systemName: "person.fill.badge.plus")
                                .foregroundStyle(.main)
                        }
                    }
                    .padding(.trailing, 16)
                    .padding(.vertical, 10)
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(persons, id: \.name) { person in
                                HStack {
                                    Image(person.image)
                                        .resizable()
                                        .frame(width: 24,height: 24)
                                        .clipShape(Circle())
                                    Text(person.name)
                                        .foregroundStyle(.white)
                                        .font(.system(size: 11))
                                    Spacer()
                                    Image(systemName: "trash")
                                        .foregroundStyle(.gray4)
                                    
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                }
        }
        .frame(width: 199, height:  204)
        .clipShape(.rect(cornerRadius: 10))
    }
}

//#Preview {
//    TravelCompanionsView(isPresented: .constant(true), persons: [Person(image: "beef3", name: "강병호"),Person(image: "beef1", name: "김수민"),Person(image: "beef2", name: "하잇"),Person(image: "beef4", name: "면답"), Person(image: "beef2", name: "호잇")])
//}
