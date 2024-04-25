//
//  ResizeInBgView.swift
//  ImageListApp
//
//  Created by 김기영 on 4/13/24.
//

import SwiftUI
//리스트의 이미지들 리사이징을 백그라운드에서 비동기로 진행, cpu,메모리 효율이 매우 좋지 않다.
struct ResizeInBgView: View {
    @StateObject var imageViewModel: ImageViewModel
    @State private var count = 0
    @State var index = 0
    @State var image: UIImage?
    
    var body: some View {
        ScrollView {
            //Improve Scroll performance with lazyvstack
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
                                        
                                            switch result {
                                            case .success(let data):
                                                Task {
                                                    //이미지 리사이징을 다른 스레드에서 진행
                                                    //CPU, 메모리 자원을 엄청 먹음
                                                    image = try await imageViewModel.resizeImage(image: UIImage(data: data)!)
                                                    
                                                    //크기가 정해진 빈 배열(nil로 채워진 배열)에 저장한 이미지를 저장하고 그 때 그 때 꺼내씀
                                                    //비동기로 저장하다보니 매번 저장되는 순서가 뒤죽박죽
                                                    //TODO: 시리얼 큐를 시도해보자, 혹은 Actor?, 혹은 캐싱을 딕셔너리 방식?
                                                    DispatchQueue.main.async {
                                                        //퍼블리싱 변수에 접근하므로 메인스레드에서 진행
                                                        imageViewModel.savedImageList[index] = image
                                                        index += 1
                                                        //인덱스가 10개가 넘어가면 처음으로 돌아감
                                                        if index > 9 {
                                                            index = 0
                                                        }
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
        }
        
    }
}

#Preview {
    ResizeInBgView(imageViewModel: ImageViewModel())
}
