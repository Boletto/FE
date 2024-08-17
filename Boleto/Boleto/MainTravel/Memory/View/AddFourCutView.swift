//
//  AddFourCutView.swift
//  Boleto
//
//  Created by Sunho on 8/15/24.
//

import SwiftUI

struct AddFourCutView: View {
    //    @Binding var isopen: Bool
    var images = ["dong", "gas", "beef", "dong", "gas", "beef","dong", "gas", "beef"]
    var body: some View {
        VStack{
            VStack {
                HStack {
                    EmptyFourCutView()
                    EmptyFourCutView()
                    
                }
                HStack {
                    EmptyFourCutView()
                    EmptyFourCutView()
                    
                }
            }.padding(.all, 18)
                .padding(.bottom, 40)
                .background(
                    Image("dong")
                        .resizable()
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                )
            savedFrame
                .padding(.leading,32)
            defaultFrames
                .padding(.leading,32)
            Spacer()
            Button(action: {}, label: {
                Text("완료")
                    .foregroundStyle(.black)
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.mainColor)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }).padding(.horizontal, 16)
            
        }
        .applyBackground()
        .customNavigationBar(centerView: {
            Text("네컷사진 추가")
                .foregroundStyle(.white)
        }, leftView: {
            Image(systemName: "xmark")
                .foregroundColor(.white)
        })        
    }
    var savedFrame: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("저장된 프레임")
                .foregroundStyle(.white)
                .font(.system(size: 12, weight: .semibold))
                .padding(.bottom, 10)
            ScrollView(.horizontal) {
                LazyHGrid(rows: [GridItem(.fixed(50), spacing: 0)])  {
                    ForEach(images, id: \.self ){ image in
                        Button(action: {
                            
                        }, label: {
                            Image(image)
                                .resizable()
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .frame(width: 50)
                        })
                    }
                }
            }.frame(height: 50)
        }
    }
    var defaultFrames: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("기본 프레임")
                .foregroundStyle(.white)
                .font(.system(size: 12, weight: .semibold))
                .padding(.bottom, 10)
            ScrollView(.horizontal) {
                LazyHGrid(rows: [GridItem(.fixed(50), spacing: 0)])  {
                    ForEach(images, id: \.self ){ image in
                        Button(action: {
                            
                        }, label: {
                            Image(image)
                                .resizable()
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .frame(width: 50)
                        })
                    }
                }
            }.frame(height: 50)
        }
    }
}

#Preview {
    AddFourCutView()
}
