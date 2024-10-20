//
//  AddFourCutView.swift
//  Boleto
//
//  Created by Sunho on 8/15/24.
//

import SwiftUI
import ComposableArchitecture

struct AddFourCutView: View {
    @Environment(\.dismiss) var dismiss
    let store: StoreOf<AddFourCutFeature>
    var body: some View {
        VStack{
            fourCutView
            savedFrameView
                .padding(.top, 24)
                .padding(.leading,32)
            defaultFrameView
                .padding(.top, 24)
                .padding(.leading,32)
            Spacer()
            Button(action: {
                if store.isAbleToImage {
                    store.send(.finishTapped)
                } else {
                    print("error")
                }
              
            }, label: {
                Text("완료")
                    .foregroundStyle(.black)
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.mainColor)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }).padding(.horizontal, 16)
            
        }
        .task {
            store.send(.fetchFrame)
        }
        .applyBackground(color: .background)
        .customNavigationBar(centerView: {
            Text("네컷사진 추가")
                .foregroundStyle(.white)
        }, leftView: {
            Button (action: {dismiss()}, label: {
                Image(systemName: "xmark")
                    .foregroundColor(.white)
            })

        })        
    }
    var fourCutView: some View {
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
                Group {
                    if store.isDefaultFrameSelected {
                        Image(store.selectedFrame.imageUrl ?? "whiteFrame" )
                            .resizable()
                            .frame(height: 338)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    else {
                        URLImageView(urlstring: store.selectedFrame.imageUrl ?? "whiteFrame")
                            .frame(height: 338)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                }    .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray6, lineWidth: 1) // Adding 2pt white stroke
                )
            )
        
    }
    var savedFrameView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("저장된 프레임")
                .foregroundStyle(.white)
                .font(.system(size: 12, weight: .semibold))
                .padding(.bottom, 10)
            ScrollView(.horizontal) {
                LazyHGrid(rows: [GridItem(.fixed(50), spacing: 20)])  {
                    ForEach(store.savedImages, id: \.idx){ frameitem in
                        Button(action: {
                            store.send(.selectImage(frameitem, isDefault: false))
                        }, label: {
                            ZStack {
                                URLImageView(urlstring: frameitem.imageUrl,size: CGSize(width: 50, height: 50))
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                    .frame(width: 50)
                                if store.selectedFrame == frameitem {
                                    Image(systemName: "checkmark")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .foregroundStyle(Color.mainColor)
                                        .padding(.all,10)
                                        .overlay (
                                            RoundedRectangle(cornerRadius: 15)
                                                .stroke(.main,lineWidth: 2)
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
    var defaultFrameView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("기본 프레임")
                .foregroundStyle(.white)
                .font(.system(size: 12, weight: .semibold))
                .padding(.bottom, 10)
            ScrollView(.horizontal) {
                LazyHGrid(rows: [GridItem(.fixed(50), spacing: 20)])  {
                    ForEach(store.defaultImages, id: \.idx ){ item in
                        Button(action: {
                            store.send(.selectImage(item, isDefault: true))
                        }, label: {
                            ZStack {
                                Image(item.imageUrl)
                                    .resizable()
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                    .frame(width: 50)
                                if store.selectedFrame == item {
                                    Image(systemName: "checkmark")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .foregroundStyle(Color.mainColor)
                                        .padding(.all,10)
                                        .overlay (
                                            RoundedRectangle(cornerRadius: 15)
                                                .stroke(.main,lineWidth: 2)
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
}

//#Preview {
//    AddFourCutView(store: Store(initialState: AddFourCutFeature.State()) {
//        AddFourCutFeature()
//    })
//}
