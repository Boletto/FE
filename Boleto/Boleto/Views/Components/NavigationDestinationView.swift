//
//  NavigationDestinationView.swift
//  Boleto
//
//  Created by Sunho on 12/9/24.
//
import SwiftUI

struct NavigationDestinationView<Content: View>: View {
    let content: Content
    let title: String?
    @Environment(\.dismiss) private var dismiss
    
    init(title: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        content
            .toolbarBackground(Color.background, for: .navigationBar)
            .applyBackground(color: .background)
            .navigationBarBackButtonHidden()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if let title = title {
                    ToolbarItem(placement: .principal) {
                        Text(title)
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.backward")
                            .foregroundStyle(.white)
                    }
                }
            }
    }
}
