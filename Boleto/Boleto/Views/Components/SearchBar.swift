//
//  SearchBar.swift
//  Boleto
//
//  Created by Sunho on 8/26/24.
//

import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    let placeholder: String
    //    let onErase: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.white)
                .opacity(0.6)
            
            TextField(placeholder, text: $text, prompt: Text("Search").foregroundStyle(.gray5))
                .foregroundColor(.primary)
                .tint(.white)
            Spacer()
            if !text.isEmpty {
                Button(action: {
                    self.text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(8)
        .background(Color.gray2)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal, 16)
        
    }
}
