//
//  FirstScrollView.swift
//  ImageListApp
//
//  Created by 김기영 on 4/11/24.
//

import SwiftUI

struct FirstScrollView: View {
    @ObservedObject var imageViewModel: ImageViewModel
    @ObservedObject var imageLoader: ImageLoader = ImageLoader()
    @State private var count = 0
    @State var timerCount: CGFloat = 0
    @State var imageList:[UIImage] = []
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("It takes \(timerCount) secs")
                
                ForEach(imageViewModel.imageList) { img  in
                    ImageContainer(url: URL(string: img.urls.thumb)!, count: $count)
                }
                
            }
        }.onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
                timerCount += 0.01
                if count == 9 {
                    timer.invalidate()
                }
            }
        }
        //                imageViewModel.getImageList()
    }
}


private struct ImageContainer: View {
    @StateObject var imageLoader: ImageLoader = ImageLoader()
    @State var url: URL?
    @State var image: UIImage?
    @Binding var count: Int
    
    var body: some View {
        VStack {
            if let uiImage = image {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .onAppear{
                        count += 1
                    }
            } else {
                Text("Loading")
            }
        }
        .onAppear{
            if let imgUrl = url {
                imageLoader.loadImage(from: imgUrl) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let data):
                            image = UIImage(data: data)
                        case .failure(_ ):
                            break
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    FirstScrollView(imageViewModel: ImageViewModel())
}
