//
//  EmptyPhotoView.swift
//  Boleto
//
//  Created by Sunho on 8/12/24.
//

import SwiftUI

struct EmptyPhotoView: View {
    var body: some View {
        Image(systemName: "plus")
            .frame(maxWidth: .infinity  , maxHeight: .infinity)
            .background{
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.gray, style: StrokeStyle(lineWidth: 1, dash: [10]))
            }

    }
}

#Preview {
    EmptyPhotoView()
}
