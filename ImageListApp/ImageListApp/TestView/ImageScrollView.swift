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
    @State var imageDict: [String:UIImage] = [:]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                HStack{
                    Text("\(count) images are loaded")
                }
                
                //Using SavedImageList array to cache
//                ForEach(0..<imageViewModel.imageList.count, id: \.self) { num  in
//                    if let img = imageViewModel.savedImageList[num] {
//                        Image(uiImage: img)
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 250)
//                            .clipShape(RoundedRectangle(cornerRadius: 20))
//                            .onAppear{
//                                count += 1
//                                print(count)
//                            }
//                    } else {
//                        Text("Loading")
//                            .frame(width: 250, height: 250)
//                            .clipShape(RoundedRectangle(cornerRadius: 20))
//                            .onAppear{
//                                if let imgUrl = URL(string: imageViewModel.imageList[num].urls.raw) {
//                                    imageViewModel.loadImage(from: imgUrl) { result in
//                                        DispatchQueue.main.async {
//                                            switch result {
//                                            case .success(let data):
//                                                image = UIImage(data: data)!
//                                                //크기가 정해진 빈 배열(nil로 채워진 배열)에 저장한 이미지를 저장하고 그 때 그 때 꺼내씀
//                                                imageViewModel.savedImageList[index] = image
//                                                index += 1
//                                                //인덱스가 10개가 넘어가면 처음으로 돌아감
//                                                if index > 9 {
//                                                    index = 0
//                                                }
//                                            case .failure(_ ):
//                                                break
//                                            }
//                                        }
//                                    }
//                                }
//                            }
//                    }
//                }
                
                
                //Using CoreData to cache
                ForEach(imageViewModel.imageList) { model in
                    if let image = imageDict[model.id] {
                        //이미지가 로딩됐을때
                        
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 250)
                            .onAppear{
                                print("original appeared \(model.id)")
                            }
                        
                    } else {
                        //If there is cache data in Core Data
                        if let thumbImage = ImageCacheManager.shared.loadImageCache(key: model.id) {
                            Image(uiImage: thumbImage )
                                .resizable()
                                .scaledToFit()
                                .frame(width: 250)
                                .onAppear{
                                    print("Thum no.\(model.id)")
                                    guard let url = URL(string: model.urls.raw )  else { return }
                                    imageViewModel.loadImage(from: url ) { result in
                                        switch result {
                                        case .success(let data):
                                            //데이터를 uiimage로 변환하고 뷰의 속성에 할당
                                            guard let img = UIImage(data: data) else { break }
                                            //@State 래퍼가 붙은 변수에 변화가 와야지 뷰의 업데이트가 일어난다
                                            imageDict.updateValue(img, forKey: model.id)
                                            
                                        case .failure(let error):
                                            
                                            print("error occured: Image loading error - \(error.localizedDescription)")
                                            break
                                        }
                                    }
                                }
                            
                        } else { //If there is no thumbnail image cache data in CoreData
                            Text("Loading")
                                .frame(width: 250, height: 250)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .onAppear {
                                    guard let url = URL(string: model.urls.raw )  else { return }
                                    imageViewModel.loadImage(from: url ) { result in
                                        switch result {
                                        case .success(let data):
                                            //데이터를 uiimage로 변환하고 뷰의 속성에 할당
                                            guard let img = UIImage(data: data) else { break }
                                            imageDict.updateValue(img, forKey: model.id)
                                            //데이터를 썸네일 사이즈로 다운샘플링
                                            guard let thumbImg = imageViewModel.resizeInThumb(data: data, size: CGSize(width: 100, height: 100)) else { break }
                                            //모델의 id를 ImageData entity의 name 속성에 할당하고 이미지 데이터도 할당해서 캐싱
                                            ImageCacheManager.shared.saveImageCache(image: thumbImg, forkey: model.id)
                                            
                                        case .failure(let error):
                                            
                                            print("error occured: Image loading error - \(error.localizedDescription)")
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
    ImageScrollView(imageViewModel: ImageViewModel())
}
