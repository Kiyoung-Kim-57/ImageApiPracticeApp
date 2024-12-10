//
//  ImageCacheManager.swift
//  ImageListApp
//
//  Created by 김기영 on 4/24/24.
//

import Foundation
import CoreData
import UIKit

final class ImageCacheManager {
    static let shared = ImageCacheManager()
    
    lazy var persistanceContainer: NSPersistentContainer = {
        //앱의 코어데이터 파일명
        let container = NSPersistentContainer(name: "ImageListApp")
        container.loadPersistentStores { _, error in
            if let error = error {
                debugPrint("error: \(error.localizedDescription)")
            }
        }
        return container
    }()
    //이미지캐시를 코어데이터에 저장
    func saveImageCache(image: UIImage, forkey key: String) {
        let context = persistanceContainer.viewContext
        let entity = ImageData(context: context)
        
        entity.data = image.pngData()
        entity.name = key
        
        do {
            try context.save()
        } catch {
            debugPrint("\(error.localizedDescription)")
        }
    }
    //이미지캐시를 코어데이터에서 로드
    func loadImageCache(key: String) -> UIImage? {
        let context = persistanceContainer.viewContext
        //ImageData entity fetch request
        let fetchRequest: NSFetchRequest<ImageData> = ImageData.fetchRequest()
        //코어 데이터에서 패치한 데이터를 필터링
        fetchRequest.predicate = NSPredicate(format: "name == %@", key)
        
        do {
            let result = try context.fetch(fetchRequest)
            if let cachedImage = result.first?.data {
                return UIImage(data: cachedImage)
            }
        } catch {
            debugPrint("error: \(error.localizedDescription)")
        }

        return nil
    }
    
    func deleteAllImageCache() {
        let context = persistanceContainer.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "ImageData")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            debugPrint("cache deleted")
        } catch {
            debugPrint("error occured cache is not deleted yet")
        }
    }
}
