//
//  FirstScrollView.swift
//  ImageListApp
//
//  Created by 김기영 on 4/11/24.
//

import SwiftUI

struct LazyScrollView: View {
    @StateObject var imageViewModel: ImageViewModel
    @StateObject var imageLoader: ImageLoader
    @State private var count = 0
    @State var index = 0
    @State var image: UIImage?
    
    var body: some View {
        ScrollView {
            //Improve Scroll performance with lazyvstack
            LazyVStack(spacing: 30) {
                HStack{
                    Text("\(count) images are loaded")
                }
                
                
                ForEach(0..<imageViewModel.imageList.count, id: \.self) { num  in
                    if let img = imageLoader.imageList[num] {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 250)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .onAppear{
                                count += 1
                                print(count)
                            }
                    } else {
                        Text("Loading")
                            .frame(width: 250, height: 250)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .onAppear{
                                if let imgUrl = URL(string: imageViewModel.imageList[num].urls.thumb) {
                                    imageLoader.loadImage(from: imgUrl) { result in
                                        DispatchQueue.main.async {
                                            switch result {
                                            case .success(let data):
                                                image = UIImage(data: data)!
                                                //크기가 정해진 빈 배열(nil로 채워진 배열)에 저장한 이미지를 저장하고 그 때 그 때 꺼내씀
                                                imageLoader.imageList[index] = image
                                                index += 1
                                                //인덱스가 10개가 넘어가면 처음으로 돌아감
                                                if index > 9 {
                                                    index = 0
                                                }
                                                
                                            case .failure(_ ):
                                                break
                                            }
                                        }
                                    }
                                }
                            }
                    }
                }
                
            }
        }
    }
}




#Preview {
    LazyScrollView(imageViewModel: ImageViewModel(), imageLoader: ImageLoader())
}
