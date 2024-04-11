//
//  ImageModel.swift
//  ImageListApp
//
//  Created by 김기영 on 4/8/24.
//

import Foundation

//struct ImageModel: Decodable {
//    var id: String
//    var slug: String
//    var createDate: Date
//    var imageURL: ImageURL
//}
//
//struct ImageURL: Decodable {
//    var raw: String
//    var full: String
//    var regular: String
//    var thumb: String
//}
//
//enum CodingKeys: String, Codable {
//    case id
//    case slug
//    case createDate = "created_at"
//    case imageURL = "urls"
//}

// MARK: - WelcomeElement
struct ImageModel: Codable, Identifiable {
    
    
    let id :String
    let urls: Urls
    
    enum CodingKeys: String, CodingKey, Hashable {
        case id
        case urls
    }
}

struct Urls: Codable {
    let raw, full, regular, small: String
    let thumb, smallS3: String

    enum CodingKeys: String, CodingKey {
        case raw, full, regular, small, thumb
        case smallS3 = "small_s3"
    }
}


extension ImageModel: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
            return lhs.id == rhs.id
        }
}
