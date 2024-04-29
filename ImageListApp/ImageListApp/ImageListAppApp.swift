//
//  ImageListAppApp.swift
//  ImageListApp
//
//  Created by 김기영 on 4/3/24.
//

import SwiftUI

@main
struct ImageListAppApp: App {
    let persistenceController = PersistenceController.shared
//    let imageCacheManager = ImageCacheManager.shared

    var body: some Scene {
        WindowGroup {
//            TestContentView()
            ImageContainerListView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
//                .environment(\.managedObjectContext, imageCacheManager.persistanceContainer.viewContext)
        }
    }
}
