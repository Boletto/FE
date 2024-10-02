//
//  ToolbarContent.swift
//  Boleto
//
//  Created by Sunho on 9/14/24.
//

import SwiftUI
import ComposableArchitecture

struct CommonToolbar: ToolbarContent {
    let store: StoreOf<AppFeature>
    let title: String?
    var body: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            if let title = title {
                Text(title)
                    .foregroundStyle(.white)
            }
            else {
                Image("logo")
                    .resizable()
                    .frame(width: 68, height: 20)
            }
        }
        ToolbarItem(placement: .topBarTrailing) {
            HStack {
                Button(action: {
                    store.send(.tabNotification)
                }, label: {
                    Image(systemName: "bell")
                        .foregroundStyle(.white)
                })
                Button(action: {
                    store.send(.tabmyPage)
                }, label: {
                    Image(systemName: "person")
                        .foregroundStyle(.white)
                })
            }
        }
    }
}
