//
//  ImageVIewModel.swift
//  ImageListApp
//
//  Created by 김기영 on 4/9/24.
//

import Foundation
import UIKit

class ImageViewModel: ObservableObject {
    @Published var imageList: [ImageModel] = [
//        //For test
        ImageModel(id: "1", urls: Urls(raw: "https://plus.unsplash.com/premium_photo-1703618158960-661ea02dffb2?q=80&w=3271&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D", full: "", regular: "", small: "", thumb: "https://plus.unsplash.com/premium_photo-1703618158960-661ea02dffb2?q=80&w=3271&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D", smallS3: "")),
        ImageModel(id: "2", urls: Urls(raw: "https://images.unsplash.com/photo-1701749059090-ac8afdba7b44?q=80&w=3087&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D", full: "", regular: "", small: "", thumb:"", smallS3: "")),
        ImageModel(id: "3", urls: Urls(raw: "https://images.unsplash.com/photo-1713553579944-5f8a041eeae5?q=80&w=3087&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D", full: "", regular: "", small: "", thumb:"", smallS3: "")),
        ImageModel(id: "4", urls: Urls(raw: "https://images.unsplash.com/photo-1713902115860-03ca793849f5?q=80&w=2641&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D", full: "", regular: "", small: "", thumb:"", smallS3: "")),
        ImageModel(id: "5", urls: Urls(raw: "https://images.unsplash.com/photo-1690575539214-eb0ade6cdd4d?q=80&w=3027&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D", full: "", regular: "", small: "", thumb:"", smallS3: "")),
        ImageModel(id: "6", urls: Urls(raw: "https://plus.unsplash.com/premium_photo-1669446008871-fc638b9dec04?q=80&w=3270&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D", full: "", regular: "", small: "", thumb:"", smallS3: "")),
        ImageModel(id: "7", urls: Urls(raw: "https://images.unsplash.com/photo-1713184355726-d3a31d822fcc?q=80&w=3200&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D", full: "", regular: "", small: "", thumb:"", smallS3: "")),
        ImageModel(id: "8", urls: Urls(raw: "https://images.unsplash.com/photo-1713815540178-8322b898a2c4?q=80&w=3044&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D", full: "", regular: "", small: "", thumb:"", smallS3: "")),
        ImageModel(id: "9", urls: Urls(raw: "https://images.unsplash.com/photo-1713774590628-6af0be775ef0?q=80&w=3276&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D", full: "", regular: "", small: "", thumb:"", smallS3: ""))
        
    ]
    @Published var savedImageList: [UIImage?] = [UIImage?](repeating: nil, count: 10)
    @Published var savedThumbnails: [String : UIImage] = [:]
    
    
    func getImageList() {
        ImageService().getImage { result in
            switch result {
            case .success(let list):
                DispatchQueue.main.async {
                    self.imageList = list
                }
            case .failure(_ ):
                print("error")
            }
        }
    }
    
    func loadImage(from url: URL, completion: @escaping (Result<Data, CallError>) -> Void) {
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { return completion(.failure(.error)) }
            return completion(.success(data))
        }.resume()
    }
    
    //To test resizing images in background
    func resizeImage(image: UIImage) async throws -> UIImage {
        let resized = image.resize(ratio: 0.5)
        return resized
    }
    
    func resizeInThumb(data: Data ,size: CGSize) -> UIImage? {
        //리사이즈할 때 적용할 옵션을 딕셔너리 방식으로 지정
        let options: [CFString: Any] = [
                    kCGImageSourceShouldCache: false,
                    kCGImageSourceCreateThumbnailFromImageAlways: true,
                    kCGImageSourceCreateThumbnailFromImageIfAbsent: true,
                    kCGImageSourceThumbnailMaxPixelSize: max(size.width, size.height),
                    kCGImageSourceCreateThumbnailWithTransform: true
                ]
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil),
              //옵션을 적용해서 imageSource 데이터를 다운샘플링함
              let cgImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary) else { return nil }
        //다운샘플링된 데이터를 uiimage로 저장
        let resizedImage = UIImage(cgImage: cgImage)
        return resizedImage
    }
}

//class ImageLoader: ObservableObject {
//    @Published var savedImageList: [UIImage?] = [UIImage?](repeating: nil, count: 10)
//    
//    func loadImage(from url: URL, completion: @escaping (Result<Data, CallError>) -> Void) {
//        
//        URLSession.shared.dataTask(with: url) { data, _, error in
//            guard let data = data, error == nil else { return completion(.failure(.error)) }
//            return completion(.success(data))
//        }.resume()
//    }
//    
//    //To test resizing images in background
//    func resizeImage(image: UIImage) async throws -> UIImage {
//        let resized = image.resize(ratio: 0.5)
//        return resized
//    }
//    
//    func resize2(data: Data ,size: CGSize) -> UIImage? {
//        let options: [CFString: Any] = [
//                    kCGImageSourceShouldCache: false,
//                    kCGImageSourceCreateThumbnailFromImageAlways: true,
//                    kCGImageSourceCreateThumbnailFromImageIfAbsent: true,
//                    kCGImageSourceThumbnailMaxPixelSize: max(size.width, size.height),
//                    kCGImageSourceCreateThumbnailWithTransform: true
//                ]
//        guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil),
//              let cgImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary) else { return nil }
//        
//        let resizedImage = UIImage(cgImage: cgImage)
//        return resizedImage
//    }
//   
//    
//}

enum CallError: Error {
    case error
}
