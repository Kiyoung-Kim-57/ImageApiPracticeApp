//
//  ApiModel.swift
//  ImageListApp
//
//  Created by 김기영 on 4/8/24.
//

import Foundation

extension Bundle {
    var apiKey: String? {
        guard let filePath = Bundle.main.url(forResource: "ApiList", withExtension: "plist"),
              let data = try? Data(contentsOf: filePath)
        else {
            return nil
        }
        
        return try? PropertyListDecoder().decode(ApiList.self, from: data).imageKey
    }
}

private struct ApiList: Codable {
    let imageKey: String
    
    enum CodingKeys: String, CodingKey {
        case imageKey = "UnsplashApi"
    }
}
