//
//  ImageListAppApp.swift
//  ImageListApp
//
//  Created by 김기영 on 4/3/24.
//

import SwiftUI

@main
struct ImageListAppApp: App {
    let imageCacheManager = ImageCacheManager.shared

    var body: some Scene {
        WindowGroup {
            TestContentView()
                .environment(\.managedObjectContext, imageCacheManager.persistanceContainer.viewContext)
        }
    }
}
