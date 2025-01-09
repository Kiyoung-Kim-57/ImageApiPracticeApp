//
//  ImageManager.swift
//  ImageListApp
//
//  Created by 김기영 on 12/10/24.
//

import Foundation
import UIKit

enum ImageManager {
    static func resizeImage(image: UIImage) async throws -> UIImage {
        let resized = image.resize(ratio: 0.5)
        return resized
    }
    
    static func downSampleImage(data: Data ,size: CGSize) -> UIImage? {
        let maxDimension = max(size.width, size.height) * UITraitCollection.current.displayScale
        let options: [CFString: Any] = [
                    kCGImageSourceShouldCache: false,
                    kCGImageSourceCreateThumbnailFromImageAlways: true,
                    kCGImageSourceCreateThumbnailFromImageIfAbsent: true,
                    kCGImageSourceThumbnailMaxPixelSize: maxDimension,
                    kCGImageSourceCreateThumbnailWithTransform: true
                ]
        
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil),
              let cgImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary)
        else { return nil }
        
        let resizedImage = UIImage(cgImage: cgImage)
        return resizedImage
    }
}
