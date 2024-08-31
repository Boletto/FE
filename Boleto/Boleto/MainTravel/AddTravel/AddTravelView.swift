//
//  AddTravelView.swift
//  Boleto
//
//  Created by Sunho on 8/31/24.
//

import SwiftUI
import ComposableArchitecture

struct AddTravelView: View {
    @Bindable var store: StoreOf< AddTravelFeature>
    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            VStack {
                Text("JI")
            }
        }destination: { store in
            switch store.case {
            case .makeTicket:
                AddTicketView()
            }
        }
    }
}

//#Preview {
//    AddTravelView(store: )
//}
