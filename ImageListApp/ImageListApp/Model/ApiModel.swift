//
//  ApiModel.swift
//  ImageListApp
//
//  Created by 김기영 on 4/8/24.
//

import Foundation

class ApiModel {
    var unsplashKey: String {
        return Bundle.main.apiKey
    }
}


extension Bundle {
    var apiKey: String {
        guard let filePath = Bundle.main.url(forResource: "ApiList", withExtension: "plist") else {
            fatalError("No such file directory")
        }
        do {
            //filepath에서 데이터 생성
            let data = try Data(contentsOf: filePath)
            //데이터를 ApiList에 맞춰 디코딩
            let result = try PropertyListDecoder().decode(ApiList.self, from: data)
            return result.imageKey
        } catch {
            fatalError()
        }
    }
}

private struct ApiList: Codable {
    let imageKey: String
    
    enum CodingKeys: String, CodingKey {
        //Plist 안에 "UnsplashApi"가 있는 경우 imageKey로 받아서 변수 imageKey에 할당
        case imageKey = "UnsplashApi"
    }
}
