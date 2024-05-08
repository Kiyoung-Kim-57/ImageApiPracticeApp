//
//  ImageService.swift
//  ImageListApp
//
//  Created by 김기영 on 4/8/24.
//

import Foundation

class ImageService {
//    var apiKey: String = ApiModel().unsplashKey
    var apiKey: String? {
        return Bundle.main.apiKey
    }
    var apiURL: URLComponents {
        var urlComponenets = URLComponents()
        urlComponenets.scheme = "https"
        urlComponenets.host = "api.unsplash.com"
        return urlComponenets
    }
    
    func getImage(completion: @escaping (Result<[ImageModel], ImageError>) -> Void) {
//        var url = URL(string: "https://api.unsplash.com/photos/random?client_id=\(apiKey)&count=10")
        guard let apiKey = apiKey else { return }
        
        var urlComponents = apiURL
        urlComponents.path = "/photos/random"
        urlComponents.queryItems = [
            //불러올 이미지의 수
            URLQueryItem(name: "count", value: "10"),
            //개인 api key
            URLQueryItem(name: "client_id", value: apiKey)
        ]
        guard let url = urlComponents.url else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return completion(.failure(.requestError))}
            
            let imageResponse = try? JSONDecoder().decode([ImageModel].self, from: data)
            
            if let imageResponse = imageResponse {
                completion(.success(imageResponse))
            } else {
                completion(.failure(.requestError))
            }
        }.resume()
    }
    
    
}

enum ImageError:Error {
    case requestError
}
