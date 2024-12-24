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
    @State var imageDict: [String:UIImage] = [:]
    
    var body: some View {
        ScrollView {
            VStack(spacing: Constants.vStackSpacing) {
                //Using CoreData to cache
                imageList(list: imageViewModel.imageList)
            }
        }
    }
}

extension ImageScrollView {
    private func imageList(list: [ImageDTO]) -> some View {
        ForEach(list) { model in
            ImageCellView(model: model)
        }
    }
    
    @ViewBuilder
    private func ImageCellView(model: ImageDTO) -> some View {
        if let image = imageDict[model.id] {
            thumbnailImageView(image: image)
                .onAppear{
                    debugPrint("original appeared \(model.id)")
                }
        } else {
            waitingFetchingView(model: model)
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
    
    private func thumbnailImageView(
        image: UIImage,
        isLoadingTextHidden: Bool = true
    ) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .frame(width: Constants.imageFrameSize)
            .overlay {
                Text("Loading")
                    .frame(
                        width: Constants.imageFrameSize,
                        height: Constants.imageFrameSize
                    )
                    .opacity(isLoadingTextHidden ? 0 : 1)
            }
            .clipShape(
                RoundedRectangle(cornerRadius: Constants.imageCornerRadius)
            )
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
            size: CGSize(
                width: Constants.imageFrameSize,
                height: Constants.imageFrameSize
            )
        ) else { return }
        
        ImageCacheManager.shared.saveImageCache(image: thumbImg, forkey: id)
    }
}

extension ImageScrollView {
    private enum Constants {
        static let vStackSpacing: CGFloat = 30
        static let imageFrameSize: CGFloat = 250
        static let imageCornerRadius: CGFloat = 20
    }
}
