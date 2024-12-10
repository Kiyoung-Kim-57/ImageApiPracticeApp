//
//  AsyncImageView.swift
//  ImageListApp
//
//  Created by 김기영 on 4/11/24.
//

import SwiftUI
//AsyncImage를 활용해서 간단하고 가독성 좋게 만든 스크롤 뷰
struct AsyncImageView: View {
    @ObservedObject var imageViewModel: ImageViewModel
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                imageList(list: imageViewModel.imageList)
            }
        }
    }
}

extension AsyncImageView {
    private func imageList(list: [ImageDTO]) -> some View {
        ForEach(list) { img in
            if let imgURL = URL(string: img.imageSizeURL.raw) {
                AsyncImage(url: imgURL ) { img in
                    img
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                } placeholder: {
                    Text("Loading")
                        .frame(width: 250, height: 250)
                }
            }
        }
    }
}
