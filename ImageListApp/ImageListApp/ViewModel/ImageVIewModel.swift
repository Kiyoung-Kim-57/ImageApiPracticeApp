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
        //For test
        ImageModel(id: "1", urls: Urls(raw: "", full: "", regular: "", small: "", thumb: "https://plus.unsplash.com/premium_photo-1703618158960-661ea02dffb2?q=80&w=3271&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D", smallS3: "")),
        ImageModel(id: "2", urls: Urls(raw: "", full: "", regular: "", small: "", thumb:"https://images.unsplash.com/photo-1701749059090-ac8afdba7b44?q=80&w=3087&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D", smallS3: "")),
        ImageModel(id: "3", urls: Urls(raw: "", full: "", regular: "", small: "", thumb:"https://images.unsplash.com/photo-1701749059090-ac8afdba7b44?q=80&w=3087&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D", smallS3: "")),
        ImageModel(id: "4", urls: Urls(raw: "", full: "", regular: "", small: "", thumb:"https://images.unsplash.com/photo-1701749059090-ac8afdba7b44?q=80&w=3087&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D", smallS3: "")),
        ImageModel(id: "5", urls: Urls(raw: "", full: "", regular: "", small: "", thumb:"https://images.unsplash.com/photo-1701749059090-ac8afdba7b44?q=80&w=3087&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D", smallS3: "")),
        ImageModel(id: "6", urls: Urls(raw: "", full: "", regular: "", small: "", thumb:"https://images.unsplash.com/photo-1701749059090-ac8afdba7b44?q=80&w=3087&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D", smallS3: "")),
        ImageModel(id: "7", urls: Urls(raw: "", full: "", regular: "", small: "", thumb:"https://images.unsplash.com/photo-1701749059090-ac8afdba7b44?q=80&w=3087&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D", smallS3: "")),
        ImageModel(id: "8", urls: Urls(raw: "", full: "", regular: "", small: "", thumb:"https://images.unsplash.com/photo-1701749059090-ac8afdba7b44?q=80&w=3087&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D", smallS3: "")),
        ImageModel(id: "9", urls: Urls(raw: "", full: "", regular: "", small: "", thumb:"https://images.unsplash.com/photo-1701749059090-ac8afdba7b44?q=80&w=3087&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D", smallS3: ""))
        
    ]
    
    
    
    func getImageList() {
        ImageService().getImage { result in
            switch result {
            case .success(let list):
                self.imageList = list
            case .failure(_ ):
                print("error")
            }
        }
    }
}

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    @Published var imageList: [UIImage] = []
    
    func loadImage(from url: URL, completion: @escaping (Result<Data, CallError>) -> Void) {
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { return completion(.failure(.error)) }
            return completion(.success(data))
        }.resume()
    }
}

enum CallError: Error {
    case error
}
