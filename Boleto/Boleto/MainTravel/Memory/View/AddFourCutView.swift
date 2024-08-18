//
//  AddFourCutView.swift
//  Boleto
//
//  Created by Sunho on 8/15/24.
//

import SwiftUI
import ComposableArchitecture

struct AddFourCutView: View {
    let store: StoreOf<AddFourCutFeature> 
    var images = ["dong", "gas", "beef", "dong", "gas", "beef","dong", "gas", "beef"]
    var body: some View {
        VStack{
            VStack {
                HStack {
                    FourCutImageView(store: store, index: 0)
                    FourCutImageView(store: store, index: 1)
                }
                HStack {
                    FourCutImageView(store: store, index: 2)
                    FourCutImageView(store: store, index: 3)
                }
            }.padding(.all, 18)
                .padding(.bottom, 40)
                .background(
                    Image(store.selectedImage ?? "dong")
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
                    ForEach(Array(store.savedImages.enumerated()), id: \.element ){ index, image in
                        Button(action: {
                            store.send(.selectImage(index, false))
                        }, label: {
                            ZStack {
                                Image(image)
                                    .resizable()
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                    .frame(width: 50)
                                if store.selectedImage == image {
                                    Image(systemName: "checkmark")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .foregroundStyle(Color.mainColor)
                                        .padding(.all,10)
                                        .overlay (
                                            RoundedRectangle(cornerRadius: 15)
                                                .stroke(.white,lineWidth: 2)
                                        )
                                        .background(
                                            RoundedRectangle(cornerRadius: 15)
                                                .foregroundStyle(Color.black.opacity(0.6))
                                        )
                                }
                            }
                        })
                    }
                }
            }.frame(height: 55)
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
                    ForEach(Array(store.defaultImages.enumerated()), id: \.element ){ index, image in
                        Button(action: {
                            store.send(.selectImage(index, true))
                        }, label: {
                            Image(image)
                                .resizable()
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .frame(width: 50)
                        })
                    }
                }
            }.frame(height: 55)
        }
    }
}

#Preview {
    AddFourCutView(store: Store(initialState: AddFourCutFeature.State()) {
        AddFourCutFeature()
    })
}
