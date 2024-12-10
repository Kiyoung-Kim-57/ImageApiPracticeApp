//
//  ImageModel.swift
//  ImageListApp
//
//  Created by 김기영 on 4/8/24.
//

import Foundation
struct ImageDTO: Decodable, Identifiable {
    let id :String
    let altDescription: String
    let imageSizeURL: ImageSizeURL
    
    enum CodingKeys: String, CodingKey, Hashable {
        case id
        case altDescription = "alt_description"
        case imageSizeURL = "urls"
    }
}

struct ImageSizeURL: Decodable {
    let raw, full, regular, small, thumb, smallS3: String

    enum CodingKeys: String, CodingKey {
        case raw, full, regular, small, thumb
        case smallS3 = "small_s3"
    }
}

extension ImageDTO: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
            return lhs.id == rhs.id
        }
}
