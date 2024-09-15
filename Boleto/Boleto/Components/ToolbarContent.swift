//
//  ToolbarContent.swift
//  Boleto
//
//  Created by Sunho on 9/14/24.
//

import SwiftUI


struct ToolbarContent: View {
    let notiTap: () -> Void
    let settingTap: () -> Void
    var body: some View {
        HStack {
            Button(action: {
                notiTap()
            }, label: {
                Image(systemName: "bell")
                    .foregroundStyle(.white)
            })
            Button(action: {settingTap()}, label: {
                Image(systemName: "gearshape")
                    .foregroundStyle(.white)
            })
        }
    }
    
}
