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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
