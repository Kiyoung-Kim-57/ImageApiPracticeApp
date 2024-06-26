//
//  ResizedImageView.swift
//  ImageListApp
//
//  Created by 김기영 on 4/13/24.
//

import SwiftUI
//이미지 데이터를 디코딩하고 리사이징한 후에 표시하는 스크롤뷰 -> 리사이징이 cpu 자원을 많이 사용, 완료 후에는 메모리 용량을 덜 사용
struct ResizedImageView: View {
    @StateObject var imageViewModel: ImageViewModel
    @State private var count = 0
    @State var timerCount: CGFloat = 0
    @State var index = 0
    @State var image: UIImage?
    
    var body: some View {
        ScrollView {
            //Improve Scroll performance with lazyvstack
            VStack(spacing: 30) {
                Text("\(count) images are loaded")
                
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
                                        
                                        switch result {
                                        case .success(let data):
                                            //리사이징 후에 바로 뷰에 업데이트
                                            image = UIImage(data: data)!.resize(ratio: 0.5)
                                            //크기가 정해진 빈 배열(nil로 채워진 배열)에 저장한 이미지를 저장하고 그 때 그 때 꺼내씀
                                            DispatchQueue.main.async {
                                                
                                                imageViewModel.savedImageList[index] = image
                                                index += 1
                                                //인덱스가 10개가 넘어가면 처음으로 돌아감
                                                if index > 9 {
                                                    index = 0
                                                }
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
        }.onAppear {
            //                imageViewModel.getImageList()
        }
       
    }
}

#Preview {
    ResizedImageView(imageViewModel: ImageViewModel())
}
