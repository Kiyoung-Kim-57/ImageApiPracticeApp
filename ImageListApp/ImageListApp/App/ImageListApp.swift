//
//  ImageListAppApp.swift
//  ImageListApp
//
//  Created by 김기영 on 4/3/24.
//

import SwiftUI

@main
struct ImageListApp: App {
    let imageCacheManager = ImageCacheManager.shared

    var body: some Scene {
        WindowGroup {
            StartView()
                .environment(\.managedObjectContext, imageCacheManager.persistanceContainer.viewContext)
        }
    }
}
