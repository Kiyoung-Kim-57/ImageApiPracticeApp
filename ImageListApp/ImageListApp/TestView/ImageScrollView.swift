//
//  FirstScrollView.swift
//  ImageListApp
//
//  Created by 김기영 on 4/11/24.
//

import SwiftUI
//단순하게 스크롤뷰에서 매 요소마다 원본 이미지를 불러오는 스크롤뷰, 이미지 용량이 큰 경우 메모리 사용이 크다
struct ImageScrollView: View {
    @StateObject var imageViewModel: ImageViewModel
    @State private var count = 0
    @State var index = 0
    @State var image: UIImage?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                HStack{
                    Text("\(count) images are loaded")
                }
                
                
                ForEach(0..<imageViewModel.imageList.count, id: \.self) { num  in
                    if let img = imageViewModel.savedImageList[num] {
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
                                if let imgUrl = URL(string: imageViewModel.imageList[num].urls.raw) {
                                    imageViewModel.loadImage(from: imgUrl) { result in
                                        DispatchQueue.main.async {
                                            switch result {
                                            case .success(let data):
                                                image = UIImage(data: data)!
                                                //크기가 정해진 빈 배열(nil로 채워진 배열)에 저장한 이미지를 저장하고 그 때 그 때 꺼내씀
                                                imageViewModel.savedImageList[index] = image
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
    ImageScrollView(imageViewModel: ImageViewModel())
}
