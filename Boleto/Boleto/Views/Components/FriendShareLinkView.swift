//
//  FriendShareLinkView.swift
//  Boleto
//
//  Created by Sunho on 11/19/24.
//

import SwiftUI

struct FriendShareLinkView: View {
    let baseUrlString = "https://boletto.site"
    @Binding var shareUrl: URL?
    @Binding var message: String
    let getCode: () -> Void
    @State private var isProcessingShare = false
    var body: some View {
        if let shareUrl = shareUrl, !isProcessingShare {
            ShareLink(item: shareUrl, subject: Text("친구를 맺어요"), message: Text(message + "\n" + shareUrl.absoluteString)) {
                shareButton
            }
        } else {
            Button {
                getCode()
            } label: {
                shareButton
            }
        }
       }
    private var shareButton: some View {
           Label {
               Text("친구 추가 링크 공유하기")
                   .customTextStyle(.smallBtn)
                   .foregroundStyle(.gray1)
           } icon: {
               Image(systemName: "link")
                   .resizable()
                   .frame(width: 16, height: 16)
                   .foregroundStyle(.gray1)
                   .padding(.leading, 24)
           }
           .frame(maxWidth: .infinity)
           .frame(height: 46)
           .background {
               RoundedRectangle(cornerRadius: 12)
                   .fill(Color.mainColor)
           }
       }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
