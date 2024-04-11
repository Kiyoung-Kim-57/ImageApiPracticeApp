//
//  AsyncImageView.swift
//  ImageListApp
//
//  Created by 김기영 on 4/11/24.
//

import SwiftUI

struct AsyncImageView: View {
    @StateObject var imageViewModel: ImageViewModel = ImageViewModel()
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                ForEach(imageViewModel.imageList) { img  in
                    if let imgURL = URL(string: img.urls.thumb) {
                        AsyncImage(url: imgURL ) { img in
                            img
                                .resizable()
                                .scaledToFit()
                                .frame(width: 250)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                            
                        } placeholder: {
                            Text("Loading")
                        }
                    }
                }
            }
        }.onAppear {
            //                imageViewModel.getImageList()
        }
        
    }
}

#Preview {
    AsyncImageView()
}
