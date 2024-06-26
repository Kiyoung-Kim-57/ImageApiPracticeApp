//
//  AsyncImageView.swift
//  ImageListApp
//
//  Created by 김기영 on 4/11/24.
//

import SwiftUI
//AsyncImage를 활용해서 간단하고 가독성 좋게 만든 스크롤 뷰
struct AsyncImageView: View {
    @StateObject var imageViewModel: ImageViewModel
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                ForEach(imageViewModel.imageList) { img  in
                    if let imgURL = URL(string: img.urls.raw) {
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
        
    }
}

#Preview {
    AsyncImageView(imageViewModel: ImageViewModel())
}
