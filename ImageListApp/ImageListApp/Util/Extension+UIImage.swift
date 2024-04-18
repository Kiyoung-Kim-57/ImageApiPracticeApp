//
//  Extension+UIImage.swift
//  ImageListApp
//
//  Created by 김기영 on 4/13/24.
//

import Foundation
import SwiftUI

extension UIImage {
    func resize(ratio: CGFloat) -> UIImage {
        let newWidth = self.size.width * ratio
        let newHeight = self.size.height * ratio
        let newSize = CGSize(width: newWidth, height: newHeight)
        let render = UIGraphicsImageRenderer(size: newSize)
        let renderedImage = render.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
        
        return renderedImage
    }
    
    func resize2(size: CGSize) -> UIImage? {
        let options: [CFString: Any] = [
                    kCGImageSourceShouldCache: false,
                    kCGImageSourceCreateThumbnailFromImageAlways: true,
                    kCGImageSourceCreateThumbnailFromImageIfAbsent: true,
                    kCGImageSourceThumbnailMaxPixelSize: max(size.width, size.height),
                    kCGImageSourceCreateThumbnailWithTransform: true
                ]
        
        guard let data = jpegData(compressionQuality: 1.0),
              let imageSource = CGImageSourceCreateWithData(data as CFData, nil),
              let cgImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary) else { return nil }
        
        let resizedImage = UIImage(cgImage: cgImage)
        return resizedImage
    }
}
