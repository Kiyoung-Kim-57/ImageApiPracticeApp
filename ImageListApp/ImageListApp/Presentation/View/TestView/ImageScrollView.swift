//
//  FirstScrollView.swift
//  ImageListApp
//
//  Created by 김기영 on 4/11/24.
//

import SwiftUI
//단순하게 스크롤뷰에서 매 요소마다 원본 이미지를 불러오는 스크롤뷰, 이미지 용량이 큰 경우 메모리 사용이 크다
struct ImageScrollView: View {
    @ObservedObject var imageViewModel: ImageViewModel
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
                //Using CoreData to cache
                imageList(list: imageViewModel.imageList)
            }
        }
    }
}

extension ImageScrollView {
    private func imageList(list: [ImageDTO]) -> some View {
        ForEach(list) { model in
            if let image = imageDict[model.id] {
                thumbnailImageView(image: image)
                    .onAppear{
                        debugPrint("original appeared \(model.id)")
                    }
            } else {
                waitingFetchingView(model: model)
            }
        }
    }
    
    private func waitingFetchingView(model: ImageDTO) -> some View {
        if let thumbImage = ImageCacheManager.shared.loadImageCache(key: model.id) {
            thumbnailImageView(image: thumbImage)
                .onAppear{
                    debugPrint("Thum no.\(model.id)")
                    guard let url = URL(string: model.imageSizeURL.raw )  else { return }
                    fetchImage(url: url, id: model.id)
                }
        } else {
            thumbnailImageView(image: UIImage(), isLoadingTextHidden: false)
                .onAppear {
                    guard let url = URL(string: model.imageSizeURL.raw )  else { return }
                    fetchImage(url: url, id: model.id, isCaching: true)
                }
        }
    }
    
    private func thumbnailImageView(image: UIImage, isLoadingTextHidden: Bool = true) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .frame(width: 250)
            .overlay {
                Text("Loading")
                    .frame(width: 250, height: 250)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .opacity(isLoadingTextHidden ? 0 : 1)
            }
    }
    
    private func fetchImage(url: URL, id: String, isCaching: Bool = false) {
        imageViewModel.loadImage(from: url ) { result in
            switch result {
            case .success(let data):
                guard let img = UIImage(data: data) else { break }
                imageDict.updateValue(img, forKey: id)
                
                guard isCaching else { return }
                cacheImage(data: data, id: id)
            case .failure(let error):
                debugPrint("error occured: Image loading error - \(error.localizedDescription)")
                break
            }
        }
    }
    private func cacheImage(data: Data, id: String) {
        guard let thumbImg = ImageManager.downSampleImage(
            data: data,
            size: CGSize(width: 100, height: 100)
        ) else { return }
        
        ImageCacheManager.shared.saveImageCache(image: thumbImg, forkey: id)
    }
}
