//
//  ImageVIewModel.swift
//  ImageListApp
//
//  Created by 김기영 on 4/9/24.
//

import Foundation
import UIKit

final class ImageViewModel: ObservableObject {
    @Published var imageList: [ImageDTO] = []
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
}

enum CallError: Error {
    case error
}
